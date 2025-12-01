from django.contrib import admin
from .models import QRCodeCard


@admin.register(QRCodeCard)
class QRCodeCardAdmin(admin.ModelAdmin):
    list_display = ("code", "status", "center_name", "center_city", "created_at")
    list_filter = ("status", "center_city")
    search_fields = ("code", "center_name", "center_city")



