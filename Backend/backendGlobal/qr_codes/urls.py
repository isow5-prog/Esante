from django.urls import path
from . import views


app_name = "qr_codes"

urlpatterns = [
    path("qr-cards/", views.QRCodeCardListCreateView.as_view(), name="qr-card-list"),
    path(
        "qr-cards/validate/",
        views.QRCodeValidationView.as_view(),
        name="qr-card-validate",
    ),
]



