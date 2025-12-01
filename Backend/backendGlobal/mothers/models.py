from django.db import models
from django.utils import timezone
from django.conf import settings

from qr_codes.models import QRCodeCard


class HealthCenter(models.Model):
    """
    Centre de santé officiel.

    Ce modèle remplace les champs textuels center_name / center_city
    et pourra être relié aux utilisateurs et aux mères.
    """

    name = models.CharField(max_length=255)
    code = models.CharField(max_length=32, unique=True)
    city = models.CharField(max_length=255)
    address = models.CharField(max_length=255, blank=True)

    class Meta:
        ordering = ("name",)

    def __str__(self) -> str:
        return f"{self.name} ({self.city})"


class Mother(models.Model):
    """
    Représente une mère associée à un QR code unique.

    Une carte QR (QRCodeCard) ne peut être liée qu'à une seule mère,
    ce qui correspond à ton scénario : une carte unique par maman.
    """

    qr_card = models.OneToOneField(
        QRCodeCard,
        on_delete=models.PROTECT,
        related_name="mother",
        help_text="Carte QR utilisée par cette mère",
    )
    full_name = models.CharField(max_length=255)
    address = models.CharField(max_length=255)
    phone = models.CharField(max_length=32)
    birth_date = models.DateField()
    profession = models.CharField(max_length=255)

    center = models.ForeignKey(
        HealthCenter,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="mothers",
        help_text="Centre principal de suivi de la mère",
    )

    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-created_at",)

    def __str__(self) -> str:
        return f"{self.full_name} - {self.qr_card.code}"


class HealthRecord(models.Model):
    """
    Carnet de santé d'une mère.

    Contient les informations supplémentaires ajoutées par l'agent de santé
    après la validation de la carte QR.
    """

    mother = models.OneToOneField(
        Mother,
        on_delete=models.CASCADE,
        related_name="health_record",
        help_text="Mère associée à ce carnet"
    )

    # Informations du père
    father_name = models.CharField(
        max_length=255,
        verbose_name="Nom du père",
        help_text="Prénom et nom du père"
    )
    father_phone = models.CharField(
        max_length=32,
        blank=True,
        verbose_name="Téléphone du père"
    )
    father_profession = models.CharField(
        max_length=255,
        blank=True,
        verbose_name="Profession du père"
    )

    # Informations du carnet
    pere_carnet_center = models.CharField(
        max_length=255,
        verbose_name="Centre père-carnet CSD",
        help_text="Nom du centre père-carnet CSD"
    )
    identification_code = models.CharField(
        max_length=100,
        verbose_name="Code d'identification",
        help_text="Le code de l'identification de la maison"
    )

    # Centre de naissance
    birth_center = models.ForeignKey(
        HealthCenter,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="birth_records",
        verbose_name="Centre de naissance",
        help_text="Centre de santé où la mère a accouché (optionnel)"
    )
    birth_center_name = models.CharField(
        max_length=255,
        blank=True,
        verbose_name="Nom du centre de naissance",
        help_text="Si le centre n'est pas dans la liste"
    )

    # Allocation
    allocation_info = models.CharField(
        max_length=255,
        blank=True,
        verbose_name="Information d'allocation",
        help_text="Ils allocation l'femele"
    )

    # Agent qui a créé le carnet
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name="created_records",
        verbose_name="Créé par"
    )

    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-created_at",)
        verbose_name = "Carnet de santé"
        verbose_name_plural = "Carnets de santé"

    def __str__(self) -> str:
        return f"Carnet de {self.mother.full_name}"


