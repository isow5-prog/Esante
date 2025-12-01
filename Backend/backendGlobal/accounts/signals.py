import logging
from django.db.models.signals import post_save, pre_save, m2m_changed
from django.dispatch import receiver
from django.contrib.auth import get_user_model
from django.core.mail import send_mail
from django.conf import settings
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.contrib.auth.models import Group, Permission
from django.db import transaction
from django.utils import timezone

# Configuration du logger
logger = logging.getLogger(__name__)

User = get_user_model()

def send_welcome_email(user, password=None):
    """
    Envoie un email de bienvenue à un nouvel utilisateur.
    
    Args:
        user: L'instance de l'utilisateur
        password: Le mot de passe en clair (uniquement pour les nouveaux utilisateurs)
    """
    if not user.email:
        logger.warning(f"Aucune adresse email pour l'utilisateur {user.badge_id}, impossible d'envoyer l'email de bienvenue")
        return
    
    context = {
        'user': user,
        'app_name': 'E-sante SN',
        'site_url': settings.FRONTEND_URL or 'http://localhost:3000',
        'current_year': timezone.now().year,
        'password': password,
    }
    
    subject = f"Bienvenue sur {context['app_name']}"
    html_message = render_to_string('emails/welcome.html', context)
    plain_message = strip_tags(html_message)
    
    try:
        send_mail(
            subject=subject,
            message=plain_message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            html_message=html_message,
            fail_silently=False,
        )
        logger.info(f"Email de bienvenue envoyé à {user.email}")
    except Exception as e:
        logger.error(f"Erreur lors de l'envoi de l'email de bienvenue à {user.email}: {str(e)}")

def assign_default_permissions(user):
    """
    Assigne les permissions par défaut en fonction du rôle de l'utilisateur.
    """
    try:
        if user.role == User.Role.MINISTRY:
            # Permissions pour les utilisateurs du ministère
            permissions = [
                'view_dashboard',
                'manage_users',
                'manage_health_centers',
                'view_statistics',
            ]
            group_name = 'Ministère de la Santé'
        else:
            # Permissions par défaut pour les agents de santé
            permissions = [
                'view_dashboard',
                'add_patient',
                'view_patient',
            ]
            group_name = 'Agents de Santé'
        
        # Créer ou récupérer le groupe
        group, created = Group.objects.get_or_create(name=group_name)
        
        # Ajouter l'utilisateur au groupe
        user.groups.add(group)
        
        # Assigner les permissions individuelles
        for perm_codename in permissions:
            try:
                app_label = 'accounts' if perm_codename.startswith(('view_', 'add_', 'change_', 'delete_')) else 'core'
                perm = Permission.objects.get(codename=perm_codename, content_type__app_label=app_label)
                user.user_permissions.add(perm)
            except Permission.DoesNotExist:
                logger.warning(f"Permission non trouvée: {perm_codename}")
        
        logger.info(f"Permissions attribuées à l'utilisateur {user.badge_id} ({group_name})")
        
    except Exception as e:
        logger.error(f"Erreur lors de l'attribution des permissions à l'utilisateur {user.badge_id}: {str(e)}")

@receiver(post_save, sender=User)
def handle_user_creation(sender, instance, created, **kwargs):
    """
    Gère les actions à effectuer après la création d'un nouvel utilisateur.
    """
    if created:
        logger.info(f"Nouvel utilisateur créé : {instance.badge_id} - {instance.get_full_name()}")
        
        # Générer un mot de passe temporaire si nécessaire
        temp_password = None
        if not instance.has_usable_password() and not instance.password:
            temp_password = User.objects.make_random_password()
            instance.set_password(temp_password)
            instance.save()
        
        # Envoyer l'email de bienvenue en arrière-plan
        transaction.on_commit(lambda: send_welcome_email(instance, temp_password))
        
        # Assigner les permissions par défaut
        transaction.on_commit(lambda: assign_default_permissions(instance))

@receiver(pre_save, sender=User)
def handle_user_update(sender, instance, **kwargs):
    """
    Gère les actions avant la sauvegarde d'un utilisateur.
    """
    if not instance.pk:
        return  # Nouvel utilisateur, déjà géré par handle_user_creation
    
    try:
        # Récupérer l'ancienne instance pour la comparaison
        old_instance = User.objects.get(pk=instance.pk)
        
        # Vérifier si le mot de passe a changé
        if instance.password != old_instance.password:
            logger.info(f"Mot de passe mis à jour pour l'utilisateur {instance.badge_id}")
            # Ici, vous pourriez ajouter une logique pour forcer la réinitialisation du mot de passe
            # ou envoyer une notification de changement de mot de passe
        
        # Vérifier si le statut actif a changé
        if instance.is_active != old_instance.is_active:
            status = "activé" if instance.is_active else "désactivé"
            logger.info(f"Statut de l'utilisateur {instance.badge_id} {status}")
            # Ici, vous pourriez ajouter une logique pour notifier l'utilisateur du changement de statut
    
    except User.DoesNotExist:
        pass  # Cas d'une nouvelle création, déjà géré par handle_user_creation

@receiver(m2m_changed, sender=User.groups.through)
def handle_user_groups_change(sender, instance, action, **kwargs):
    """
    Gère les changements dans les groupes d'un utilisateur.
    """
    if action in ['post_add', 'post_remove', 'post_clear']:
        logger.info(f"Groupes mis à jour pour l'utilisateur {instance.badge_id}")
        # Ici, vous pourriez ajouter une logique pour synchroniser les permissions
        # ou notifier les administrateurs des changements de groupe
