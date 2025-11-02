from django.contrib import admin
from .models import Program, Name, Year_Level
# Register your models here.

admin.site.register(Program)
admin.site.register(Name)
admin.site.register(Year_Level)

class ProgramAdmin(admin.ModelAdmin):
    list_display = ('name', 'created_at', 'updated_at')
    search_fields = ('name',)

class NameAdmin(admin.ModelAdmin):
    list_display = ('lastname', 'firstname', 'middlename', 'program', 'created_at', 'updated_at')
    search_fields = ('lastname', 'firstname', 'program__name')
    
class Year_LevelAdmin(admin.ModelAdmin):
    list_display = ('program', 'level', 'created_at', 'updated_at')
    search_fields = ('program__name', 'level')