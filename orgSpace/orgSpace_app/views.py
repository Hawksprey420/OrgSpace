from django.shortcuts import render

def landing_page(request):
    """Landing page - accessible to everyone"""
    return render(request, "orgSpace_app/landing.html")

def officer_dashboard(request):
    return render(request, "orgSpace_app/officer_dashboard.html")

def login_view(request):
    return render(request, "orgSpace_app/registration/login.html")

def student_dashboard(request):
    return render(request, "orgSpace_app/student_dashboard.html")