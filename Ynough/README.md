# ynough

Application Flutter connectee a PostgreSQL.

## Configuration PostgreSQL

La connexion est configuree via des variables compile-time (`--dart-define`) :

- `PG_HOST` (defaut: `localhost`)
- `PG_PORT` (defaut: `5432`)
- `PG_DATABASE` (defaut: `ynough`)
- `PG_USER` (defaut: `postgres`)
- `PG_PASSWORD` (defaut: `postgres`)
- `PG_SSL` (`true`/`false`, defaut: `false`)

## Initialiser le schema PostgreSQL

Le script de creation est dans `db/migrations/001_init.sql`.

```bash
psql -h localhost -p 5432 -U postgres -d ynough -f db/migrations/001_init.sql
```

Notes:
- La table de match est nommee `game_match` (au lieu de `match`) pour eviter un mot reserve SQL.
- Le champ `score` est calcule automatiquement via `score_team1 + score_team2`.

## Lancer l application

```bash
flutter pub get
flutter run \
  --dart-define=PG_HOST=localhost \
  --dart-define=PG_PORT=5432 \
  --dart-define=PG_DATABASE=ynough \
  --dart-define=PG_USER=postgres \
  --dart-define=PG_PASSWORD=postgres \
  --dart-define=PG_SSL=false
```

## Notes

- Le schema (`team`, `game_match`, `referee`) est cree automatiquement au premier demarrage.
- Pour la production, ne laisse pas les credentials en dur et prefere un backend/API entre l app et PostgreSQL.
