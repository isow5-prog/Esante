from rest_framework import serializers

from .models import (
    HealthCenter, Mother, HealthRecord, PreventionMessage,
    Pregnancy, Child, MedicalHistory, SpouseInfo,
    PrenatalConsultation, Vaccination, MedicalExam,
    Treatment, PregnancyEvolution, BirthPlan, Appointment
)


class HealthCenterSerializer(serializers.ModelSerializer):
    mothers_count = serializers.SerializerMethodField()

    class Meta:
        model = HealthCenter
        fields = ["id", "name", "code", "city", "address", "mothers_count"]
        read_only_fields = ["id"]

    def get_mothers_count(self, obj):
        return obj.mothers.count()


class MotherSerializer(serializers.ModelSerializer):
    center = HealthCenterSerializer(read_only=True)
    center_id = serializers.PrimaryKeyRelatedField(
        source="center",
        queryset=HealthCenter.objects.all(),
        write_only=True,
        required=False,
        allow_null=True,
    )
    # Champs calculés pour le frontend
    qr_code = serializers.CharField(source="qr_card.code", read_only=True)
    qr_status = serializers.CharField(source="qr_card.status", read_only=True)
    has_record = serializers.SerializerMethodField()

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
            "qr_code",
            "qr_status",
            "center",
            "center_id",
            "has_record",
            "created_at",
        ]
        read_only_fields = ["id", "created_at", "qr_card", "qr_code", "qr_status", "has_record"]

    def get_has_record(self, obj):
        return hasattr(obj, 'health_record')


