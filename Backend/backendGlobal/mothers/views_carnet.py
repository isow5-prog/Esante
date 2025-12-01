"""
Vues pour la gestion complète du carnet de santé.

PRINCIPE: TOUT passe par le QR code !
La sage-femme scanne le QR code et peut tout faire.
Elle travaille automatiquement avec la grossesse EN COURS.
"""
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404

from qr_codes.models import QRCodeCard
from .models import (
    Mother, Pregnancy, Child, MedicalHistory, SpouseInfo,
    PrenatalConsultation, Vaccination, MedicalExam,
    Treatment, PregnancyEvolution, BirthPlan, Appointment
)
from .serializers import (
    PregnancyListSerializer, PregnancyDetailSerializer, FullPregnancySerializer,
    ChildSerializer, MedicalHistorySerializer, SpouseInfoSerializer,
    PrenatalConsultationSerializer, VaccinationSerializer, MedicalExamSerializer,
    TreatmentSerializer, PregnancyEvolutionSerializer, BirthPlanSerializer,
    AppointmentSerializer, MotherSerializer
)


def get_mother_by_qr(qr_code):
    """Récupère une mère à partir de son QR code."""
    try:
        qr_card = QRCodeCard.objects.get(code=qr_code)
    except QRCodeCard.DoesNotExist:
        return None, None, {"error": "QR code invalide ou inexistant."}
    
    if qr_card.status != QRCodeCard.Status.VALIDATED:
        return None, None, {"error": "Cette carte n'est pas encore activée."}
    
    if not hasattr(qr_card, "mother"):
        return None, None, {"error": "Aucune mère associée à ce QR code."}
    
    mother = qr_card.mother
    
    # Récupère automatiquement la grossesse en cours
    current_pregnancy = mother.pregnancies.filter(
        status=Pregnancy.Status.EN_COURS
    ).first()
    
    return mother, current_pregnancy, None


def get_qr_from_request(request):
    """Récupère le QR code depuis la requête (GET ou POST)."""
    if request.method == "GET":
        return request.query_params.get("qr_code")
    return request.data.get("qr_code")


# ============================================================================
# POINT D'ENTRÉE PRINCIPAL
# ============================================================================

