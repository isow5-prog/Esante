from django.apps import AppConfig
from django.utils.translation import gettext_lazy as _


class AccountsConfig(AppConfig):
    """Configuration de l'application accounts."""
    
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'accounts'
    verbose_name = _('authentification et autorisations')
    
    def ready(self):
        """
        Méthode appelée au chargement de l'application.
        Permet d'importer les signaux sans créer d'imports circulaires.
        """
        # Importer les signaux
        try:
            import accounts.signals  # noqa F401
        except ImportError:
            # Les signaux ne sont pas encore implémentés
            pass
