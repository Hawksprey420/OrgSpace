from django.db import models

class BaseModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class Program(BaseModel):
    name = models.CharField(max_length=255)
    college = models.CharField(max_length=255)

    def __str__(self):
        return self.name


class StudentSubmission(BaseModel):
    # Student info
    student_number = models.CharField(max_length=50)
    lastname = models.CharField(max_length=50)
    firstname = models.CharField(max_length=50)
    middlename = models.CharField(max_length=50, blank=True, null=True)

    # Relations
    program = models.ForeignKey(Program, on_delete=models.CASCADE)
    college = models.CharField(max_length=255)   # keep simple for MVP

    # Officer verification flow
    is_verified = models.BooleanField(default=False)
    verified_by = models.CharField(max_length=255, blank=True, null=True)
    verified_at = models.DateTimeField(blank=True, null=True)

    # Blockchain-related
    nft_object_id = models.CharField(max_length=200, blank=True, null=True)
    nft_tx_digest = models.CharField(max_length=200, blank=True, null=True)

    def __str__(self):
        return f"{self.student_number} - {self.lastname}, {self.firstname}"
