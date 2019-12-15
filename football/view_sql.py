# eligibility, and for Django not to barf, everything needs something we can pretend is a PK
CREATE_SUMMARY_VIEW_SQL = """
    CREATE VIEW stats_summary AS
        SELECT
                (ROW_NUMBER() OVER (ORDER BY ranked_teams.season_id ASC, rank ASC))
                    AS id,
                ranked_teams.*,
                CASE
                    WHEN rank <= 4 THEN 'uefa'
                    WHEN rank > 4 AND rank <= 6 THEN 'europa'
                    WHEN rank > (team_count.num_teams - 3) THEN 'relegated'
                END AS eligibility
            FROM
                ranked_teams
                    INNER JOIN (
                        SELECT season_id, count(team_id) AS num_teams
                        FROM ranked_teams
                        GROUP BY season_id
                    ) AS team_count
                    ON ranked_teams.season_id=team_count.season_id
        ORDER BY rank
"""

# Calculated stats, augment with ranks
CREATE_RANKED_VIEW_SQL = """
    CREATE VIEW ranked_teams AS
        SELECT
                (ROW_NUMBER() OVER (
                        PARTITION BY league, season_id
                        ORDER BY points DESC, goal_difference DESC, goals_for DESC
                )) AS rank,
                *
            FROM (
                SELECT
                        team.name,
                        team.code,
                        team.league,
                        (3 * wins) + draws AS points,
                        stats.*
                    FROM football_team AS team
                        INNER JOIN (
                            SELECT
                                    team_id,
                                    season_id,
                                    SUM(score_for) AS goals_for,
                                    SUM(score_against) AS goals_against,
                                    SUM(goalMargin) AS goal_difference,
                                    COUNT(match_id) FILTER (WHERE score_for > score_against) AS wins,
                                    COUNT(match_id) FILTER (WHERE score_for < score_against) AS losses,
                                    COUNT(match_id) FILTER (WHERE score_for = score_against) AS draws
                                FROM match_scores AS scores
                                GROUP BY scores.team_id, scores.season_id
                        ) AS stats
                            ON team.id = stats.team_id
            ) as _summary
"""

# full scores with for/against
CREATE_SCORES_VIEW_SQL = """
    CREATE VIEW match_scores AS
        SELECT
                self.season_id,
                self.match_id AS match_id,
                self.team_id AS team_id,
                self.score AS score_for,
                other.score AS score_against,
                self.score - other.score AS goalMargin
            FROM
                match_score_by_season AS self
                    INNER JOIN match_score_by_season AS other
                        ON self.match_id=other.match_id
                            AND self.id != other.id
"""

# for easy reuse in self-join
CREATE_MATCH_VIEW_SQL = """
    CREATE VIEW match_score_by_season AS
        SELECT match.season_id, score.*
            FROM football_score AS score
                INNER JOIN football_match AS MATCH
                    ON score.match_id=match.id
"""

DROP_SUMMARY_VIEW_SQL = "DROP VIEW stats_summary"
DROP_RANKED_VIEW_SQL = "DROP VIEW ranked_teams"
DROP_SCORES_VIEW_SQL = "DROP VIEW match_scores"
DROP_MATCH_VIEW_SQL = "DROP VIEW match_score_by_season"
