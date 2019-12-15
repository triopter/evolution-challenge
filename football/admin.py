from django.contrib import admin

from football.models import Match, Team, Score, Season


class ScoreAdmin(admin.ModelAdmin):
    list_display = ("__str__", "match", "team", "score")


admin.site.register(Score, ScoreAdmin)