class HealthRecordSerializer(serializers.ModelSerializer):
    """Serializer pour le carnet de santé."""
    mother_name = serializers.CharField(source="mother.full_name", read_only=True)
    mother_qr_code = serializers.CharField(source="mother.qr_card.code", read_only=True)
    birth_center_name_display = serializers.SerializerMethodField()
    created_by_name = serializers.SerializerMethodField()

    class Meta:
        model = HealthRecord
        fields = [
            "id",
            "mother",
            "mother_name",
            "mother_qr_code",
            "father_name",
            "father_phone",
            "father_profession",
            "pere_carnet_center",
            "identification_code",
            "birth_center",
            "birth_center_name",
            "birth_center_name_display",
            "allocation_info",
            "created_by",
            "created_by_name",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_by", "created_at", "updated_at"]

    def get_birth_center_name_display(self, obj):
        if obj.birth_center:
            return obj.birth_center.name
        return obj.birth_center_name or ""

    def get_created_by_name(self, obj):
        if obj.created_by:
            return obj.created_by.get_full_name()
        return None


class AddRecordSerializer(serializers.Serializer):
    """
    Serializer pour ajouter un carnet à une mère existante.
    Reçoit le code QR et les informations du carnet.
    """
    code = serializers.CharField(help_text="Code QR de la mère")
    
    # Infos mère (mise à jour optionnelle)
    address = serializers.CharField(required=False, allow_blank=True)
    phone = serializers.CharField(required=False, allow_blank=True)
    birth_date = serializers.DateField(required=False)
    profession = serializers.CharField(required=False, allow_blank=True)
    
    # Infos père
    father_name = serializers.CharField(help_text="Prénom et nom du père")
    
    # Infos carnet
    pere_carnet_center = serializers.CharField(help_text="Nom du centre père-carnet CSD")
    identification_code = serializers.CharField(help_text="Code d'identification de la maison")
    mother_center_of_birth = serializers.CharField(required=False, allow_blank=True, help_text="Centre de naissance")
    allocation_info = serializers.CharField(required=False, allow_blank=True, help_text="Allocation")


class PreventionMessageSerializer(serializers.ModelSerializer):
    author_name = serializers.SerializerMethodField()
    category_display = serializers.CharField(source="get_category_display", read_only=True)
    status_display = serializers.CharField(source="get_status_display", read_only=True)
    target_display = serializers.CharField(source="get_target_display", read_only=True)

    class Meta:
        model = PreventionMessage
        fields = [
            "id",
            "title",
            "content",
            "category",
            "category_display",
            "status",
            "status_display",
            "target",
            "target_display",
            "author",
            "author_name",
            "scheduled_at",
            "published_at",
            "views_count",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "author", "views_count", "created_at", "updated_at", "published_at"]

    def get_author_name(self, obj):
        if obj.author:
            return obj.author.get_full_name()
        return None


# ============================================================================
# SERIALIZERS DU CARNET DE SANTÉ COMPLET
# ============================================================================

class ChildSerializer(serializers.ModelSerializer):
    """Serializer pour les enfants."""
    sexe_display = serializers.CharField(source="get_sexe_display", read_only=True)

    class Meta:
        model = Child
        fields = [
            "id", "pregnancy", "full_name", "sexe", "sexe_display",
            "birth_date", "birth_weight", "birth_height",
            "numero_dossier", "is_alive", "created_at"
        ]
        read_only_fields = ["id", "created_at"]


class PregnancyListSerializer(serializers.ModelSerializer):
    """Serializer simplifié pour la liste des grossesses."""
    mother_name = serializers.CharField(source="mother.full_name", read_only=True)
    status_display = serializers.CharField(source="get_status_display", read_only=True)
    children_count = serializers.SerializerMethodField()

    class Meta:
        model = Pregnancy
        fields = [
            "id", "mother", "mother_name", "numero", "status", "status_display",
            "date_derniere_regles", "date_accouchement_prevue",
            "semaine_actuelle", "children_count", "created_at"
        ]
        read_only_fields = ["id", "created_at", "semaine_actuelle"]

    def get_children_count(self, obj):
        return obj.children.count()


class PregnancyDetailSerializer(serializers.ModelSerializer):
    """Serializer complet pour le détail d'une grossesse."""
    mother_name = serializers.CharField(source="mother.full_name", read_only=True)
    mother_qr_code = serializers.CharField(source="mother.qr_card.code", read_only=True)
    status_display = serializers.CharField(source="get_status_display", read_only=True)
    lieu_accouchement_name = serializers.CharField(
        source="lieu_accouchement.name", read_only=True
    )
    children = ChildSerializer(many=True, read_only=True)
    consultations_count = serializers.SerializerMethodField()
    vaccinations_count = serializers.SerializerMethodField()

    class Meta:
        model = Pregnancy
        fields = [
            "id", "mother", "mother_name", "mother_qr_code", "numero",
            "status", "status_display",
            "date_derniere_regles", "date_accouchement_prevue", "date_accouchement_reel",
            "mode_accouchement", "lieu_accouchement", "lieu_accouchement_name",
            "semaine_actuelle", "children", "consultations_count", "vaccinations_count",
            "created_by", "created_at", "updated_at"
        ]
        read_only_fields = ["id", "created_by", "created_at", "updated_at", "semaine_actuelle"]

    def get_consultations_count(self, obj):
        return obj.consultations.filter(is_completed=True).count()

    def get_vaccinations_count(self, obj):
        return obj.vaccinations.filter(is_completed=True).count()


class MedicalHistorySerializer(serializers.ModelSerializer):
    """Serializer pour les antécédents médicaux."""
    type_display = serializers.CharField(source="get_type_display", read_only=True)

    class Meta:
        model = MedicalHistory
        fields = [
            "id", "mother", "type", "type_display", "title",
            "date_diagnostic", "details", "relation",
            "created_by", "created_at"
        ]
        read_only_fields = ["id", "created_by", "created_at"]


class SpouseInfoSerializer(serializers.ModelSerializer):
    """Serializer pour les informations du conjoint."""

    class Meta:
        model = SpouseInfo
        fields = [
            "id", "mother", "full_name", "birth_date", "blood_group",
            "medical_history", "allergies", "phone", "profession",
            "created_at", "updated_at"
        ]
        read_only_fields = ["id", "created_at", "updated_at"]


class PrenatalConsultationSerializer(serializers.ModelSerializer):
    """Serializer pour les consultations prénatales (CPN)."""
    medecin_name = serializers.SerializerMethodField()
    tension = serializers.CharField(read_only=True)

    class Meta:
        model = PrenatalConsultation
        fields = [
            "id", "pregnancy", "cpn_number", "date", "semaine",
            "poids", "tension_systolique", "tension_diastolique", "tension",
            "taille_uterine", "position_bebe", "battements_coeur",
            "observations", "prescriptions", "medecin", "medecin_name",
            "is_completed", "created_at", "updated_at"
        ]
        read_only_fields = ["id", "medecin", "created_at", "updated_at"]

    def get_medecin_name(self, obj):
        if obj.medecin:
            return obj.medecin.get_full_name()
        return None


class VaccinationSerializer(serializers.ModelSerializer):
    """Serializer pour les vaccinations."""
    lieu_name = serializers.CharField(source="lieu.name", read_only=True)
    medecin_name = serializers.SerializerMethodField()

    class Meta:
        model = Vaccination
        fields = [
            "id", "pregnancy", "nom", "description", "date", "semaine",
            "numero_lot", "lieu", "lieu_name", "medecin", "medecin_name",
            "is_completed", "created_at", "updated_at"
        ]
        read_only_fields = ["id", "medecin", "created_at", "updated_at"]

    def get_medecin_name(self, obj):
        if obj.medecin:
            return obj.medecin.get_full_name()
        return None


class MedicalExamSerializer(serializers.ModelSerializer):
    """Serializer pour les examens médicaux."""
    type_display = serializers.CharField(source="get_type_display", read_only=True)
    lieu_name = serializers.CharField(source="lieu.name", read_only=True)
    medecin_name = serializers.SerializerMethodField()

    class Meta:
        model = MedicalExam
        fields = [
            "id", "pregnancy", "type", "type_display", "nom", "date", "semaine",
            "resultats", "observations", "lieu", "lieu_name",
            "medecin", "medecin_name", "is_completed", "created_at"
        ]
        read_only_fields = ["id", "medecin", "created_at"]

    def get_medecin_name(self, obj):
        if obj.medecin:
            return obj.medecin.get_full_name()
        return None


class TreatmentSerializer(serializers.ModelSerializer):
    """Serializer pour les traitements/médicaments."""
    prescrit_par_name = serializers.SerializerMethodField()

    class Meta:
        model = Treatment
        fields = [
            "id", "pregnancy", "nom", "dosage", "frequence",
            "date_debut", "date_fin", "motif",
            "prescrit_par", "prescrit_par_name", "is_active", "created_at"
        ]
        read_only_fields = ["id", "prescrit_par", "created_at"]

    def get_prescrit_par_name(self, obj):
        if obj.prescrit_par:
            return obj.prescrit_par.get_full_name()
        return None


class PregnancyEvolutionSerializer(serializers.ModelSerializer):
    """Serializer pour l'évolution de la grossesse."""
    medecin_name = serializers.SerializerMethodField()

    class Meta:
        model = PregnancyEvolution
        fields = [
            "id", "pregnancy", "date", "semaine",
            "poids_maman", "tension", "poids_estime_bebe",
            "taille_femorale", "diametre_biparietal",
            "observations", "medecin", "medecin_name", "created_at"
        ]
        read_only_fields = ["id", "medecin", "created_at"]

    def get_medecin_name(self, obj):
        if obj.medecin:
            return obj.medecin.get_full_name()
        return None


class BirthPlanSerializer(serializers.ModelSerializer):
    """Serializer pour le plan d'accouchement."""
    lieu_souhaite_name = serializers.CharField(
        source="lieu_souhaite.name", read_only=True
    )

    class Meta:
        model = BirthPlan
        fields = [
            "id", "pregnancy", "lieu_souhaite", "lieu_souhaite_name",
            "accompagnant", "preferences_douleur", "positions_preferees",
            "peau_a_peau", "allaitement", "notes_particulieres",
            "created_by", "created_at", "updated_at"
        ]
        read_only_fields = ["id", "created_by", "created_at", "updated_at"]


class AppointmentSerializer(serializers.ModelSerializer):
    """Serializer pour les rendez-vous."""
    type_display = serializers.CharField(source="get_type_display", read_only=True)
    status_display = serializers.CharField(source="get_status_display", read_only=True)
    lieu_name = serializers.CharField(source="lieu.name", read_only=True)
    medecin_name = serializers.SerializerMethodField()

    class Meta:
        model = Appointment
        fields = [
            "id", "pregnancy", "type", "type_display", "title",
            "date", "heure", "lieu", "lieu_name",
            "medecin", "medecin_name", "status", "status_display",
            "notes", "rappel_envoye", "created_at"
        ]
        read_only_fields = ["id", "created_at"]

    def get_medecin_name(self, obj):
        if obj.medecin:
            return obj.medecin.get_full_name()
        return None


# ============================================================================
# SERIALIZERS POUR LA VUE COMPLÈTE DU CARNET
# ============================================================================

class FullHealthRecordSerializer(serializers.ModelSerializer):
    """
    Serializer complet pour afficher tout le carnet de santé.
    Utilisé côté mobile pour la maman.
    """
    # Infos de base
    mother_name = serializers.CharField(source="mother.full_name", read_only=True)
    mother_phone = serializers.CharField(source="mother.phone", read_only=True)
    mother_address = serializers.CharField(source="mother.address", read_only=True)
    mother_birth_date = serializers.DateField(source="mother.birth_date", read_only=True)
    mother_profession = serializers.CharField(source="mother.profession", read_only=True)
    qr_code = serializers.CharField(source="mother.qr_card.code", read_only=True)
    center_name = serializers.CharField(source="mother.center.name", read_only=True)
    
    # Antécédents
    medical_histories = serializers.SerializerMethodField()
    spouse_info = serializers.SerializerMethodField()
    
    # Grossesses
    pregnancies = serializers.SerializerMethodField()
    current_pregnancy = serializers.SerializerMethodField()

    class Meta:
        model = HealthRecord
        fields = [
            "id",
            # Mère
            "mother_name", "mother_phone", "mother_address",
            "mother_birth_date", "mother_profession",
            "qr_code", "center_name",
            # Père
            "father_name", "father_phone", "father_profession",
            # Carnet
            "pere_carnet_center", "identification_code",
            "allocation_info",
            # Relations
            "medical_histories", "spouse_info",
            "pregnancies", "current_pregnancy",
            "created_at", "updated_at"
        ]

    def get_medical_histories(self, obj):
        histories = obj.mother.medical_histories.all()
        return MedicalHistorySerializer(histories, many=True).data

    def get_spouse_info(self, obj):
        if hasattr(obj.mother, 'spouse_info'):
            return SpouseInfoSerializer(obj.mother.spouse_info).data
        return None

    def get_pregnancies(self, obj):
        pregnancies = obj.mother.pregnancies.all()
        return PregnancyListSerializer(pregnancies, many=True).data

    def get_current_pregnancy(self, obj):
        pregnancy = obj.mother.pregnancies.filter(status=Pregnancy.Status.EN_COURS).first()
        if pregnancy:
            return PregnancyDetailSerializer(pregnancy).data
        return None


class FullPregnancySerializer(serializers.ModelSerializer):
    """
    Serializer complet pour afficher tous les détails d'une grossesse.
    """
    mother_name = serializers.CharField(source="mother.full_name", read_only=True)
    status_display = serializers.CharField(source="get_status_display", read_only=True)
    
    # Toutes les sections
    children = ChildSerializer(many=True, read_only=True)
    consultations = PrenatalConsultationSerializer(many=True, read_only=True)
    vaccinations = VaccinationSerializer(many=True, read_only=True)
    exams = MedicalExamSerializer(many=True, read_only=True)
    treatments = TreatmentSerializer(many=True, read_only=True)
    evolutions = PregnancyEvolutionSerializer(many=True, read_only=True)
    appointments = AppointmentSerializer(many=True, read_only=True)
    birth_plan = BirthPlanSerializer(read_only=True)

    class Meta:
        model = Pregnancy
        fields = [
            "id", "mother", "mother_name", "numero",
            "status", "status_display",
            "date_derniere_regles", "date_accouchement_prevue", "date_accouchement_reel",
            "mode_accouchement", "lieu_accouchement", "semaine_actuelle",
            # Sections
            "children", "consultations", "vaccinations",
            "exams", "treatments", "evolutions", "appointments", "birth_plan",
            "created_at", "updated_at"
        ]


