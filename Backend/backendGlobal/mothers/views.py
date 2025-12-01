from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Q, Count, Sum
from django.db.models.functions import TruncMonth
from django.utils import timezone
from datetime import timedelta

from .models import (
    HealthCenter, Mother, HealthRecord, PreventionMessage,
    Child, Pregnancy, PrenatalConsultation, Vaccination
)
from .serializers import (
    HealthCenterSerializer, MotherSerializer, HealthRecordSerializer,
    AddRecordSerializer, PreventionMessageSerializer
)
from accounts.permissions import IsMinistry, IsHealthWorker
from qr_codes.models import QRCodeCard


class HealthCenterListCreateView(generics.ListCreateAPIView):
    """
    API pour lister et créer des centres de santé.

    GET  /api/centers/ - Liste tous les centres
    POST /api/centers/ - Créer un nouveau centre
    """

    queryset = HealthCenter.objects.all()
    serializer_class = HealthCenterSerializer
    permission_classes = [permissions.IsAuthenticated]


class RecentMothersListView(generics.ListAPIView):
    """
    Liste des dernières mères enregistrées.

    GET /api/mothers/recent/ - 20 dernières mères
    """

    queryset = Mother.objects.select_related("qr_card", "center").all()[:20]
    serializer_class = MotherSerializer
    permission_classes = [permissions.IsAuthenticated]


