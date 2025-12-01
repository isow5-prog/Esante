from django.contrib.auth.models import AbstractUser, BaseUserManager, Group, Permission
from django.db import models
from django.utils.crypto import get_random_string
from django.utils.translation import gettext_lazy as _

class UserManager(BaseUserManager):
    """Gestionnaire personnalisé pour le modèle User."""
    
    def create_user(self, badge_id, email, password=None, **extra_fields):
        """Crée et enregistre un utilisateur avec le badge_id et l'email donnés."""
        if not badge_id:
            raise ValueError('Le badge_id est obligatoire')
        if not email:
            raise ValueError('L\'email est obligatoire')
            
        email = self.normalize_email(email)
        user = self.model(badge_id=badge_id, email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user
    
    def create_superuser(self, badge_id, email, password=None, **extra_fields):
        """Crée et enregistre un superutilisateur avec les droits d'administration."""
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        
        if extra_fields.get('is_staff') is not True:
            raise ValueError('Le superutilisateur doit avoir is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Le superutilisateur doit avoir is_superuser=True.')
            
        return self.create_user(badge_id, email, password, **extra_fields)

class User(AbstractUser):
    """
    Modèle d'utilisateur personnalisé pour l'application E-sante SN.
    Utilise badge_id comme identifiant de connexion au lieu de username.
    """
    # Utilisation du gestionnaire personnalisé
    objects = UserManager()
    
    # Suppression du champ username
    username = None
    
    class Role(models.TextChoices):
        MINISTRY = 'MINISTRY', _('Ministère de la Santé')
        HEALTH_WORKER = 'HEALTH_WORKER', _('Agent de Santé')
    
    # Champs d'authentification
    USERNAME_FIELD = 'badge_id'
    EMAIL_FIELD = 'email'
    REQUIRED_FIELDS = ['email', 'first_name', 'last_name', 'phone', 'role']
    
    # Champs personnalisés
    role = models.CharField(
        _('rôle'),
        max_length=20,
        choices=Role.choices,
        default=Role.HEALTH_WORKER,
        help_text=_('Rôle de l\'utilisateur dans le système')
    )
    
    badge_id = models.CharField(
        _('numéro de badge'),
        max_length=50,
        unique=True,
        help_text=_('Identifiant unique du badge pour la connexion')
    )
    
    phone = models.CharField(
        _('numéro de téléphone'),
        max_length=20,
        help_text=_('Numéro de téléphone de l\'utilisateur')
    )
    
    # Champ de relation avec le centre de santé (mis en commentaire pour le moment)
    # health_center = models.ForeignKey(
    #     'health_centers.HealthCenter',
    #     on_delete=models.SET_NULL,
    #     null=True,
    #     blank=True,
    #     verbose_name=_('centre de santé'),
    #     help_text=_('Centre de santé auquel est affecté l\'agent')
    # )
    
    # Champ temporaire pour stocker l'ID du centre de santé
    health_center_id = models.PositiveIntegerField(
        _('ID du centre de santé'),
        null=True,
        blank=True,
        help_text=_('ID du centre de santé auquel est affecté l\'agent')
    )
    
    # Champs hérités à personnaliser
    email = models.EmailField(_('adresse email'), unique=True)
    is_active = models.BooleanField(
        _('compte actif'),
        default=True,
        help_text=_('Désignation si le compte est actif ou non')
    )
    
    # Configuration de l'authentification
    USERNAME_FIELD = 'badge_id'
    EMAIL_FIELD = 'email'
    REQUIRED_FIELDS = ['email', 'first_name', 'last_name', 'phone', 'role']
    
    class Meta:
        verbose_name = _('utilisateur')
        verbose_name_plural = _('utilisateurs')
        ordering = ['last_name', 'first_name']
        
        # Ajout des permissions personnalisées
        permissions = [
            ('view_dashboard', _('Peut voir le tableau de bord')),
            ('manage_users', _('Peut gérer les utilisateurs')),
            ('manage_health_centers', _('Peut gérer les centres de santé')),
        ]
    
    def save(self, *args, **kwargs):
        """
        Surcharge de la méthode save pour générer automatiquement un badge_id
        pour les nouveaux agents de santé.
        """
        is_new = self._state.adding
        
        # Générer un badge_id unique pour les nouveaux agents de santé
        if is_new and self.role == self.Role.HEALTH_WORKER and not self.badge_id:
            self.badge_id = self.generate_unique_badge_id()
        
        # S'assurer que l'email est en minuscules
        if self.email:
            self.email = self.email.lower()
            
        super().save(*args, **kwargs)
    
    @classmethod
    def generate_unique_badge_id(cls):
        """Génère un identifiant de badge unique."""
        while True:
            badge_id = f"AGENT-{get_random_string(8).upper()}"
            if not cls.objects.filter(badge_id=badge_id).exists():
                return badge_id
    
    def get_full_name(self):
        """Retourne le nom complet de l'utilisateur."""
        full_name = f"{self.first_name} {self.last_name}"
        return full_name.strip()
    
    def get_short_name(self):
        """Retourne le prénom de l'utilisateur."""
        return self.first_name
    
    def __str__(self):
        """Représentation en chaîne de l'utilisateur."""
        return f"{self.get_full_name()} ({self.badge_id or 'sans badge'})"
    
    # Méthodes liées aux rôles et permissions
    def is_ministry_user(self):
        """Vérifie si l'utilisateur fait partie du ministère."""
        return self.role == self.Role.MINISTRY
    
    def is_health_worker(self):
        """Vérifie si l'utilisateur est un agent de santé."""
        return self.role == self.Role.HEALTH_WORKER
