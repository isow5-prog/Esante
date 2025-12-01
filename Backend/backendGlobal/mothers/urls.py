from django.urls import path

from . import views

app_name = "mothers"

urlpatterns = [
    # Centres de santé
    path("centers/", views.HealthCenterListCreateView.as_view(), name="center-list"),

    # Mères
    path("mothers/", views.MotherListView.as_view(), name="mother-list"),
    path("mothers/recent/", views.RecentMothersListView.as_view(), name="recent-mothers"),
    path("mothers/add-record/", views.AddRecordView.as_view(), name="add-record"),
    path("mothers/<int:pk>/", views.MotherDetailView.as_view(), name="mother-detail"),

    # Statistiques
    path("stats/overview/", views.StatsOverviewView.as_view(), name="stats-overview"),
    path("stats/detailed/", views.StatsDetailedView.as_view(), name="stats-detailed"),

    # Messages de prévention
    path("messages/", views.MessageListCreateView.as_view(), name="message-list"),
    path("messages/<int:pk>/", views.MessageDetailView.as_view(), name="message-detail"),
    path("messages/<int:pk>/publish/", views.MessagePublishView.as_view(), name="message-publish"),
]



