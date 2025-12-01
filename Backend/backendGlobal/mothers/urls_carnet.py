"""
URLs pour la gestion du carnet de santé.

TOUT passe par le QR code !
La sage-femme scanne et peut tout faire.
"""
from django.urls import path
from .views_carnet import (
    ScanQRCodeView,
    PregnancyView,
    CurrentPregnancyView,
    ChildView,
    MedicalHistoryView,
    SpouseInfoView,
    ConsultationView,
    VaccinationView,
    ExamView,
    TreatmentView,
    EvolutionView,
    BirthPlanView,
    AppointmentView,
)

urlpatterns = [
    # Point d'entrée : Scanner le QR code
    path("scan/", ScanQRCodeView.as_view(), name="carnet-scan"),
    
    # Grossesses
    path("pregnancies/", PregnancyView.as_view(), name="pregnancy-list"),
    path("current-pregnancy/", CurrentPregnancyView.as_view(), name="current-pregnancy"),
    
    # Enfants (grossesse en cours)
    path("children/", ChildView.as_view(), name="child-list"),
    
    # Antécédents médicaux
    path("medical-history/", MedicalHistoryView.as_view(), name="medical-history"),
    
    # Conjoint
    path("spouse/", SpouseInfoView.as_view(), name="spouse-info"),
    
    # Consultations prénatales (grossesse en cours)
    path("consultations/", ConsultationView.as_view(), name="consultation-list"),
    
    # Vaccinations (grossesse en cours)
    path("vaccinations/", VaccinationView.as_view(), name="vaccination-list"),
    
    # Examens médicaux (grossesse en cours)
    path("exams/", ExamView.as_view(), name="exam-list"),
    
    # Traitements (grossesse en cours)
    path("treatments/", TreatmentView.as_view(), name="treatment-list"),
    
    # Évolution (grossesse en cours)
    path("evolutions/", EvolutionView.as_view(), name="evolution-list"),
    
    # Plan d'accouchement (grossesse en cours)
    path("birth-plan/", BirthPlanView.as_view(), name="birth-plan"),
    
    # Rendez-vous (grossesse en cours)
    path("appointments/", AppointmentView.as_view(), name="appointment-list"),
]
