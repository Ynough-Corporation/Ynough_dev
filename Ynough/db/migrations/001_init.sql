CREATE TABLE IF NOT EXISTS team (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE,
    player_1 VARCHAR(120) NOT NULL,
    player_2 VARCHAR(120) NOT NULL,
    CONSTRAINT ck_team_players_different CHECK (player_1 <> player_2)
);

CREATE TABLE IF NOT EXISTS referee (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS game_match (
    id BIGSERIAL PRIMARY KEY,
    id_referee BIGINT,
    id_team1 BIGINT NOT NULL,
    id_team2 BIGINT NOT NULL,
    score_team1 BIGINT NOT NULL DEFAULT 0,
    score_team2 BIGINT NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled',
    date TIMESTAMPTZ NOT NULL,
    score BIGINT GENERATED ALWAYS AS (score_team1 + score_team2) STORED,

    CONSTRAINT fk_game_match_referee
        FOREIGN KEY (id_referee)
        REFERENCES referee (id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_game_match_team1
        FOREIGN KEY (id_team1)
        REFERENCES team (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_game_match_team2
        FOREIGN KEY (id_team2)
        REFERENCES team (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT ck_game_match_teams_different CHECK (id_team1 <> id_team2),
    CONSTRAINT ck_game_match_scores_positive CHECK (score_team1 >= 0 AND score_team2 >= 0),
    CONSTRAINT ck_game_match_status CHECK (status IN ('scheduled', 'in_progress', 'finished', 'cancelled'))
);

CREATE INDEX IF NOT EXISTS idx_game_match_date ON game_match (date);
CREATE INDEX IF NOT EXISTS idx_game_match_referee ON game_match (id_referee);
CREATE INDEX IF NOT EXISTS idx_game_match_team1 ON game_match (id_team1);
CREATE INDEX IF NOT EXISTS idx_game_match_team2 ON game_match (id_team2);

