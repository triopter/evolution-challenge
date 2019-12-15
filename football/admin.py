from django.contrib import admin

from football.models import Match, Team, Score, Summary, Season


class ScoreAdmin(admin.ModelAdmin):
    list_display = ("__str__", "match", "team", "score")


class SummaryAdmin(admin.ModelAdmin):
    list_display = (
        "__str__",
        "code",
        "team",
        "rank",
        "points",
        "wins",
        "losses",
        "draws",
        "goals_for",
        "goals_against",
        "goal_difference",
    )
    readonly_fields = [f.name for f in Summary._meta.fields]

    def has_add_permission(self, *args, **kwargs):
        return False

    def has_delete_permission(self, *args, **kwargs):
        return False


admin.site.register(Score, ScoreAdmin)
admin.site.register(Summary, SummaryAdmin)
