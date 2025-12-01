from rest_framework.permissions import BasePermission
from django.contrib.auth import get_user_model

User = get_user_model()


class IsMinistry(BasePermission):
    """
    Permission DRF qui limite l'accès aux utilisateurs du ministère.
    """

    def has_permission(self, request, view):
        user = request.user
        return bool(
            user
            and user.is_authenticated
            and user.role == User.Role.MINISTRY
        )


class IsHealthWorker(BasePermission):
    """
    Permission DRF qui limite l'accès aux agents de santé.
    """

    def has_permission(self, request, view):
        user = request.user
        return bool(
            user
            and user.is_authenticated
            and user.role == User.Role.HEALTH_WORKER
        )

