from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from django.db.models import Q

from mothers.models import (
    Mother, PreventionMessage, Pregnancy,
    MedicalHistory, SpouseInfo, PrenatalConsultation,
    Vaccination, MedicalExam, Treatment, Appointment
)
from mothers.serializers import (
    FullHealthRecordSerializer, FullPregnancySerializer,
    MedicalHistorySerializer, SpouseInfoSerializer,
    PrenatalConsultationSerializer, VaccinationSerializer,
    MedicalExamSerializer, TreatmentSerializer, AppointmentSerializer
)
from .serializers import (
    QRAuthSerializer,
    MotherProfileSerializer,
    PreventionMessageMobileSerializer,
    MotherUpdateSerializer,
)


class QRAuthView(APIView):
    """
    Authentification de la maman par scan du QR code.
    
    POST /api/mobile/auth/qr-login/
    
    La maman scanne son QR code, on vérifie qu'il est valide
    et on lui retourne un token JWT pour accéder à ses données.
    """
    
    permission_classes = [AllowAny]
    
    def post(self, request):
        serializer = QRAuthSerializer(data=request.data)
        
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        # Récupère la mère associée au QR code
        mother = serializer.get_mother()
        
        # Génère les tokens JWT pour la maman
        # On utilise le code QR comme identifiant unique
        refresh = RefreshToken()
        refresh["mother_id"] = mother.id
        refresh["qr_code"] = mother.qr_card.code
        refresh["type"] = "mother"
        
        return Response({
            "success": True,
            "message": f"Bienvenue {mother.full_name} !",
            "tokens": {
                "access": str(refresh.access_token),
                "refresh": str(refresh),
            },
            "mother": MotherProfileSerializer(mother, context={"request": request}).data
        }, status=status.HTTP_200_OK)


