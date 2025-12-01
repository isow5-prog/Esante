from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from accounts.permissions import IsHealthWorker
from .models import QRCodeCard
from .serializers import QRCodeCardSerializer
from mothers.models import Mother
from mothers.serializers import MotherSerializer


class QRCodeCardListCreateView(generics.ListCreateAPIView):
    queryset = QRCodeCard.objects.all()
    serializer_class = QRCodeCardSerializer
    permission_classes = [IsAuthenticated]

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context["request"] = self.request
        return context


class QRCodeValidationView(APIView):
    """
    Valide une carte QR et crée la mère associée si nécessaire.

    Payload attendu (côté front ValidateCard):
    {
        "code": "QR-XXXXXX",
        "full_name": "...",
        "address": "...",
        "phone": "...",
        "birth_date": "YYYY-MM-DD",
        "profession": "..."
    }
    """

    # Seuls les agents de santé peuvent valider une carte
    permission_classes = [IsAuthenticated, IsHealthWorker]

    def post(self, request):
        code = request.data.get("code")
        if not code:
            return Response(
                {"detail": "Le code du QR est requis."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            qr_card = QRCodeCard.objects.get(code=code)
        except QRCodeCard.DoesNotExist:
            return Response(
                {"detail": "QR code introuvable."},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Création ou mise à jour de la mère liée à cette carte
        mother_data = {
            "full_name": request.data.get("full_name"),
            "address": request.data.get("address"),
            "phone": request.data.get("phone"),
            "birth_date": request.data.get("birth_date"),
            "profession": request.data.get("profession"),
        }

        if not all(mother_data.values()):
            return Response(
                {
                    "detail": "Les champs full_name, address, phone, birth_date et profession sont requis."
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        mother, created = Mother.objects.update_or_create(
            qr_card=qr_card,
            defaults=mother_data,
        )

        # Marquer la carte comme validée/active
        qr_card.status = QRCodeCard.Status.VALIDATED
        qr_card.save(update_fields=["status", "updated_at"])

        serializer = MotherSerializer(mother)
        return Response(serializer.data, status=status.HTTP_200_OK)

