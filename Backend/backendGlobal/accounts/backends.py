from django.contrib.auth import get_user_model
from django.contrib.auth.backends import ModelBackend
import logging

logger = logging.getLogger(__name__)

class BadgeBackend(ModelBackend):
    """
    Authentifie les utilisateurs avec leur badge_id et mot de passe.
    """
    def authenticate(self, request, username=None, password=None, **kwargs):
        if username is None or password is None:
            return None
            
        UserModel = get_user_model()
        
        try:
            # Chercher l'utilisateur par badge_id (insensible à la casse)
            user = UserModel.objects.get(badge_id__iexact=username)
            
            # Vérifier le mot de passe
            if user.check_password(password):
                logger.info(f"Connexion réussie pour l'utilisateur {user.badge_id}")
                return user
            else:
                logger.warning(f"Tentative de connexion échouée - Mot de passe incorrect pour {username}")
        except UserModel.DoesNotExist:
            logger.warning(f"Tentative de connexion échouée - Aucun utilisateur avec le badge_id: {username}")
            return None
        except Exception as e:
            logger.error(f"Erreur lors de l'authentification: {str(e)}", exc_info=True)
            
        return None

    def get_user(self, user_id):
        UserModel = get_user_model()
        try:
            return UserModel.objects.get(pk=user_id)
        except UserModel.DoesNotExist:
            return None