class PreventionMessage(models.Model):
    """
    Messages de prévention envoyés par le ministère.

    Ces messages peuvent être destinés à tous, aux mères uniquement,
    ou aux agents de santé.
    """

    class Category(models.TextChoices):
        VACCINATION = "vaccination", "Vaccination"
        PRENATAL = "prenatal", "Prénatal"
        NUTRITION = "nutrition", "Nutrition"
        INFO = "info", "Information"
        URGENCE = "urgence", "Urgence"

    class Status(models.TextChoices):
        DRAFT = "draft", "Brouillon"
        PUBLISHED = "published", "Publié"
        SCHEDULED = "scheduled", "Programmé"

    class Target(models.TextChoices):
        ALL = "all", "Tous"
        MOTHERS = "mothers", "Mères uniquement"
        AGENTS = "agents", "Agents de santé"

    title = models.CharField(max_length=255)
    content = models.TextField()
    category = models.CharField(
        max_length=20,
        choices=Category.choices,
        default=Category.INFO
    )
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.DRAFT
    )
    target = models.CharField(
        max_length=20,
        choices=Target.choices,
        default=Target.ALL
    )

    # Auteur du message
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name="messages"
    )

    # Date de publication (pour les messages programmés)
    scheduled_at = models.DateTimeField(null=True, blank=True)
    published_at = models.DateTimeField(null=True, blank=True)

    # Statistiques
    views_count = models.PositiveIntegerField(default=0)

    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-created_at",)

    def __str__(self) -> str:
        return f"{self.title} ({self.get_status_display()})"

    def publish(self):
        """Publie le message immédiatement."""
        self.status = self.Status.PUBLISHED
        self.published_at = timezone.now()
        self.save()


# ============================================================================
# MODÈLES DU CARNET DE SANTÉ COMPLET
# ============================================================================

class Pregnancy(models.Model):
    """
    Représente une grossesse d'une mère.
    Une mère peut avoir plusieurs grossesses (carnets).
    """

    class Status(models.TextChoices):
        EN_COURS = "en_cours", "En cours"
        TERMINE = "termine", "Terminé"
        INTERROMPU = "interrompu", "Interrompu"

    mother = models.ForeignKey(
        Mother,
        on_delete=models.CASCADE,
        related_name="pregnancies",
        help_text="Mère associée à cette grossesse"
    )
    numero = models.PositiveIntegerField(
        verbose_name="Numéro de grossesse",
        help_text="1ère grossesse = 1, 2ème = 2, etc."
    )
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.EN_COURS
    )
    
    # Dates importantes
    date_derniere_regles = models.DateField(
        null=True, blank=True,
        verbose_name="Date des dernières règles"
    )
    date_accouchement_prevue = models.DateField(
        null=True, blank=True,
        verbose_name="Date prévue d'accouchement"
    )
    date_accouchement_reel = models.DateField(
        null=True, blank=True,
        verbose_name="Date réelle d'accouchement"
    )
    
    # Informations sur l'accouchement
    mode_accouchement = models.CharField(
        max_length=50,
        blank=True,
        verbose_name="Mode d'accouchement",
        help_text="Voie basse, Césarienne, etc."
    )
    lieu_accouchement = models.ForeignKey(
        HealthCenter,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name="accouchements",
        verbose_name="Lieu d'accouchement"
    )
    
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name="created_pregnancies"
    )
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-numero",)
        unique_together = ("mother", "numero")
        verbose_name = "Grossesse"
        verbose_name_plural = "Grossesses"

    def __str__(self):
        return f"Grossesse n°{self.numero} de {self.mother.full_name}"

    @property
    def semaine_actuelle(self):
        """Calcule la semaine de grossesse actuelle."""
        if not self.date_derniere_regles:
            return None
        from datetime import date
        jours = (date.today() - self.date_derniere_regles).days
        return jours // 7


class Child(models.Model):
    """
    Enfant né d'une grossesse.
    """

    class Sexe(models.TextChoices):
        MASCULIN = "M", "Masculin"
        FEMININ = "F", "Féminin"

    pregnancy = models.ForeignKey(
        Pregnancy,
        on_delete=models.CASCADE,
        related_name="children",
        help_text="Grossesse associée"
    )
    full_name = models.CharField(max_length=255, verbose_name="Nom complet")
    sexe = models.CharField(max_length=1, choices=Sexe.choices)
    birth_date = models.DateField(verbose_name="Date de naissance")
    birth_weight = models.DecimalField(
        max_digits=4, decimal_places=2,
        null=True, blank=True,
        verbose_name="Poids à la naissance (kg)"
    )
    birth_height = models.DecimalField(
        max_digits=4, decimal_places=1,
        null=True, blank=True,
        verbose_name="Taille à la naissance (cm)"
    )
    numero_dossier = models.CharField(
        max_length=50, blank=True,
        verbose_name="Numéro de dossier"
    )
    is_alive = models.BooleanField(default=True, verbose_name="Vivant")
    
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-birth_date",)
        verbose_name = "Enfant"
        verbose_name_plural = "Enfants"

    def __str__(self):
        return f"{self.full_name} ({self.get_sexe_display()})"