class MotherProfileView(APIView):
    """
    Récupère le profil complet de la maman.
    
    GET /api/mobile/profile/
    
    Retourne toutes les informations :
    - Données personnelles
    - Carte QR
    - Centre de suivi
    - Carnet de santé
    """
    
    permission_classes = [AllowAny]  # On utilisera le token maman
    
    def get(self, request):
        # Récupère le mother_id depuis le token
        mother_id = request.auth.get("mother_id") if request.auth else None
        
        if not mother_id:
            # Fallback: chercher dans le query param pour les tests
            qr_code = request.query_params.get("qr_code")
            if qr_code:
                try:
                    mother = Mother.objects.select_related(
                        "qr_card", "center", "health_record"
                    ).get(qr_card__code=qr_code)
                except Mother.DoesNotExist:
                    return Response(
                        {"error": "Profil non trouvé"},
                        status=status.HTTP_404_NOT_FOUND
                    )
            else:
                return Response(
                    {"error": "Token invalide ou manquant"},
                    status=status.HTTP_401_UNAUTHORIZED
                )
        else:
            try:
                mother = Mother.objects.select_related(
                    "qr_card", "center", "health_record"
                ).get(id=mother_id)
            except Mother.DoesNotExist:
                return Response(
                    {"error": "Profil non trouvé"},
                    status=status.HTTP_404_NOT_FOUND
                )
        
        serializer = MotherProfileSerializer(mother, context={"request": request})
        return Response(serializer.data)
    
    def patch(self, request):
        """Met à jour le profil de la maman (téléphone, adresse)."""
        mother_id = request.auth.get("mother_id") if request.auth else None
        
        if not mother_id:
            return Response(
                {"error": "Token invalide ou manquant"},
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        try:
            mother = Mother.objects.get(id=mother_id)
        except Mother.DoesNotExist:
            return Response(
                {"error": "Profil non trouvé"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        serializer = MotherUpdateSerializer(mother, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({
                "success": True,
                "message": "Profil mis à jour",
                "data": MotherProfileSerializer(mother, context={"request": request}).data
            })
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class MotherMessagesView(APIView):
    """
    Récupère les messages de prévention destinés aux mamans.
    
    GET /api/mobile/messages/
    
    Retourne les messages publiés ciblant les mères ou tous.
    """
    
    permission_classes = [AllowAny]
    
    def get(self, request):
        # Messages publiés pour les mères ou tous
        messages = PreventionMessage.objects.filter(
            status=PreventionMessage.Status.PUBLISHED,
        ).filter(
            Q(target=PreventionMessage.Target.MOTHERS) |
            Q(target=PreventionMessage.Target.ALL)
        ).order_by("-published_at")[:20]
        
        serializer = PreventionMessageMobileSerializer(messages, many=True)
        return Response({
            "count": messages.count(),
            "messages": serializer.data
        })


class MotherHealthRecordView(APIView):
    """
    Récupère le carnet de santé détaillé de la maman.
    
    GET /api/mobile/health-record/
    
    Retourne les détails du carnet de santé.
    """
    
    permission_classes = [AllowAny]
    
    def get(self, request):
        qr_code = request.query_params.get("qr_code")
        mother_id = request.auth.get("mother_id") if request.auth else None
        
        if mother_id:
            try:
                mother = Mother.objects.select_related("health_record").get(id=mother_id)
            except Mother.DoesNotExist:
                return Response(
                    {"error": "Maman non trouvée"},
                    status=status.HTTP_404_NOT_FOUND
                )
        elif qr_code:
            try:
                mother = Mother.objects.select_related("health_record").get(
                    qr_card__code=qr_code
                )
            except Mother.DoesNotExist:
                return Response(
                    {"error": "QR code invalide"},
                    status=status.HTTP_404_NOT_FOUND
                )
        else:
            return Response(
                {"error": "Token ou QR code requis"},
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        if not hasattr(mother, "health_record"):
            return Response({
                "has_record": False,
                "message": "Aucun carnet de santé n'a encore été créé pour cette maman."
            })
        
        from .serializers import HealthRecordMobileSerializer
        serializer = HealthRecordMobileSerializer(
            mother.health_record,
            context={"request": request}
        )
        
        return Response({
            "has_record": True,
            "mother_name": mother.full_name,
            "health_record": serializer.data
        })


class VerifyQRCodeView(APIView):
    """
    Vérifie simplement si un QR code est valide.
    
    POST /api/mobile/verify-qr/
    
    Utile pour l'app Flutter avant de faire le login complet.
    """
    
    permission_classes = [AllowAny]
    
    def post(self, request):
        qr_code = request.data.get("qr_code")
        
        if not qr_code:
            return Response({
                "valid": False,
                "error": "Code QR manquant"
            }, status=status.HTTP_400_BAD_REQUEST)
        
        from qr_codes.models import QRCodeCard
        
        try:
            qr_card = QRCodeCard.objects.get(code=qr_code)
        except QRCodeCard.DoesNotExist:
            return Response({
                "valid": False,
                "status": "unknown",
                "message": "Ce QR code n'existe pas dans notre système."
            })
        
        if qr_card.status == QRCodeCard.Status.PENDING:
            return Response({
                "valid": False,
                "status": "pending",
                "message": "Cette carte n'a pas encore été activée. Veuillez consulter un agent de santé."
            })
        
        # Vérifie si une mère est associée
        if not hasattr(qr_card, "mother"):
            return Response({
                "valid": False,
                "status": "no_mother",
                "message": "Aucune mère n'est associée à cette carte."
            })
        
        return Response({
            "valid": True,
            "status": "active",
            "mother_name": qr_card.mother.full_name,
            "message": f"Carte active pour {qr_card.mother.full_name}"
        })


# ============================================================================
# ENDPOINTS CARNET COMPLET POUR LA MAMAN
# ============================================================================

class FullHealthRecordView(APIView):
    """
    Récupère le carnet de santé COMPLET de la maman.
    
    GET /api/mobile/full-health-record/
    
    Retourne toutes les informations du carnet :
    - Infos mère et père
    - Antécédents médicaux
    - Informations conjoint
    - Liste des grossesses
    - Grossesse en cours (si applicable)
    """
    
    permission_classes = [AllowAny]
    
    def get(self, request):
        qr_code = request.query_params.get("qr_code")
        mother_id = request.auth.get("mother_id") if request.auth else None
        
        if mother_id:
            try:
                mother = Mother.objects.select_related(
                    "health_record", "qr_card", "center"
                ).prefetch_related(
                    "medical_histories", "pregnancies"
                ).get(id=mother_id)
            except Mother.DoesNotExist:
                return Response(
                    {"error": "Maman non trouvée"},
                    status=status.HTTP_404_NOT_FOUND
                )
        elif qr_code:
            try:
                mother = Mother.objects.select_related(
                    "health_record", "qr_card", "center"
                ).prefetch_related(
                    "medical_histories", "pregnancies"
                ).get(qr_card__code=qr_code)
            except Mother.DoesNotExist:
                return Response(
                    {"error": "QR code invalide"},
                    status=status.HTTP_404_NOT_FOUND
                )
        else:
            return Response(
                {"error": "Token ou QR code requis"},
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        if not hasattr(mother, "health_record"):
            return Response({
                "has_record": False,
                "message": "Aucun carnet de santé n'a encore été créé."
            })
        
        serializer = FullHealthRecordSerializer(
            mother.health_record,
            context={"request": request}
        )
        
        return Response({
            "has_record": True,
            "data": serializer.data
        })


class PregnancyDetailMobileView(APIView):
    """
    Récupère le détail complet d'une grossesse.
    
    GET /api/mobile/pregnancies/<id>/
    
    Retourne :
    - Infos de la grossesse
    - Consultations prénatales
    - Vaccinations
    - Examens
    - Traitements
    - Évolution
    - Plan d'accouchement
    - Rendez-vous
    """
    
    permission_classes = [AllowAny]
    
    def get(self, request, pk):
        qr_code = request.query_params.get("qr_code")
        mother_id = request.auth.get("mother_id") if request.auth else None
        
        try:
            pregnancy = Pregnancy.objects.select_related(
                "mother", "lieu_accouchement"
            ).prefetch_related(
                "children", "consultations", "vaccinations",
                "exams", "treatments", "evolutions", "appointments"
            ).get(pk=pk)
        except Pregnancy.DoesNotExist:
            return Response(
                {"error": "Grossesse non trouvée"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Vérifier que la grossesse appartient bien à la maman
        if mother_id and pregnancy.mother_id != mother_id:
            return Response(
                {"error": "Cette grossesse ne vous appartient pas"},
                status=status.HTTP_403_FORBIDDEN
            )
        
        if qr_code and pregnancy.mother.qr_card.code != qr_code:
            return Response(
                {"error": "Cette grossesse ne vous appartient pas"},
                status=status.HTTP_403_FORBIDDEN
            )
        
        serializer = FullPregnancySerializer(pregnancy)
        return Response(serializer.data)


class ConsultationsMobileView(APIView):
    """
    Liste des consultations prénatales de la maman.
    
    GET /api/mobile/consultations/
    """
    
    permission_classes = [AllowAny]
    
    def get(self, request):
        qr_code = request.query_params.get("qr_code")
        pregnancy_id = request.query_params.get("pregnancy_id")
        mother_id = request.auth.get("mother_id") if request.auth else None
        
        if mother_id:
            consultations = PrenatalConsultation.objects.filter(
                pregnancy__mother_id=mother_id
            )
        elif qr_code:
            consultations = PrenatalConsultation.objects.filter(
                pregnancy__mother__qr_card__code=qr_code
            )
        else:
            return Response(
                {"error": "Token ou QR code requis"},
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        if pregnancy_id:
            consultations = consultations.filter(pregnancy_id=pregnancy_id)
        
        consultations = consultations.order_by("-date")
        serializer = PrenatalConsultationSerializer(consultations, many=True)
        
        return Response({
            "count": consultations.count(),
            "consultations": serializer.data
        })


class VaccinationsMobileView(APIView):
    """
    Liste des vaccinations de la maman.
    
    GET /api/mobile/vaccinations/
    """
    
    permission_classes = [AllowAny]
    
    def get(self, request):
        qr_code = request.query_params.get("qr_code")
        pregnancy_id = request.query_params.get("pregnancy_id")
        mother_id = request.auth.get("mother_id") if request.auth else None
        
        if mother_id:
            vaccinations = Vaccination.objects.filter(
                pregnancy__mother_id=mother_id
            )
        elif qr_code:
            vaccinations = Vaccination.objects.filter(
                pregnancy__mother__qr_card__code=qr_code
            )
        else:
            return Response(
                {"error": "Token ou QR code requis"},
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        if pregnancy_id:
            vaccinations = vaccinations.filter(pregnancy_id=pregnancy_id)
        
        vaccinations = vaccinations.order_by("-date")
        serializer = VaccinationSerializer(vaccinations, many=True)
        
        return Response({
            "count": vaccinations.count(),
            "vaccinations": serializer.data
        })


class AppointmentsMobileView(APIView):
    """
    Liste des rendez-vous de la maman.
    
    GET /api/mobile/appointments/
    """
    
    permission_classes = [AllowAny]
    
    def get(self, request):
        qr_code = request.query_params.get("qr_code")
        pregnancy_id = request.query_params.get("pregnancy_id")
        status_filter = request.query_params.get("status")
        mother_id = request.auth.get("mother_id") if request.auth else None
        
        if mother_id:
            appointments = Appointment.objects.filter(
                pregnancy__mother_id=mother_id
            )
        elif qr_code:
            appointments = Appointment.objects.filter(
                pregnancy__mother__qr_card__code=qr_code
            )
        else:
            return Response(
                {"error": "Token ou QR code requis"},
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        if pregnancy_id:
            appointments = appointments.filter(pregnancy_id=pregnancy_id)
        
        if status_filter:
            appointments = appointments.filter(status=status_filter)
        
        appointments = appointments.order_by("date")
        serializer = AppointmentSerializer(appointments, many=True)
        
        # Séparer les prochains RDV et les passés
        from datetime import date
        today = date.today()
        upcoming = [a for a in serializer.data if a['date'] >= str(today)]
        past = [a for a in serializer.data if a['date'] < str(today)]
        
        return Response({
            "total": appointments.count(),
            "upcoming_count": len(upcoming),
            "upcoming": upcoming,
            "past": past
        })


class MedicalHistoryMobileView(APIView):
    """
    Antécédents médicaux de la maman.
    
    GET /api/mobile/medical-history/
    """
    
    permission_classes = [AllowAny]
    
    def get(self, request):
        qr_code = request.query_params.get("qr_code")
        type_filter = request.query_params.get("type")
        mother_id = request.auth.get("mother_id") if request.auth else None
        
        if mother_id:
            histories = MedicalHistory.objects.filter(mother_id=mother_id)
        elif qr_code:
            histories = MedicalHistory.objects.filter(
                mother__qr_card__code=qr_code
            )
        else:
            return Response(
                {"error": "Token ou QR code requis"},
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        if type_filter:
            histories = histories.filter(type=type_filter)
        
        serializer = MedicalHistorySerializer(histories, many=True)
        
        # Grouper par type
        grouped = {
            "medical": [],
            "chirurgical": [],
            "familial": [],
            "allergie": []
        }
        for h in serializer.data:
            if h['type'] in grouped:
                grouped[h['type']].append(h)
        
        return Response({
            "count": histories.count(),
            "grouped": grouped,
            "all": serializer.data
        })

