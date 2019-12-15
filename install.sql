
CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);

CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);

CREATE SEQUENCE public.auth_group_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);

CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);

CREATE TABLE public.auth_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);

CREATE SEQUENCE public.auth_user_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.auth_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.auth_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);

CREATE SEQUENCE public.auth_user_user_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);

CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);

CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);

CREATE SEQUENCE public.django_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);

CREATE TABLE public.football_match (
    id integer NOT NULL,
    round_number smallint NOT NULL,
    match_date date NOT NULL,
    season_id integer NOT NULL,
    CONSTRAINT football_match_round_number_check CHECK ((round_number >= 0))
);

CREATE SEQUENCE public.football_match_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.football_score (
    id integer NOT NULL,
    score smallint NOT NULL,
    is_home_team boolean NOT NULL,
    match_id integer NOT NULL,
    team_id integer NOT NULL
);

CREATE SEQUENCE public.football_score_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.football_season (
    id integer NOT NULL,
    years character varying(191) NOT NULL
);

CREATE SEQUENCE public.football_season_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.football_team (
    id integer NOT NULL,
    league character varying(191) NOT NULL,
    name character varying(191) NOT NULL,
    key character varying(191) NOT NULL,
    code character varying(3) NOT NULL
);

CREATE SEQUENCE public.football_team_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE VIEW public.match_score_by_season AS
 SELECT match.season_id,
    score.id,
    score.score,
    score.is_home_team,
    score.match_id,
    score.team_id
   FROM (public.football_score score
     JOIN public.football_match match ON ((score.match_id = match.id)));

CREATE VIEW public.match_scores AS
 SELECT self.season_id,
    self.match_id,
    self.team_id,
    self.score AS score_for,
    other.score AS score_against,
    (self.score - other.score) AS goalmargin
   FROM (public.match_score_by_season self
     JOIN public.match_score_by_season other ON (((self.match_id = other.match_id) AND (self.id <> other.id))));

CREATE VIEW public.ranked_teams AS
 SELECT row_number() OVER (PARTITION BY _summary.league, _summary.season_id ORDER BY _summary.points DESC, _summary.goal_difference DESC, _summary.goals_for DESC) AS rank,
    _summary.name,
    _summary.code,
    _summary.league,
    _summary.points,
    _summary.team_id,
    _summary.season_id,
    _summary.goals_for,
    _summary.goals_against,
    _summary.goal_difference,
    _summary.wins,
    _summary.losses,
    _summary.draws
   FROM ( SELECT team.name,
            team.code,
            team.league,
            ((3 * stats.wins) + stats.draws) AS points,
            stats.team_id,
            stats.season_id,
            stats.goals_for,
            stats.goals_against,
            stats.goal_difference,
            stats.wins,
            stats.losses,
            stats.draws
           FROM (public.football_team team
             JOIN ( SELECT scores.team_id,
                    scores.season_id,
                    sum(scores.score_for) AS goals_for,
                    sum(scores.score_against) AS goals_against,
                    sum(scores.goalmargin) AS goal_difference,
                    count(scores.match_id) FILTER (WHERE (scores.score_for > scores.score_against)) AS wins,
                    count(scores.match_id) FILTER (WHERE (scores.score_for < scores.score_against)) AS losses,
                    count(scores.match_id) FILTER (WHERE (scores.score_for = scores.score_against)) AS draws
                   FROM public.match_scores scores
                  GROUP BY scores.team_id, scores.season_id) stats ON ((team.id = stats.team_id)))) _summary;