class MedicalHistory(models.Model):
    """
    Antécédents médicaux, chirurgicaux ou familiaux.
    """

    class Type(models.TextChoices):
        MEDICAL = "medical", "Médical"
        CHIRURGICAL = "chirurgical", "Chirurgical"
        FAMILIAL = "familial", "Familial"
        ALLERGIE = "allergie", "Allergie"

    mother = models.ForeignKey(
        Mother,
        on_delete=models.CASCADE,
        related_name="medical_histories"
    )
    type = models.CharField(max_length=20, choices=Type.choices)
    title = models.CharField(
        max_length=255,
        verbose_name="Titre/Type",
        help_text="Ex: Hypertension, Césarienne, Diabète"
    )
    date_diagnostic = models.CharField(
        max_length=100, blank=True,
        verbose_name="Date/Période",
        help_text="Ex: Diagnostiqué en 2019, Mai 2015"
    )
    details = models.TextField(
        blank=True,
        verbose_name="Détails",
        help_text="Description détaillée"
    )
    relation = models.CharField(
        max_length=100, blank=True,
        verbose_name="Relation familiale",
        help_text="Pour les antécédents familiaux: Mère, Père, etc."
    )
    
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True
    )
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-created_at",)
        verbose_name = "Antécédent médical"
        verbose_name_plural = "Antécédents médicaux"

    def __str__(self):
        return f"{self.get_type_display()}: {self.title}"


class SpouseInfo(models.Model):
    """
    Informations sur le conjoint (pour les antécédents).
    """

    mother = models.OneToOneField(
        Mother,
        on_delete=models.CASCADE,
        related_name="spouse_info"
    )
    full_name = models.CharField(max_length=255, verbose_name="Nom complet")
    birth_date = models.DateField(null=True, blank=True, verbose_name="Date de naissance")
    blood_group = models.CharField(
        max_length=10, blank=True,
        verbose_name="Groupe sanguin",
        help_text="Ex: O+, A-, B+, AB-"
    )
    medical_history = models.TextField(
        blank=True,
        verbose_name="Antécédents médicaux"
    )
    allergies = models.TextField(
        blank=True,
        verbose_name="Allergies"
    )
    phone = models.CharField(max_length=32, blank=True)
    profession = models.CharField(max_length=255, blank=True)
    
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Information conjoint"
        verbose_name_plural = "Informations conjoints"

    def __str__(self):
        return f"Conjoint de {self.mother.full_name}: {self.full_name}"


class PrenatalConsultation(models.Model):
    """
    Consultation prénatale (CPN).
    """

    pregnancy = models.ForeignKey(
        Pregnancy,
        on_delete=models.CASCADE,
        related_name="consultations"
    )
    cpn_number = models.PositiveIntegerField(
        verbose_name="Numéro CPN",
        help_text="CPN 1, CPN 2, etc."
    )
    date = models.DateField(verbose_name="Date de consultation")
    semaine = models.PositiveIntegerField(
        verbose_name="Semaine de grossesse"
    )
    
    # Mesures
    poids = models.DecimalField(
        max_digits=5, decimal_places=2,
        null=True, blank=True,
        verbose_name="Poids (kg)"
    )
    tension_systolique = models.PositiveIntegerField(
        null=True, blank=True,
        verbose_name="Tension systolique"
    )
    tension_diastolique = models.PositiveIntegerField(
        null=True, blank=True,
        verbose_name="Tension diastolique"
    )
    taille_uterine = models.DecimalField(
        max_digits=4, decimal_places=1,
        null=True, blank=True,
        verbose_name="Taille utérine (cm)"
    )
    position_bebe = models.CharField(
        max_length=50, blank=True,
        verbose_name="Position du bébé",
        help_text="Céphalique, Siège, Transverse"
    )
    battements_coeur = models.PositiveIntegerField(
        null=True, blank=True,
        verbose_name="Battements cœur fœtal (bpm)"
    )
    
    # Observations
    observations = models.TextField(blank=True)
    prescriptions = models.TextField(
        blank=True,
        verbose_name="Prescriptions"
    )
    
    # Médecin/Sage-femme
    medecin = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name="consultations_effectuees"
    )
    is_completed = models.BooleanField(
        default=False,
        verbose_name="Effectuée"
    )
    
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("cpn_number",)
        unique_together = ("pregnancy", "cpn_number")
        verbose_name = "Consultation prénatale"
        verbose_name_plural = "Consultations prénatales"

    def __str__(self):
        return f"CPN {self.cpn_number} - {self.pregnancy}"

    @property
    def tension(self):
        if self.tension_systolique and self.tension_diastolique:
            return f"{self.tension_systolique}/{self.tension_diastolique}"
        return None


