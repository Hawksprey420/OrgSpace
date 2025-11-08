from django.shortcuts import render

# Create your views here.

# def landing_page(request):
#     return render(request, "orgSpace_app/landing.html")

def landing_page(request):
    """Landing page - accessible to everyone"""
    return render(request, "orgSpace_app/landing.html")

#login_required
# def home(request):
#     """Dashboard/Home page - requires login"""
#     return render(request, "orgSpace_app/home.html")

#login_required
def dashboard(request):
    """Main officer dashboard - requires login"""
    return render(request, "orgSpace_app/officer_dashboard.html")

def dashboard(request):
    """Main student dashboard - requires login"""
    return render(request, "orgSpace_app/student_dashboard.html")