CREATE VIEW public.stats_summary AS
 SELECT row_number() OVER (ORDER BY ranked_teams.season_id, ranked_teams.rank) AS id,
    ranked_teams.rank,
    ranked_teams.name,
    ranked_teams.code,
    ranked_teams.league,
    ranked_teams.points,
    ranked_teams.team_id,
    ranked_teams.season_id,
    ranked_teams.goals_for,
    ranked_teams.goals_against,
    ranked_teams.goal_difference,
    ranked_teams.wins,
    ranked_teams.losses,
    ranked_teams.draws,
        CASE
            WHEN (ranked_teams.rank <= 4) THEN 'uefa'::text
            WHEN ((ranked_teams.rank > 4) AND (ranked_teams.rank <= 6)) THEN 'europa'::text
            WHEN (ranked_teams.rank > (team_count.num_teams - 3)) THEN 'relegated'::text
            ELSE NULL::text
        END AS eligibility
   FROM (public.ranked_teams
     JOIN ( SELECT ranked_teams_1.season_id,
            count(ranked_teams_1.team_id) AS num_teams
           FROM public.ranked_teams ranked_teams_1
          GROUP BY ranked_teams_1.season_id) team_count ON ((ranked_teams.season_id = team_count.season_id)))
  ORDER BY ranked_teams.rank;

ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);

ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);

ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);

ALTER TABLE ONLY public.auth_user ALTER COLUMN id SET DEFAULT nextval('public.auth_user_id_seq'::regclass);

ALTER TABLE ONLY public.auth_user_groups ALTER COLUMN id SET DEFAULT nextval('public.auth_user_groups_id_seq'::regclass);

ALTER TABLE ONLY public.auth_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_user_user_permissions_id_seq'::regclass);

ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);

ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);

ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);

ALTER TABLE ONLY public.football_match ALTER COLUMN id SET DEFAULT nextval('public.football_match_id_seq'::regclass);

ALTER TABLE ONLY public.football_score ALTER COLUMN id SET DEFAULT nextval('public.football_score_id_seq'::regclass);

ALTER TABLE ONLY public.football_season ALTER COLUMN id SET DEFAULT nextval('public.football_season_id_seq'::regclass);

ALTER TABLE ONLY public.football_team ALTER COLUMN id SET DEFAULT nextval('public.football_team_id_seq'::regclass);

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq UNIQUE (user_id, group_id);

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq UNIQUE (user_id, permission_id);

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);

ALTER TABLE ONLY public.football_match
    ADD CONSTRAINT football_match_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.football_score
    ADD CONSTRAINT football_score_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.football_season
    ADD CONSTRAINT football_season_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.football_season
    ADD CONSTRAINT football_season_years_key UNIQUE (years);

ALTER TABLE ONLY public.football_team
    ADD CONSTRAINT football_team_code_key UNIQUE (code);

ALTER TABLE ONLY public.football_team
    ADD CONSTRAINT football_team_pkey PRIMARY KEY (id);

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);

CREATE INDEX auth_user_groups_group_id_97559544 ON public.auth_user_groups USING btree (group_id);

CREATE INDEX auth_user_groups_user_id_6a12ed8b ON public.auth_user_groups USING btree (user_id);

CREATE INDEX auth_user_user_permissions_permission_id_1fbb5f2c ON public.auth_user_user_permissions USING btree (permission_id);

CREATE INDEX auth_user_user_permissions_user_id_a95ead1b ON public.auth_user_user_permissions USING btree (user_id);

CREATE INDEX auth_user_username_6821ab7c_like ON public.auth_user USING btree (username varchar_pattern_ops);

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);

CREATE INDEX football_match_season_id_abdedcc0 ON public.football_match USING btree (season_id);

CREATE INDEX football_score_match_id_daa7fece ON public.football_score USING btree (match_id);

CREATE INDEX football_score_team_id_a762e124 ON public.football_score USING btree (team_id);

CREATE INDEX football_season_years_e01052fb_like ON public.football_season USING btree (years varchar_pattern_ops);

CREATE INDEX football_team_code_b18f76e1_like ON public.football_team USING btree (code varchar_pattern_ops);

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY public.football_match
    ADD CONSTRAINT football_match_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.football_season(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY public.football_score
    ADD CONSTRAINT football_score_match_id_daa7fece_fk_football_match_id FOREIGN KEY (match_id) REFERENCES public.football_match(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY public.football_score
    ADD CONSTRAINT football_score_team_id_a762e124_fk_football_team_id FOREIGN KEY (team_id) REFERENCES public.football_team(id) DEFERRABLE INITIALLY DEFERRED;

