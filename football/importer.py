from django.utils.dateparse import parse_date

from football.models import Team, Match, Score, Season


class ScoreImporter(object):
    """
    Imports league score data.  Assumes correctly formatted data matching
    https://github.com/openfootball/football.json/blob/f03f5cf87dad91d359ead88e4ebfef4529944067/2016-17/en.1.json

    Note: in production we'd probably want better error handling for malformed data
    """

    def __init__(self):
        self.raw_data = {}
        self.teams = {}

    def import_data(self, raw_data):
        season, _ = Season.objects.get_or_create(years=raw_data["name"])
        for index, round_data in enumerate(raw_data["rounds"]):
            round_number = index + 1
            for match_data in round_data["matches"]:
                self.import_match(season, round_number, match_data)

    def import_match(self, season, round_number, match_data):
        if match_data["score1"] is None or match_data["score2"] is None:
            # Skip importing.  For production app, we need to find out whether these count as draws
            return
        match = Match.objects.create(
            season=season,
            round_number=round_number,
            match_date=parse_date(match_data["date"]),
        )
        team1 = self.get_or_create_team(match_data["team1"])
        team2 = self.get_or_create_team(match_data["team2"])
        self.import_score(match, team1, match_data["score1"], False)
        self.import_score(match, team2, match_data["score2"], True)

    def get_or_create_team(self, team_data):
        team, created = Team.objects.get_or_create(
            **{
                "name": team_data["name"],
                "key": team_data["key"],
                "code": team_data["code"],
            }
        )
        return team

    def import_score(self, match, team, score, is_home_team):
        Score.objects.create(
            **{
                "match": match,
                "team": team,
                "score": score,
                "is_home_team": is_home_team,
            }
        )

