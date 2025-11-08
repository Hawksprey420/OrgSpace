from django.urls import path
from . import views

urlpatterns = [
    path("", views.landing_page, name="landing"),
    path("admin-dashboard/", views.admin_dashboard, name="officer_dashboard"),
    path("student-dashboard/", views.student_dashboard, name="student_dashboard"),
    path("login/", views.login_view, name="login"),
]
