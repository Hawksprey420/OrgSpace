from django.shortcuts import render

def landing_page(request):
    return render(request, "orgSpace_app/landing.html")


def admin_dashboard(request):
    return render(request, "orgSpace_app/admin/dashboard.html")


def student_dashboard(request):
    return render(request, "orgSpace_app/student/dashboard.html")


def login_view(request):
    return render(request, "orgSpace_app/registration/login.html")