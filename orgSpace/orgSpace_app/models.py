from django.db import models

# Create your models here.
class BaseModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        abstract = True
    
class Program(BaseModel):
    name = models.CharField(max_length=255)
    
    def __str__(self):
        return self.name
    
class Name(BaseModel):
    program = models.ForeignKey(Program, on_delete=models.CASCADE, related_name='names')
    lastname = models.CharField(max_length=25, blank=True, null=True)
    firstname = models.CharField(max_length=25, blank=True, null=True)
    middlename = models.CharField(max_length=25, blank=True, null=True)
    program = models.CharField(max_length=100, blank=True, null=True)
    
    def __str__(self):
       return f"{self.lastname}, {self.firstname}"

class Year_Level(BaseModel):
    program = models.ForeignKey(Program, on_delete=models.CASCADE, related_name='year_levels')
    level = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.program.name} - {self.level}"