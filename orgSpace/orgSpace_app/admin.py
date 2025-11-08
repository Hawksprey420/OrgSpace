from django.contrib import admin
from django.utils import timezone
from .models import Program, StudentSubmission


@admin.action(description="Approve selected submissions")
def approve_submissions(modeladmin, request, queryset):
    queryset.update(
        is_verified=True,
        verified_by=request.user.username,
        verified_at=timezone.now(),
    )


@admin.register(StudentSubmission)
class StudentSubmissionAdmin(admin.ModelAdmin):
    list_display = (
        "email",
        "sui_address",
        "is_verified",
        "issued_at",
        "verified_by",
        "verified_at",
    )
    list_filter = ("is_verified",)
    search_fields = ("email", "sui_address")
    actions = [approve_submissions]


admin.site.register(Program)