class Vaccination(models.Model):
    """
    Vaccinations pendant la grossesse.
    """

    pregnancy = models.ForeignKey(
        Pregnancy,
        on_delete=models.CASCADE,
        related_name="vaccinations"
    )
    nom = models.CharField(
        max_length=100,
        verbose_name="Nom du vaccin"
    )
    description = models.CharField(
        max_length=255, blank=True,
        verbose_name="Description"
    )
    date = models.DateField(verbose_name="Date de vaccination")
    semaine = models.PositiveIntegerField(
        null=True, blank=True,
        verbose_name="Semaine de grossesse"
    )
    numero_lot = models.CharField(
        max_length=50, blank=True,
        verbose_name="Numéro de lot"
    )
    lieu = models.ForeignKey(
        HealthCenter,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name="vaccinations"
    )
    medecin = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name="vaccinations_effectuees"
    )
    is_completed = models.BooleanField(
        default=False,
        verbose_name="Effectuée"
    )
    
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("date",)
        verbose_name = "Vaccination"
        verbose_name_plural = "Vaccinations"

    def __str__(self):
        status = "✓" if self.is_completed else "○"
        return f"{status} {self.nom} - {self.date}"


class MedicalExam(models.Model):
    """
    Examens complémentaires (échographies, analyses, etc.).
    """

    class Type(models.TextChoices):
        ECHOGRAPHIE = "echographie", "Échographie"
        ANALYSE_SANG = "analyse_sang", "Analyse de sang"
        ANALYSE_URINE = "analyse_urine", "Analyse d'urine"
        AUTRE = "autre", "Autre"

    pregnancy = models.ForeignKey(
        Pregnancy,
        on_delete=models.CASCADE,
        related_name="exams"
    )
    type = models.CharField(max_length=20, choices=Type.choices)
    nom = models.CharField(
        max_length=255,
        verbose_name="Nom de l'examen"
    )
    date = models.DateField(verbose_name="Date de l'examen")
    semaine = models.PositiveIntegerField(
        null=True, blank=True,
        verbose_name="Semaine de grossesse"
    )
    resultats = models.TextField(
        blank=True,
        verbose_name="Résultats"
    )
    observations = models.TextField(blank=True)
    lieu = models.ForeignKey(
        HealthCenter,
        on_delete=models.SET_NULL,
        null=True, blank=True
    )
    medecin = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True
    )
    is_completed = models.BooleanField(default=False)
    
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("date",)
        verbose_name = "Examen médical"
        verbose_name_plural = "Examens médicaux"

    def __str__(self):
        return f"{self.get_type_display()}: {self.nom}"


class Treatment(models.Model):
    """
    Traitements et médicaments prescrits.
    """

    pregnancy = models.ForeignKey(
        Pregnancy,
        on_delete=models.CASCADE,
        related_name="treatments"
    )
    nom = models.CharField(
        max_length=255,
        verbose_name="Nom du médicament"
    )
    dosage = models.CharField(
        max_length=100, blank=True,
        verbose_name="Dosage"
    )
    frequence = models.CharField(
        max_length=100, blank=True,
        verbose_name="Fréquence",
        help_text="Ex: 2x par jour, 1x par semaine"
    )
    date_debut = models.DateField(verbose_name="Date de début")
    date_fin = models.DateField(
        null=True, blank=True,
        verbose_name="Date de fin"
    )
    motif = models.TextField(
        blank=True,
        verbose_name="Motif de prescription"
    )
    prescrit_par = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name="En cours"
    )
    
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-date_debut",)
        verbose_name = "Traitement"
        verbose_name_plural = "Traitements"

    def __str__(self):
        return f"{self.nom} - {self.dosage}"


