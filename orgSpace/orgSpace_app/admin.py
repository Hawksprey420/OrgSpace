from django.contrib import admin
from .models import Program, StudentSubmission
from django.utils import timezone

@admin.action(description="Approve selected submissions")
def approve_submissions(modeladmin, request, queryset):
    queryset.update(
        is_verified=True,
        verified_by=request.user.username,
        verified_at=timezone.now(),
    )

class StudentSubmissionAdmin(admin.ModelAdmin):
    list_display = ("student_number", "lastname", "firstname", "program", "college", "is_verified")
    list_filter = ("program", "college", "is_verified")
    search_fields = ("student_number", "lastname", "firstname")
    actions = [approve_submissions]

admin.site.register(Program)
admin.site.register(StudentSubmission, StudentSubmissionAdmin)
