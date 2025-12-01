from rest_framework import serializers
from mothers.models import Mother, HealthRecord, HealthCenter, PreventionMessage
from qr_codes.models import QRCodeCard


class HealthCenterSimpleSerializer(serializers.ModelSerializer):
    """Serializer simplifié pour les centres de santé."""
    
    class Meta:
        model = HealthCenter
        fields = ["id", "name", "city", "address"]


class QRCardMobileSerializer(serializers.ModelSerializer):
    """Serializer pour la carte QR dans l'app mobile."""
    
    image_url = serializers.SerializerMethodField()
    
    class Meta:
        model = QRCodeCard
        fields = ["code", "status", "image_url", "created_at"]
    
    def get_image_url(self, obj):
        if obj.image:
            request = self.context.get("request")
            if request:
                return request.build_absolute_uri(obj.image.url)
            return obj.image.url
        return None


class HealthRecordMobileSerializer(serializers.ModelSerializer):
    """Serializer pour le carnet de santé dans l'app mobile."""
    
    birth_center_detail = HealthCenterSimpleSerializer(source="birth_center", read_only=True)
    created_by_name = serializers.CharField(source="created_by.get_full_name", read_only=True)
    
    class Meta:
        model = HealthRecord
        fields = [
            "id",
            "father_name",
            "father_phone",
            "father_profession",
            "pere_carnet_center",
            "identification_code",
            "birth_center_detail",
            "birth_center_name",
            "allocation_info",
            "created_by_name",
            "created_at",
            "updated_at",
        ]


class MotherProfileSerializer(serializers.ModelSerializer):
    """
    Serializer complet du profil de la maman.
    
    Inclut toutes les informations :
    - Données personnelles (Mother)
    - Carte QR
    - Centre de suivi
    - Carnet de santé (HealthRecord)
    """
    
    qr_card = QRCardMobileSerializer(read_only=True)
    center = HealthCenterSimpleSerializer(read_only=True)
    health_record = HealthRecordMobileSerializer(read_only=True)
    
    class Meta:
        model = Mother
        fields = [
            "id",
            "full_name",
            "address",
            "phone",
            "birth_date",
            "profession",
            "qr_card",
            "center",
            "health_record",
            "created_at",
            "updated_at",
        ]


class QRAuthSerializer(serializers.Serializer):
    """Serializer pour l'authentification par QR code."""
    
    qr_code = serializers.CharField(
        max_length=64,
        help_text="Code QR scanné par la maman"
    )
    
    def validate_qr_code(self, value):
        """Vérifie que le QR code existe et est validé."""
        try:
            qr_card = QRCodeCard.objects.get(code=value)
        except QRCodeCard.DoesNotExist:
            raise serializers.ValidationError("Code QR invalide ou inexistant.")
        
        if qr_card.status != QRCodeCard.Status.VALIDATED:
            raise serializers.ValidationError(
                "Cette carte n'a pas encore été activée par un agent de santé."
            )
        
        # Vérifie qu'une mère est associée à cette carte
        if not hasattr(qr_card, "mother"):
            raise serializers.ValidationError(
                "Aucune mère n'est associée à cette carte."
            )
        
        return value
    
    def get_mother(self):
        """Retourne la mère associée au QR code validé."""
        qr_code = self.validated_data["qr_code"]
        qr_card = QRCodeCard.objects.get(code=qr_code)
        return qr_card.mother


class PreventionMessageMobileSerializer(serializers.ModelSerializer):
    """Serializer pour les messages de prévention dans l'app mobile."""
    
    category_display = serializers.CharField(source="get_category_display", read_only=True)
    
    class Meta:
        model = PreventionMessage
        fields = [
            "id",
            "title",
            "content",
            "category",
            "category_display",
            "published_at",
        ]


class MotherUpdateSerializer(serializers.ModelSerializer):
    """Serializer pour la mise à jour du profil maman (champs limités)."""
    
    class Meta:
        model = Mother
        fields = ["phone", "address"]

