import io
import qrcode
from django.core.files.base import ContentFile
from django.db import models
from django.utils import timezone
from django.utils.crypto import get_random_string


class QRCodeCard(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending", "En attente"
        VALIDATED = "validated", "Validé"

    code = models.CharField(max_length=64, unique=True, blank=True)
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PENDING,
    )
    # Champs historiques pour le centre (conservés pour compatibilité)
    center_name = models.CharField(max_length=255, blank=True)
    center_city = models.CharField(max_length=255, blank=True)
    image = models.ImageField(upload_to="qr_codes/", blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-created_at",)

    def __str__(self):
        return f"{self.code} ({self.get_status_display()})"

    @staticmethod
    def generate_unique_code(prefix: str = "QR") -> str:
        while True:
            candidate = f"{prefix}-{get_random_string(8).upper()}"
            if not QRCodeCard.objects.filter(code=candidate).exists():
                return candidate

    def generate_qr_image(self) -> None:
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_M,
            box_size=10,
            border=4,
        )
        qr.add_data(self.code)
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white")

        buffer = io.BytesIO()
        img.save(buffer, format="PNG")
        file_name = f"{self.code}.png".replace(" ", "_")
        self.image.save(file_name, ContentFile(buffer.getvalue()), save=False)

    def save(self, *args, **kwargs):
        if not self.code:
            self.code = self.generate_unique_code()

        needs_image = not self.image
        super().save(*args, **kwargs)

        if needs_image:
            self.generate_qr_image()
            super().save(update_fields=["image"])