class PregnancyEvolution(models.Model):
    """
    Suivi de l'évolution de la grossesse (courbe de croissance).
    """

    pregnancy = models.ForeignKey(
        Pregnancy,
        on_delete=models.CASCADE,
        related_name="evolutions"
    )
    date = models.DateField()
    semaine = models.PositiveIntegerField(verbose_name="Semaine")
    
    # Mesures maman
    poids_maman = models.DecimalField(
        max_digits=5, decimal_places=2,
        null=True, blank=True,
        verbose_name="Poids maman (kg)"
    )
    tension = models.CharField(
        max_length=20, blank=True,
        verbose_name="Tension artérielle"
    )
    
    # Mesures bébé
    poids_estime_bebe = models.DecimalField(
        max_digits=5, decimal_places=2,
        null=True, blank=True,
        verbose_name="Poids estimé bébé (kg)"
    )
    taille_femorale = models.DecimalField(
        max_digits=4, decimal_places=1,
        null=True, blank=True,
        verbose_name="Longueur fémorale (mm)"
    )
    diametre_biparietal = models.DecimalField(
        max_digits=4, decimal_places=1,
        null=True, blank=True,
        verbose_name="Diamètre bipariétal (mm)"
    )
    
    observations = models.TextField(blank=True)
    medecin = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True
    )
    
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("semaine",)
        verbose_name = "Évolution grossesse"
        verbose_name_plural = "Évolutions grossesse"

    def __str__(self):
        return f"Semaine {self.semaine} - {self.pregnancy}"


class BirthPlan(models.Model):
    """
    Plan d'accouchement.
    """

    pregnancy = models.OneToOneField(
        Pregnancy,
        on_delete=models.CASCADE,
        related_name="birth_plan"
    )
    
    # Préférences générales
    lieu_souhaite = models.ForeignKey(
        HealthCenter,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        verbose_name="Lieu d'accouchement souhaité"
    )
    accompagnant = models.CharField(
        max_length=255, blank=True,
        verbose_name="Personne accompagnante",
        help_text="Qui sera présent lors de l'accouchement"
    )
    
    # Préférences pour le travail
    preferences_douleur = models.TextField(
        blank=True,
        verbose_name="Gestion de la douleur",
        help_text="Péridurale, méthodes naturelles, etc."
    )
    positions_preferees = models.TextField(
        blank=True,
        verbose_name="Positions préférées"
    )
    
    # Après l'accouchement
    peau_a_peau = models.BooleanField(
        default=True,
        verbose_name="Peau à peau immédiat"
    )
    allaitement = models.BooleanField(
        default=True,
        verbose_name="Allaitement maternel"
    )
    
    # Notes
    notes_particulieres = models.TextField(
        blank=True,
        verbose_name="Notes particulières"
    )
    
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True
    )
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Plan d'accouchement"
        verbose_name_plural = "Plans d'accouchement"

    def __str__(self):
        return f"Plan d'accouchement - {self.pregnancy}"


class Appointment(models.Model):
    """
    Rendez-vous médicaux.
    """

    class Type(models.TextChoices):
        CPN = "cpn", "Consultation prénatale"
        VACCINATION = "vaccination", "Vaccination"
        ECHOGRAPHIE = "echographie", "Échographie"
        ANALYSE = "analyse", "Analyse"
        AUTRE = "autre", "Autre"

    class Status(models.TextChoices):
        PLANIFIE = "planifie", "Planifié"
        CONFIRME = "confirme", "Confirmé"
        EFFECTUE = "effectue", "Effectué"
        ANNULE = "annule", "Annulé"
        MANQUE = "manque", "Manqué"

    pregnancy = models.ForeignKey(
        Pregnancy,
        on_delete=models.CASCADE,
        related_name="appointments"
    )
    type = models.CharField(max_length=20, choices=Type.choices)
    title = models.CharField(max_length=255, verbose_name="Titre")
    date = models.DateField()
    heure = models.TimeField(null=True, blank=True)
    lieu = models.ForeignKey(
        HealthCenter,
        on_delete=models.SET_NULL,
        null=True, blank=True
    )
    medecin = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True, blank=True
    )
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PLANIFIE
    )
    notes = models.TextField(blank=True)
    rappel_envoye = models.BooleanField(
        default=False,
        verbose_name="Rappel envoyé"
    )
    
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("date", "heure")
        verbose_name = "Rendez-vous"
        verbose_name_plural = "Rendez-vous"

    def __str__(self):
        return f"{self.title} - {self.date}"


