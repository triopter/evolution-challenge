from django.db import models

LEAGUES = [
    ("English Premier League", "English Premier League",),
    ("La Liga", "La Liga",),
    ("Bundesliga", "Bundesliga",),
]


class Season(models.Model):
    years = models.CharField(max_length=191, unique=True)

    def __str__(self):
        return self.years


class Team(models.Model):
    league = models.CharField(max_length=191, choices=LEAGUES, blank=True)
    name = models.CharField(
        max_length=191
    )  # 191 because if we wanted to port this to MySQL,
    # that would be the max width of a UTF8MB4 column
    # not that we should really ever need 191
    key = models.CharField(max_length=191)
    code = models.CharField(max_length=3, unique=True)

    def __str__(self):
        return self.name


class Match(models.Model):
    season = models.ForeignKey(Season, related_name="matches", on_delete=models.CASCADE)
    # we could use a FK to round and store the round name, but it's not very useful and
    # for current purposes only creates an extra layer of indirection
    round_number = models.PositiveSmallIntegerField()
    match_date = models.DateField()

    def __str__(self):
        # Needing a FK to fetch the name is ugly, but our data set is small enough
        # to make it viable.  If this were done frequently in production it might
        # necessitate denormalization or using a less friendly string representation.
        team_names = [s.team.name for s in self.scores.order_by("is_home_team")]
        vs = " vs. ".join(team_names)
        return f"{vs} ({self.season.years})"


class Score(models.Model):
    match = models.ForeignKey(Match, related_name="scores", on_delete=models.CASCADE)
    team = models.ForeignKey(Team, related_name="scores", on_delete=models.CASCADE)
    score = models.SmallIntegerField()
    is_home_team = models.BooleanField(
        help_text="We're pretending Team 2 is always the home team"
    )

    def __str__(self):
        return f"{self.team}: {self.score} ({self.match.match_date})"


class Summary(models.Model):
    """
    Using a non-managed model to read-only data from a view.
    """

    season = models.ForeignKey(
        Season,
        related_name="team_summaries",
        on_delete=models.DO_NOTHING,
        db_column="season_id",
    )
    league = models.CharField(max_length=191)
    team = models.ForeignKey(
        Team, related_name="summary", on_delete=models.DO_NOTHING, db_column="team_id"
    )
    name = models.CharField(max_length=191)
    league = models.CharField(max_length=191)
    code = models.CharField(max_length=6)
    wins = models.PositiveIntegerField()
    losses = models.PositiveIntegerField()
    draws = models.PositiveIntegerField()
    goals_for = models.PositiveIntegerField()
    goals_against = models.PositiveIntegerField()
    goal_difference = models.IntegerField()
    points = models.PositiveIntegerField()
    rank = models.PositiveIntegerField()
    eligibility = models.CharField(max_length=191)

    class Meta:
        managed = False  # because this is a view -- we won't create the tables
        db_table = "stats_summary"
        ordering = [
            "rank",
        ]
        unique_together = ["league", "season", "code"]

    def __str__(self):
        return f"{self.rank}: {self.team.name}"

    # prevent editing data
    # Note: to further enforce this in an app with multiple developers,
    # we might also use a custom queryset class and model manager
    # with the create(), update(), and delete() methods disabled.
    def save(self, *args, **kwargs):
        pass

    def delete(self, *args, **kwargs):
        pass

