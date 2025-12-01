from django.urls import path
from .views import (
    QRAuthView,
    MotherProfileView,
    MotherMessagesView,
    MotherHealthRecordView,
    VerifyQRCodeView,
    # Nouveaux endpoints carnet complet
    FullHealthRecordView,
    PregnancyDetailMobileView,
    ConsultationsMobileView,
    VaccinationsMobileView,
    AppointmentsMobileView,
    MedicalHistoryMobileView,
)

urlpatterns = [
    # =====================
    # AUTHENTIFICATION
    # =====================
    path("auth/qr-login/", QRAuthView.as_view(), name="mobile-qr-login"),
    path("verify-qr/", VerifyQRCodeView.as_view(), name="mobile-verify-qr"),
    
    # =====================
    # PROFIL
    # =====================
    path("profile/", MotherProfileView.as_view(), name="mobile-profile"),
    
    # =====================
    # CARNET DE SANTÉ
    # =====================
    # Carnet basique (ancien)
    path("health-record/", MotherHealthRecordView.as_view(), name="mobile-health-record"),
    
    # Carnet complet (nouveau)
    path("full-health-record/", FullHealthRecordView.as_view(), name="mobile-full-health-record"),
    
    # Détail d'une grossesse
    path("pregnancies/<int:pk>/", PregnancyDetailMobileView.as_view(), name="mobile-pregnancy-detail"),
    
    # Consultations prénatales
    path("consultations/", ConsultationsMobileView.as_view(), name="mobile-consultations"),
    
    # Vaccinations
    path("vaccinations/", VaccinationsMobileView.as_view(), name="mobile-vaccinations"),
    
    # Rendez-vous
    path("appointments/", AppointmentsMobileView.as_view(), name="mobile-appointments"),
    
    # Antécédents médicaux
    path("medical-history/", MedicalHistoryMobileView.as_view(), name="mobile-medical-history"),
    
    # =====================
    # MESSAGES
    # =====================
    path("messages/", MotherMessagesView.as_view(), name="mobile-messages"),
]

