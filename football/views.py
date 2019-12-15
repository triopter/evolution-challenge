import json
import humps

from django.conf import settings
from django.http import HttpResponse, HttpResponseBadRequest, HttpResponseNotFound
from django.shortcuts import render

from football.models import Summary, Season


def _summary(request):
    try:
        season_id = int(request.GET["season_id"])
    except ValueError:
        return HttpResponseBadRequest, {"error": "Season ID must be an integer"}
    except KeyError:
        return HttpResponseBadRequest, {"error": "Season ID is required"}

    season_exists = Season.objects.filter(pk=season_id).exists()
    if not season_exists:
        return HttpResponseNotFound, {"error": f"No season exists with ID {season_id}"}

    queryset = Summary.objects.filter(season_id=season_id)
    team_code = request.GET.get("team_code")
    if team_code:
        queryset = queryset.filter(code=team_code)

    data = [humps.camelize(team) for team in queryset.values()]

    return HttpResponse, data


def summary(request):
    resp_type, data = _summary(request)
    response = resp_type(json.dumps(data), content_type="application/json")
    for k, v in settings.CORS_HEADERS.items():
        response[k] = v
    return response

