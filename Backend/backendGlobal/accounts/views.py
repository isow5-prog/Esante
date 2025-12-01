from rest_framework import status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from django.contrib.auth import get_user_model
from django.db.models import Q
from .serializers import UserSerializer, UserCreateSerializer, CustomTokenObtainPairSerializer
from .permissions import IsMinistry

User = get_user_model()


class HealthWorkerLoginView(TokenObtainPairView):
    """
    Vue personnalisée pour la connexion des agents de santé.
    Utilise le badge_id et le mot de passe pour l'authentification.
    """
    serializer_class = CustomTokenObtainPairSerializer

    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)

        # Vérifier si l'authentification a réussi
        if response.status_code == 200 and 'user' in response.data:
            user_data = response.data['user']

            # Vérifier si l'utilisateur est un agent de santé
            user = User.objects.filter(badge_id=user_data.get('badge_id')).first()
            if user and user.role != 'HEALTH_WORKER':
                return Response(
                    {"detail": "Accès réservé aux agents de santé."},
                    status=status.HTTP_403_FORBIDDEN
                )

        return response


class UserProfileView(APIView):
    """
    Vue pour récupérer et mettre à jour le profil de l'utilisateur connecté.
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    def patch(self, request):
        user = request.user
        serializer = UserSerializer(user, data=request.data, partial=True)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserListCreateView(APIView):
    """
    Liste et création des utilisateurs (accessible uniquement par le ministère).

    GET /api/users/ - Liste tous les utilisateurs avec filtres optionnels
        Paramètres de requête :
        - role : filtrer par rôle (MINISTRY, HEALTH_WORKER)
        - search : rechercher par nom, email ou badge_id
        - is_active : filtrer par statut (true/false)

    POST /api/users/ - Créer un nouvel utilisateur
    """
    permission_classes = [IsMinistry]

    def get(self, request):
        users = User.objects.all().order_by('-date_joined')

        # Filtre par rôle
        role = request.query_params.get('role')
        if role:
            users = users.filter(role=role)

        # Filtre par statut actif
        is_active = request.query_params.get('is_active')
        if is_active is not None:
            users = users.filter(is_active=is_active.lower() == 'true')

        # Recherche
        search = request.query_params.get('search')
        if search:
            users = users.filter(
                Q(first_name__icontains=search) |
                Q(last_name__icontains=search) |
                Q(email__icontains=search) |
                Q(badge_id__icontains=search)
            )

        serializer = UserSerializer(users, many=True)

        # Statistiques
        stats = {
            "total": User.objects.count(),
            "ministry": User.objects.filter(role='MINISTRY').count(),
            "health_workers": User.objects.filter(role='HEALTH_WORKER').count(),
            "active": User.objects.filter(is_active=True).count(),
        }

        return Response({
            "users": serializer.data,
            "stats": stats
        })

    def post(self, request):
        serializer = UserCreateSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(
                UserSerializer(user).data,
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserDetailView(APIView):
    """
    Détail, mise à jour et suppression d'un utilisateur.

    GET /api/users/<id>/ - Détail d'un utilisateur
    PATCH /api/users/<id>/ - Mise à jour partielle
    DELETE /api/users/<id>/ - Désactiver un utilisateur
    """
    permission_classes = [IsMinistry]

    def get_object(self, pk):
        try:
            return User.objects.get(pk=pk)
        except User.DoesNotExist:
            return None

    def get(self, request, pk):
        user = self.get_object(pk)
        if not user:
            return Response(
                {"detail": "Utilisateur non trouvé."},
                status=status.HTTP_404_NOT_FOUND
            )
        serializer = UserSerializer(user)
        return Response(serializer.data)

    def patch(self, request, pk):
        user = self.get_object(pk)
        if not user:
            return Response(
                {"detail": "Utilisateur non trouvé."},
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = UserSerializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        user = self.get_object(pk)
        if not user:
            return Response(
                {"detail": "Utilisateur non trouvé."},
                status=status.HTTP_404_NOT_FOUND
            )

        # Désactiver plutôt que supprimer
        user.is_active = False
        user.save()
        return Response(
            {"detail": "Utilisateur désactivé avec succès."},
            status=status.HTTP_200_OK
        )


# Garder l'ancienne vue pour compatibilité (deprecated)
class UserListView(APIView):
    """
    [DEPRECATED] Utiliser UserListCreateView à la place.
    """
    permission_classes = [IsMinistry]

    def get(self, request):
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)
