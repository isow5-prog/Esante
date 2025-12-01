from rest_framework import serializers
from .models import QRCodeCard


class QRCodeCardSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    mother_name = serializers.SerializerMethodField()
    mother_phone = serializers.SerializerMethodField()
    mother_id = serializers.SerializerMethodField()

    class Meta:
        model = QRCodeCard
        fields = [
            "id",
            "code",
            "status",
            "center_name",
            "center_city",
            "image_url",
            "created_at",
            "mother_id",
            "mother_name",
            "mother_phone",
        ]
        read_only_fields = ["id", "image_url", "created_at"]
        extra_kwargs = {
            "code": {"required": False},
        }

    def create(self, validated_data):
        if not validated_data.get("code"):
            validated_data["code"] = QRCodeCard.generate_unique_code()
        return super().create(validated_data)

    def get_image_url(self, obj: QRCodeCard) -> str | None:
        request = self.context.get("request")
        if obj.image and request:
            return request.build_absolute_uri(obj.image.url)
        if obj.image:
            return obj.image.url
        return None

    def get_mother_id(self, obj: QRCodeCard):
        """Retourne l'ID de la maman si associée."""
        if hasattr(obj, "mother"):
            return obj.mother.id
        return None

    def get_mother_name(self, obj: QRCodeCard) -> str | None:
        """Retourne le nom de la maman si associée."""
        if hasattr(obj, "mother"):
            return obj.mother.full_name
        return None

    def get_mother_phone(self, obj: QRCodeCard) -> str | None:
        """Retourne le téléphone de la maman si associée."""
        if hasattr(obj, "mother"):
            return obj.mother.phone
        return None