class ScanQRCodeView(APIView):
    """
    POST /api/carnet/scan/
    Body: {"qr_code": "QR-XXX"}
    
    Retourne TOUT le dossier de la maman.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        qr_code = request.data.get("qr_code")
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current_pregnancy, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        pregnancies = mother.pregnancies.all()
        medical_histories = mother.medical_histories.all()
        
        data = {
            "mother": MotherSerializer(mother).data,
            "qr_code": qr_code,
            "has_health_record": hasattr(mother, "health_record"),
            "pregnancies": PregnancyListSerializer(pregnancies, many=True).data,
            "pregnancies_count": pregnancies.count(),
            "current_pregnancy": None,
            "medical_histories": MedicalHistorySerializer(medical_histories, many=True).data,
            "spouse_info": None,
        }
        
        if current_pregnancy:
            data["current_pregnancy"] = FullPregnancySerializer(current_pregnancy).data
        
        if hasattr(mother, "spouse_info"):
            data["spouse_info"] = SpouseInfoSerializer(mother.spouse_info).data
        
        return Response(data)


# ============================================================================
# GROSSESSES
# ============================================================================

class PregnancyView(APIView):
    """
    GET /api/carnet/pregnancies/?qr_code=QR-XXX
    POST /api/carnet/pregnancies/ {"qr_code": "QR-XXX", ...}
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        pregnancies = mother.pregnancies.all()
        return Response({
            "mother_name": mother.full_name,
            "qr_code": qr_code,
            "count": pregnancies.count(),
            "pregnancies": PregnancyListSerializer(pregnancies, many=True).data
        })

    def post(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        # Numéro automatique
        numero = mother.pregnancies.count() + 1
        
        data = request.data.copy()
        data["mother"] = mother.id
        
        serializer = PregnancyDetailSerializer(data=data)
        if serializer.is_valid():
            serializer.save(numero=numero, created_by=request.user)
            return Response({
                "message": f"Grossesse n°{numero} créée",
                "pregnancy": serializer.data
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class CurrentPregnancyView(APIView):
    """
    GET /api/carnet/current-pregnancy/?qr_code=QR-XXX
    PUT /api/carnet/current-pregnancy/ {"qr_code": "QR-XXX", ...}
    
    Accède à la grossesse EN COURS de la maman.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({
                "has_current_pregnancy": False,
                "message": "Aucune grossesse en cours. Créez-en une avec POST /api/carnet/pregnancies/"
            })
        
        return Response({
            "has_current_pregnancy": True,
            "pregnancy": FullPregnancySerializer(current).data
        })

    def put(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = PregnancyDetailSerializer(current, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ============================================================================
# ENFANTS (grossesse en cours)
# ============================================================================

class ChildView(APIView):
    """
    GET /api/carnet/children/?qr_code=QR-XXX
    POST /api/carnet/children/ {"qr_code": "QR-XXX", ...}
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        children = current.children.all()
        return Response({
            "pregnancy_numero": current.numero,
            "count": children.count(),
            "children": ChildSerializer(children, many=True).data
        })

    def post(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        data = request.data.copy()
        data['pregnancy'] = current.id
        
        serializer = ChildSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ============================================================================
# ANTÉCÉDENTS MÉDICAUX
# ============================================================================

class MedicalHistoryView(APIView):
    """
    GET /api/carnet/medical-history/?qr_code=QR-XXX
    POST /api/carnet/medical-history/ {"qr_code": "QR-XXX", ...}
    PUT /api/carnet/medical-history/ {"qr_code": "QR-XXX", "history_id": 1, ...}
    DELETE /api/carnet/medical-history/ {"qr_code": "QR-XXX", "history_id": 1}
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        histories = mother.medical_histories.all()
        
        type_filter = request.query_params.get("type")
        if type_filter:
            histories = histories.filter(type=type_filter)
        
        # Grouper par type
        grouped = {"medical": [], "chirurgical": [], "familial": [], "allergie": []}
        serialized = MedicalHistorySerializer(histories, many=True).data
        for h in serialized:
            if h['type'] in grouped:
                grouped[h['type']].append(h)
        
        return Response({
            "mother_name": mother.full_name,
            "qr_code": qr_code,
            "count": histories.count(),
            "grouped": grouped
        })

    def post(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        data = request.data.copy()
        data["mother"] = mother.id
        
        serializer = MedicalHistorySerializer(data=data)
        if serializer.is_valid():
            serializer.save(created_by=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request):
        qr_code = get_qr_from_request(request)
        history_id = request.data.get("history_id")
        if not qr_code or not history_id:
            return Response({"error": "QR code et history_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        history = get_object_or_404(MedicalHistory, id=history_id, mother=mother)
        serializer = MedicalHistorySerializer(history, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request):
        qr_code = get_qr_from_request(request)
        history_id = request.data.get("history_id")
        if not qr_code or not history_id:
            return Response({"error": "QR code et history_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        history = get_object_or_404(MedicalHistory, id=history_id, mother=mother)
        history.delete()
        return Response({"message": "Antécédent supprimé"})


# ============================================================================
# INFORMATIONS CONJOINT
# ============================================================================

class SpouseInfoView(APIView):
    """
    GET /api/carnet/spouse/?qr_code=QR-XXX
    POST /api/carnet/spouse/ {"qr_code": "QR-XXX", ...}
    PUT /api/carnet/spouse/ {"qr_code": "QR-XXX", ...}
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not hasattr(mother, "spouse_info"):
            return Response({"has_spouse_info": False, "message": "Aucune info conjoint"})
        
        return Response({
            "has_spouse_info": True,
            "spouse_info": SpouseInfoSerializer(mother.spouse_info).data
        })

    def post(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if hasattr(mother, "spouse_info"):
            return Response({"error": "Info conjoint existe déjà. Utilisez PUT."}, status=status.HTTP_400_BAD_REQUEST)
        
        data = request.data.copy()
        data["mother"] = mother.id
        
        serializer = SpouseInfoSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not hasattr(mother, "spouse_info"):
            return Response({"error": "Aucune info à modifier. Utilisez POST."}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = SpouseInfoSerializer(mother.spouse_info, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ============================================================================
# CONSULTATIONS PRÉNATALES (grossesse en cours)
# ============================================================================

class ConsultationView(APIView):
    """
    GET /api/carnet/consultations/?qr_code=QR-XXX
    POST /api/carnet/consultations/ {"qr_code": "QR-XXX", ...}
    PUT /api/carnet/consultations/ {"qr_code": "QR-XXX", "consultation_id": 1, ...}
    DELETE /api/carnet/consultations/ {"qr_code": "QR-XXX", "consultation_id": 1}
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        consultations = current.consultations.all()
        return Response({
            "pregnancy_numero": current.numero,
            "semaine_actuelle": current.semaine_actuelle,
            "count": consultations.count(),
            "consultations": PrenatalConsultationSerializer(consultations, many=True).data
        })

    def post(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        data = request.data.copy()
        data['pregnancy'] = current.id
        
        # Auto numéro CPN
        if 'cpn_number' not in data:
            data['cpn_number'] = current.consultations.count() + 1
        
        serializer = PrenatalConsultationSerializer(data=data)
        if serializer.is_valid():
            serializer.save(medecin=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request):
        qr_code = get_qr_from_request(request)
        consultation_id = request.data.get("consultation_id")
        if not qr_code or not consultation_id:
            return Response({"error": "QR code et consultation_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        consultation = get_object_or_404(PrenatalConsultation, id=consultation_id, pregnancy__mother=mother)
        serializer = PrenatalConsultationSerializer(consultation, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request):
        qr_code = get_qr_from_request(request)
        consultation_id = request.data.get("consultation_id")
        if not qr_code or not consultation_id:
            return Response({"error": "QR code et consultation_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        consultation = get_object_or_404(PrenatalConsultation, id=consultation_id, pregnancy__mother=mother)
        consultation.delete()
        return Response({"message": "Consultation supprimée"})


# ============================================================================
# VACCINATIONS (grossesse en cours)
# ============================================================================

class VaccinationView(APIView):
    """
    GET /api/carnet/vaccinations/?qr_code=QR-XXX
    POST /api/carnet/vaccinations/ {"qr_code": "QR-XXX", ...}
    PUT /api/carnet/vaccinations/ {"qr_code": "QR-XXX", "vaccination_id": 1, ...}
    DELETE /api/carnet/vaccinations/ {"qr_code": "QR-XXX", "vaccination_id": 1}
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        vaccinations = current.vaccinations.all()
        return Response({
            "pregnancy_numero": current.numero,
            "count": vaccinations.count(),
            "vaccinations": VaccinationSerializer(vaccinations, many=True).data
        })

    def post(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        data = request.data.copy()
        data['pregnancy'] = current.id
        
        serializer = VaccinationSerializer(data=data)
        if serializer.is_valid():
            serializer.save(medecin=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request):
        qr_code = get_qr_from_request(request)
        vaccination_id = request.data.get("vaccination_id")
        if not qr_code or not vaccination_id:
            return Response({"error": "QR code et vaccination_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        vaccination = get_object_or_404(Vaccination, id=vaccination_id, pregnancy__mother=mother)
        serializer = VaccinationSerializer(vaccination, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request):
        qr_code = get_qr_from_request(request)
        vaccination_id = request.data.get("vaccination_id")
        if not qr_code or not vaccination_id:
            return Response({"error": "QR code et vaccination_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        vaccination = get_object_or_404(Vaccination, id=vaccination_id, pregnancy__mother=mother)
        vaccination.delete()
        return Response({"message": "Vaccination supprimée"})


# ============================================================================
# EXAMENS MÉDICAUX (grossesse en cours)
# ============================================================================

class ExamView(APIView):
    """
    GET /api/carnet/exams/?qr_code=QR-XXX
    POST /api/carnet/exams/ {"qr_code": "QR-XXX", ...}
    PUT /api/carnet/exams/ {"qr_code": "QR-XXX", "exam_id": 1, ...}
    DELETE /api/carnet/exams/ {"qr_code": "QR-XXX", "exam_id": 1}
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        exams = current.exams.all()
        return Response({
            "pregnancy_numero": current.numero,
            "count": exams.count(),
            "exams": MedicalExamSerializer(exams, many=True).data
        })

    def post(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        data = request.data.copy()
        data['pregnancy'] = current.id
        
        serializer = MedicalExamSerializer(data=data)
        if serializer.is_valid():
            serializer.save(medecin=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request):
        qr_code = get_qr_from_request(request)
        exam_id = request.data.get("exam_id")
        if not qr_code or not exam_id:
            return Response({"error": "QR code et exam_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        exam = get_object_or_404(MedicalExam, id=exam_id, pregnancy__mother=mother)
        serializer = MedicalExamSerializer(exam, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request):
        qr_code = get_qr_from_request(request)
        exam_id = request.data.get("exam_id")
        if not qr_code or not exam_id:
            return Response({"error": "QR code et exam_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        exam = get_object_or_404(MedicalExam, id=exam_id, pregnancy__mother=mother)
        exam.delete()
        return Response({"message": "Examen supprimé"})


# ============================================================================
# TRAITEMENTS (grossesse en cours)
# ============================================================================

class TreatmentView(APIView):
    """Traitements - même logique que les autres."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        treatments = current.treatments.all()
        return Response({
            "pregnancy_numero": current.numero,
            "count": treatments.count(),
            "treatments": TreatmentSerializer(treatments, many=True).data
        })

    def post(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        data = request.data.copy()
        data['pregnancy'] = current.id
        
        serializer = TreatmentSerializer(data=data)
        if serializer.is_valid():
            serializer.save(prescrit_par=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ============================================================================
# ÉVOLUTION GROSSESSE
# ============================================================================

class EvolutionView(APIView):
    """Évolution de la grossesse."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        evolutions = current.evolutions.all()
        return Response({
            "pregnancy_numero": current.numero,
            "count": evolutions.count(),
            "evolutions": PregnancyEvolutionSerializer(evolutions, many=True).data
        })

    def post(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        data = request.data.copy()
        data['pregnancy'] = current.id
        
        serializer = PregnancyEvolutionSerializer(data=data)
        if serializer.is_valid():
            serializer.save(medecin=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ============================================================================
# PLAN D'ACCOUCHEMENT
# ============================================================================

class BirthPlanView(APIView):
    """Plan d'accouchement."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        if not hasattr(current, 'birth_plan'):
            return Response({"has_plan": False, "message": "Aucun plan d'accouchement"})
        
        return Response({
            "has_plan": True,
            "birth_plan": BirthPlanSerializer(current.birth_plan).data
        })

    def post(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        if hasattr(current, 'birth_plan'):
            return Response({"error": "Plan existe déjà. Utilisez PUT."}, status=status.HTTP_400_BAD_REQUEST)
        
        data = request.data.copy()
        data['pregnancy'] = current.id
        
        serializer = BirthPlanSerializer(data=data)
        if serializer.is_valid():
            serializer.save(created_by=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current or not hasattr(current, 'birth_plan'):
            return Response({"error": "Aucun plan à modifier"}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = BirthPlanSerializer(current.birth_plan, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ============================================================================
# RENDEZ-VOUS
# ============================================================================

class AppointmentView(APIView):
    """Rendez-vous."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        appointments = current.appointments.all()
        return Response({
            "pregnancy_numero": current.numero,
            "count": appointments.count(),
            "appointments": AppointmentSerializer(appointments, many=True).data
        })

    def post(self, request):
        qr_code = get_qr_from_request(request)
        if not qr_code:
            return Response({"error": "QR code requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, current, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        if not current:
            return Response({"error": "Aucune grossesse en cours"}, status=status.HTTP_404_NOT_FOUND)
        
        data = request.data.copy()
        data['pregnancy'] = current.id
        
        serializer = AppointmentSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request):
        qr_code = get_qr_from_request(request)
        appointment_id = request.data.get("appointment_id")
        if not qr_code or not appointment_id:
            return Response({"error": "QR code et appointment_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        appointment = get_object_or_404(Appointment, id=appointment_id, pregnancy__mother=mother)
        serializer = AppointmentSerializer(appointment, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request):
        qr_code = get_qr_from_request(request)
        appointment_id = request.data.get("appointment_id")
        if not qr_code or not appointment_id:
            return Response({"error": "QR code et appointment_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        mother, _, error = get_mother_by_qr(qr_code)
        if error:
            return Response(error, status=status.HTTP_404_NOT_FOUND)
        
        appointment = get_object_or_404(Appointment, id=appointment_id, pregnancy__mother=mother)
        appointment.delete()
        return Response({"message": "Rendez-vous supprimé"})
