from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext_lazy as _
from .models import User

class UserAdmin(BaseUserAdmin):
    """Configuration de l'interface d'administration pour le modèle User personnalisé."""
    
    # Champs à afficher dans la liste des utilisateurs
    list_display = ('badge_id', 'email', 'first_name', 'last_name', 'role', 'is_staff', 'is_active')
    list_filter = ('role', 'is_staff', 'is_active')
    
    # Configuration des champs pour la modification d'un utilisateur
    fieldsets = (
        (None, {'fields': ('badge_id', 'password')}),
        (_('Informations personnelles'), {'fields': ('first_name', 'last_name', 'email', 'phone')}),
        (_('Rôle et permissions'), {
            'fields': ('role', 'is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions'),
        }),
        (_('Dates importantes'), {'fields': ('last_login', 'date_joined')}),
    )
    
    # Configuration des champs pour l'ajout d'un nouvel utilisateur
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'first_name', 'last_name', 'password1', 'password2', 'role', 'phone', 'is_staff', 'is_active'),
        }),
    )
    
    # Champs utilisés pour la recherche
    search_fields = ('email', 'first_name', 'last_name', 'badge_id')
    ordering = ('email',)
    filter_horizontal = ('groups', 'user_permissions',)

# Enregistrement du modèle User avec la configuration personnalisée
admin.site.register(User, UserAdmin)
