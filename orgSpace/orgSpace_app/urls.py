from django.urls import path
from . import views

urlpatterns = [
    path("", views.landing_page, name="landing"),
    path("officer-dashboard/", views.officer_dashboard, name="officer_dashboard"),
    path("login/", views.login_view, name="login"),
]