class MotherListView(APIView):
    """
    Liste complète des mères avec filtres et pagination.

    GET /api/mothers/
        Paramètres de requête :
        - status : filtrer par statut QR (validated, pending)
        - center : filtrer par ID du centre
        - search : rechercher par nom ou code QR
        - page : numéro de page (défaut: 1)
        - page_size : taille de page (défaut: 20, max: 100)
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        mothers = Mother.objects.select_related("qr_card", "center").all()

        # Filtre par statut QR
        qr_status = request.query_params.get('status')
        if qr_status:
            mothers = mothers.filter(qr_card__status=qr_status)

        # Filtre par centre
        center_id = request.query_params.get('center')
        if center_id:
            mothers = mothers.filter(center_id=center_id)

        # Recherche
        search = request.query_params.get('search')
        if search:
            mothers = mothers.filter(
                Q(full_name__icontains=search) |
                Q(qr_card__code__icontains=search)
            )

        # Pagination
        page = int(request.query_params.get('page', 1))
        page_size = min(int(request.query_params.get('page_size', 20)), 100)
        start = (page - 1) * page_size
        end = start + page_size

        total_count = mothers.count()
        mothers_page = mothers[start:end]

        serializer = MotherSerializer(mothers_page, many=True)

        return Response({
            "mothers": serializer.data,
            "pagination": {
                "total": total_count,
                "page": page,
                "page_size": page_size,
                "total_pages": (total_count + page_size - 1) // page_size
            },
            "stats": {
                "total": Mother.objects.count(),
                "validated": Mother.objects.filter(qr_card__status="validated").count(),
                "pending": Mother.objects.filter(qr_card__status="pending").count(),
            }
        })


class MotherDetailView(APIView):
    """
    Détail d'une mère.

    GET /api/mothers/<id>/
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        try:
            mother = Mother.objects.select_related("qr_card", "center").get(pk=pk)
        except Mother.DoesNotExist:
            return Response(
                {"detail": "Mère non trouvée."},
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = MotherSerializer(mother)
        return Response(serializer.data)


class AddRecordView(APIView):
    """
    Ajouter un carnet de santé à une mère existante.

    POST /api/mothers/add-record/

    L'agent de santé scanne le QR code d'une mère déjà validée,
    puis remplit les informations du carnet (père, centre, etc.).

    Payload attendu :
    {
        "code": "QR-XXXXXXXX",
        "father_name": "Prénom Nom du père",
        "pere_carnet_center": "Nom du centre père-carnet CSD",
        "identification_code": "Code d'identification",
        "mother_center_of_birth": "Centre de naissance (optionnel)",
        "allocation_info": "Info allocation (optionnel)",
        "address": "Nouvelle adresse (optionnel)",
        "phone": "Nouveau téléphone (optionnel)",
        "birth_date": "YYYY-MM-DD (optionnel)",
        "profession": "Nouvelle profession (optionnel)"
    }
    """

    permission_classes = [permissions.IsAuthenticated, IsHealthWorker]

    def post(self, request):
        serializer = AddRecordSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data
        code = data.get('code')

        # Trouver la carte QR
        try:
            qr_card = QRCodeCard.objects.get(code=code)
        except QRCodeCard.DoesNotExist:
            return Response(
                {"detail": "Code QR introuvable."},
                status=status.HTTP_404_NOT_FOUND
            )

        # Vérifier que la carte est validée
        if qr_card.status != QRCodeCard.Status.VALIDATED:
            return Response(
                {"detail": "Cette carte n'est pas encore validée. Veuillez d'abord valider la carte."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Trouver la mère associée
        try:
            mother = Mother.objects.get(qr_card=qr_card)
        except Mother.DoesNotExist:
            return Response(
                {"detail": "Aucune mère associée à ce code QR."},
                status=status.HTTP_404_NOT_FOUND
            )

        # Vérifier si un carnet existe déjà
        if hasattr(mother, 'health_record'):
            return Response(
                {"detail": "Un carnet existe déjà pour cette mère."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Mise à jour des infos de la mère si fournies
        if data.get('address'):
            mother.address = data['address']
        if data.get('phone'):
            mother.phone = data['phone']
        if data.get('birth_date'):
            mother.birth_date = data['birth_date']
        if data.get('profession'):
            mother.profession = data['profession']
        mother.save()

        # Trouver le centre de naissance si fourni
        birth_center = None
        birth_center_name = data.get('mother_center_of_birth', '')
        if birth_center_name:
            birth_center = HealthCenter.objects.filter(name__iexact=birth_center_name).first()

        # Créer le carnet de santé
        health_record = HealthRecord.objects.create(
            mother=mother,
            father_name=data['father_name'],
            pere_carnet_center=data['pere_carnet_center'],
            identification_code=data['identification_code'],
            birth_center=birth_center,
            birth_center_name=birth_center_name if not birth_center else '',
            allocation_info=data.get('allocation_info', ''),
            created_by=request.user
        )

        return Response({
            "detail": "Carnet ajouté avec succès.",
            "record": HealthRecordSerializer(health_record).data,
            "mother": MotherSerializer(mother).data
        }, status=status.HTTP_201_CREATED)


class StatsOverviewView(APIView):
    """
    Statistiques générales pour le tableau de bord.

    GET /api/stats/overview/
    
    Retourne :
    - mothers : Nombre total de mères inscrites
    - consultations : Nombre total de CPN effectuées
    - children_followed : Nombre total d'enfants enregistrés
    - vaccinations : Nombre total de vaccinations effectuées
    - filles : Nombre de bébés filles
    - garcons : Nombre de bébés garçons
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        mothers_count = Mother.objects.count()
        consultations_count = PrenatalConsultation.objects.filter(is_completed=True).count()
        children_count = Child.objects.count()
        vaccinations_count = Vaccination.objects.filter(is_completed=True).count()
        
        # Stats par sexe
        filles_count = Child.objects.filter(sexe='F').count()
        garcons_count = Child.objects.filter(sexe='M').count()

        return Response({
            "mothers": mothers_count,
            "consultations": consultations_count,
            "children_followed": children_count,
            "vaccinations": vaccinations_count,
            "filles": filles_count,
            "garcons": garcons_count,
        })


class StatsDetailedView(APIView):
    """
    Statistiques détaillées pour le ministère.

    GET /api/stats/detailed/
        Paramètres de requête :
        - period : week, month, quarter, year (défaut: year)

    Retourne :
    - Statistiques globales (mothers, consultations, children, vaccinations, filles, garcons)
    - Évolution mensuelle (mothers, consultations, children, vaccinations, filles, garcons)
    - Statistiques par centre
    - Statistiques par sexe (filles/garçons)
    - Activité récente
    """

    permission_classes = [IsMinistry]

    def get(self, request):
        period = request.query_params.get('period', 'year')

        # Calculer la date de début selon la période
        now = timezone.now()
        if period == 'week':
            start_date = now - timedelta(days=7)
        elif period == 'month':
            start_date = now - timedelta(days=30)
        elif period == 'quarter':
            start_date = now - timedelta(days=90)
        else:  # year
            start_date = now - timedelta(days=365)

        # Statistiques globales
        total_mothers = Mother.objects.count()
        total_consultations = PrenatalConsultation.objects.filter(is_completed=True).count()
        total_children = Child.objects.count()
        total_vaccinations = Vaccination.objects.filter(is_completed=True).count()
        total_filles = Child.objects.filter(sexe='F').count()
        total_garcons = Child.objects.filter(sexe='M').count()
        
        period_mothers = Mother.objects.filter(created_at__gte=start_date).count()
        previous_period_mothers = Mother.objects.filter(
            created_at__gte=start_date - (now - start_date),
            created_at__lt=start_date
        ).count()

        # Calcul du pourcentage de croissance
        if previous_period_mothers > 0:
            growth = ((period_mothers - previous_period_mothers) / previous_period_mothers) * 100
        else:
            growth = 100 if period_mothers > 0 else 0

        # Évolution mensuelle (12 derniers mois) - MÈRES
        monthly_mothers = (
            Mother.objects
            .filter(created_at__gte=now - timedelta(days=365))
            .annotate(month=TruncMonth('created_at'))
            .values('month')
            .annotate(count=Count('id'))
            .order_by('month')
        )
        
        # Évolution mensuelle - CPN
        monthly_cpn = (
            PrenatalConsultation.objects
            .filter(is_completed=True, date__gte=(now - timedelta(days=365)).date())
            .annotate(month=TruncMonth('date'))
            .values('month')
            .annotate(count=Count('id'))
            .order_by('month')
        )
        
        # Évolution mensuelle - Enfants
        monthly_children = (
            Child.objects
            .filter(birth_date__gte=(now - timedelta(days=365)).date())
            .annotate(month=TruncMonth('birth_date'))
            .values('month')
            .annotate(count=Count('id'))
            .order_by('month')
        )
        
        # Évolution mensuelle - Vaccinations
        monthly_vaccinations = (
            Vaccination.objects
            .filter(is_completed=True, date__gte=(now - timedelta(days=365)).date())
            .annotate(month=TruncMonth('date'))
            .values('month')
            .annotate(count=Count('id'))
            .order_by('month')
        )
        
        # Évolution mensuelle - Filles
        monthly_filles = (
            Child.objects
            .filter(sexe='F', birth_date__gte=(now - timedelta(days=365)).date())
            .annotate(month=TruncMonth('birth_date'))
            .values('month')
            .annotate(count=Count('id'))
            .order_by('month')
        )
        
        # Évolution mensuelle - Garçons
        monthly_garcons = (
            Child.objects
            .filter(sexe='M', birth_date__gte=(now - timedelta(days=365)).date())
            .annotate(month=TruncMonth('birth_date'))
            .values('month')
            .annotate(count=Count('id'))
            .order_by('month')
        )
        
        # Convertir en dictionnaires pour fusion
        def to_dict(queryset):
            return {item['month'].strftime("%b"): item['count'] for item in queryset if item['month']}
        
        mothers_dict = to_dict(monthly_mothers)
        cpn_dict = to_dict(monthly_cpn)
        children_dict = to_dict(monthly_children)
        vaccinations_dict = to_dict(monthly_vaccinations)
        filles_dict = to_dict(monthly_filles)
        garcons_dict = to_dict(monthly_garcons)
        
        # Fusionner tous les mois
        all_months = ["Jan", "Fév", "Mar", "Avr", "Mai", "Jun", "Jul", "Aoû", "Sep", "Oct", "Nov", "Déc"]
        monthly_stats = []
        for month in all_months:
            monthly_stats.append({
                "month": month,
                "mothers": mothers_dict.get(month, 0),
                "consultations": cpn_dict.get(month, 0),
                "children": children_dict.get(month, 0),
                "vaccinations": vaccinations_dict.get(month, 0),
                "filles": filles_dict.get(month, 0),
                "garcons": garcons_dict.get(month, 0),
            })

        # Statistiques par centre
        centers_stats = []
        for center in HealthCenter.objects.all():
            center_mothers = Mother.objects.filter(center=center)
            center_period = center_mothers.filter(created_at__gte=start_date).count()
            center_previous = center_mothers.filter(
                created_at__gte=start_date - (now - start_date),
                created_at__lt=start_date
            ).count()
            
            # Récupérer les grossesses des mères de ce centre
            center_pregnancies = Pregnancy.objects.filter(mother__center=center)
            center_consultations = PrenatalConsultation.objects.filter(
                pregnancy__mother__center=center, is_completed=True
            ).count()
            center_children = Child.objects.filter(pregnancy__mother__center=center).count()
            center_vaccinations = Vaccination.objects.filter(
                pregnancy__mother__center=center, is_completed=True
            ).count()

            if center_previous > 0:
                center_growth = int(((center_period - center_previous) / center_previous) * 100)
            else:
                center_growth = 100 if center_period > 0 else 0

            centers_stats.append({
                "id": center.id,
                "name": center.name,
                "city": center.city,
                "mothers": center_mothers.count(),
                "consultations": center_consultations,
                "children": center_children,
                "vaccinations": center_vaccinations,
                "growth": center_growth
            })
        
        # Statistiques par sexe (pour le pie chart)
        gender_stats = {
            "filles": total_filles,
            "garcons": total_garcons,
            "total": total_children,
            "pourcentage_filles": round((total_filles / total_children * 100) if total_children > 0 else 0, 1),
            "pourcentage_garcons": round((total_garcons / total_children * 100) if total_children > 0 else 0, 1),
        }

        # Activité récente
        recent_activity = []
        recent_mothers = Mother.objects.select_related("center").order_by('-created_at')[:5]
        for mother in recent_mothers:
            time_diff = now - mother.created_at
            if time_diff.seconds < 3600:
                time_str = f"Il y a {time_diff.seconds // 60} min"
            elif time_diff.days == 0:
                time_str = f"Il y a {time_diff.seconds // 3600}h"
            else:
                time_str = f"Il y a {time_diff.days} jour(s)"

            recent_activity.append({
                "type": "mother",
                "message": f"Nouvelle mère inscrite à {mother.center.name if mother.center else 'N/A'}",
                "time": time_str
            })

        return Response({
            "global": {
                "mothers": total_mothers,
                "consultations": total_consultations,
                "children_followed": total_children,
                "vaccinations": total_vaccinations,
                "filles": total_filles,
                "garcons": total_garcons,
                "centers": HealthCenter.objects.count(),
                "growth": round(growth, 1)
            },
            "monthly": monthly_stats,
            "gender": gender_stats,
            "centers": centers_stats,
            "recent_activity": recent_activity
        })


# ==================== MESSAGES DE PRÉVENTION ====================

class MessageListCreateView(APIView):
    """
    Liste et création des messages de prévention.

    GET /api/messages/
        Paramètres de requête :
        - status : filtrer par statut (draft, published, scheduled)
        - category : filtrer par catégorie
        - search : rechercher par titre ou contenu

    POST /api/messages/ - Créer un nouveau message
    """

    permission_classes = [IsMinistry]

    def get(self, request):
        messages = PreventionMessage.objects.all().order_by('-created_at')

        # Filtre par statut
        msg_status = request.query_params.get('status')
        if msg_status:
            messages = messages.filter(status=msg_status)

        # Filtre par catégorie
        category = request.query_params.get('category')
        if category:
            messages = messages.filter(category=category)

        # Recherche
        search = request.query_params.get('search')
        if search:
            messages = messages.filter(
                Q(title__icontains=search) |
                Q(content__icontains=search)
            )

        serializer = PreventionMessageSerializer(messages, many=True)

        # Statistiques
        stats = {
            "total": PreventionMessage.objects.count(),
            "published": PreventionMessage.objects.filter(status="published").count(),
            "draft": PreventionMessage.objects.filter(status="draft").count(),
            "scheduled": PreventionMessage.objects.filter(status="scheduled").count(),
            "total_views": sum(m.views_count for m in PreventionMessage.objects.all()),
        }

        return Response({
            "messages": serializer.data,
            "stats": stats
        })

    def post(self, request):
        serializer = PreventionMessageSerializer(data=request.data)
        if serializer.is_valid():
            message = serializer.save(author=request.user)

            # Publier immédiatement si le statut est "published"
            if message.status == PreventionMessage.Status.PUBLISHED:
                message.published_at = timezone.now()
                message.save()

            return Response(
                PreventionMessageSerializer(message).data,
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class MessageDetailView(APIView):
    """
    Détail, mise à jour et suppression d'un message.

    GET /api/messages/<id>/
    PATCH /api/messages/<id>/
    DELETE /api/messages/<id>/
    """

    permission_classes = [IsMinistry]

    def get_object(self, pk):
        try:
            return PreventionMessage.objects.get(pk=pk)
        except PreventionMessage.DoesNotExist:
            return None

    def get(self, request, pk):
        message = self.get_object(pk)
        if not message:
            return Response(
                {"detail": "Message non trouvé."},
                status=status.HTTP_404_NOT_FOUND
            )

        # Incrémenter le compteur de vues
        message.views_count += 1
        message.save(update_fields=['views_count'])

        serializer = PreventionMessageSerializer(message)
        return Response(serializer.data)

    def patch(self, request, pk):
        message = self.get_object(pk)
        if not message:
            return Response(
                {"detail": "Message non trouvé."},
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = PreventionMessageSerializer(message, data=request.data, partial=True)
        if serializer.is_valid():
            updated_message = serializer.save()

            # Publier si le statut passe à "published"
            if updated_message.status == PreventionMessage.Status.PUBLISHED and not updated_message.published_at:
                updated_message.published_at = timezone.now()
                updated_message.save()

            return Response(PreventionMessageSerializer(updated_message).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        message = self.get_object(pk)
        if not message:
            return Response(
                {"detail": "Message non trouvé."},
                status=status.HTTP_404_NOT_FOUND
            )

        message.delete()
        return Response(
            {"detail": "Message supprimé avec succès."},
            status=status.HTTP_200_OK
        )


class MessagePublishView(APIView):
    """
    Publier un message.

    POST /api/messages/<id>/publish/
    """

    permission_classes = [IsMinistry]

    def post(self, request, pk):
        try:
            message = PreventionMessage.objects.get(pk=pk)
        except PreventionMessage.DoesNotExist:
            return Response(
                {"detail": "Message non trouvé."},
                status=status.HTTP_404_NOT_FOUND
            )

        message.publish()
        return Response(PreventionMessageSerializer(message).data)



