# Generated by Django 3.0 on 2019-12-15 20:15

from django.db import migrations, models
import django.db.models.deletion

from football.view_sql import (
    CREATE_MATCH_VIEW_SQL,
    CREATE_SCORES_VIEW_SQL,
    CREATE_RANKED_VIEW_SQL,
    CREATE_SUMMARY_VIEW_SQL,
    DROP_MATCH_VIEW_SQL,
    DROP_SCORES_VIEW_SQL,
    DROP_RANKED_VIEW_SQL,
    DROP_SUMMARY_VIEW_SQL,
)


class Migration(migrations.Migration):

    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="Match",
            fields=[
                (
                    "id",
                    models.AutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("round_number", models.PositiveSmallIntegerField()),
                ("match_date", models.DateField()),
            ],
        ),
        migrations.CreateModel(
            name="Season",
            fields=[
                (
                    "id",
                    models.AutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("years", models.CharField(max_length=191, unique=True)),
            ],
        ),
        migrations.CreateModel(
            name="Team",
            fields=[
                (
                    "id",
                    models.AutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                (
                    "league",
                    models.CharField(
                        blank=True,
                        choices=[
                            ("English Premier League", "English Premier League"),
                            ("La Liga", "La Liga"),
                            ("Bundesliga", "Bundesliga"),
                        ],
                        max_length=191,
                    ),
                ),
                ("name", models.CharField(max_length=191)),
                ("key", models.CharField(max_length=191)),
                ("code", models.CharField(max_length=3, unique=True)),
            ],
        ),
        migrations.CreateModel(
            name="Score",
            fields=[
                (
                    "id",
                    models.AutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("score", models.SmallIntegerField()),
                (
                    "is_home_team",
                    models.BooleanField(
                        help_text="We're pretending Team 2 is always the home team"
                    ),
                ),
                (
                    "match",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="scores",
                        to="football.Match",
                    ),
                ),
                (
                    "team",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="scores",
                        to="football.Team",
                    ),
                ),
            ],
        ),
        migrations.AddField(
            model_name="match",
            name="season",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name="matches",
                to="football.Season",
            ),
        ),
        migrations.RunSQL(CREATE_MATCH_VIEW_SQL, DROP_MATCH_VIEW_SQL),
        migrations.RunSQL(CREATE_SCORES_VIEW_SQL, DROP_SCORES_VIEW_SQL),
        migrations.RunSQL(CREATE_RANKED_VIEW_SQL, DROP_RANKED_VIEW_SQL),
        migrations.RunSQL(CREATE_SUMMARY_VIEW_SQL, DROP_SUMMARY_VIEW_SQL),
    ]
