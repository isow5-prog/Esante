from rest_framework import serializers
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    """Sérialiseur pour le modèle User"""
    full_name = serializers.SerializerMethodField()
    center = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 'badge_id', 'first_name', 'last_name', 'full_name',
            'email', 'role', 'phone', 'health_center_id', 'center',
            'is_active', 'date_joined'
        ]
        read_only_fields = ['id', 'badge_id', 'date_joined']

    def get_full_name(self, obj):
        return obj.get_full_name()

    def get_center(self, obj):
        # Retourne le nom du centre si disponible
        if obj.health_center_id:
            from mothers.models import HealthCenter
            try:
                center = HealthCenter.objects.get(id=obj.health_center_id)
                return {"id": center.id, "name": center.name, "city": center.city}
            except HealthCenter.DoesNotExist:
                return None
        return None


class UserCreateSerializer(serializers.ModelSerializer):
    """Sérialiseur pour la création d'un utilisateur"""
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = [
            'first_name', 'last_name', 'email', 'phone',
            'role', 'health_center_id', 'password'
        ]

    def create(self, validated_data):
        password = validated_data.pop('password')
        # Le badge_id est généré automatiquement dans le modèle
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Sérialiseur personnalisé pour la génération de token JWT"""
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)

        # Ajouter des claims personnalisés
        token['role'] = user.role
        token['full_name'] = user.get_full_name()
        if user.health_center_id:
            token['health_center_id'] = user.health_center_id

        return token

    def validate(self, attrs):
        # La validation de base crée le token
        data = super().validate(attrs)

        # Ajouter des données utilisateur supplémentaires à la réponse
        refresh = self.get_token(self.user)
        data['refresh'] = str(refresh)
        data['access'] = str(refresh.access_token)

        # Ajouter des informations utilisateur
        data['user'] = {
            'id': self.user.id,
            'badge_id': self.user.badge_id,
            'full_name': self.user.get_full_name(),
            'role': self.user.role,
            'email': self.user.email,
        }

        if self.user.health_center_id:
            data['user']['health_center_id'] = self.user.health_center_id

        return data
