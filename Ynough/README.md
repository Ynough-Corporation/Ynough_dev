# Ynough

Application de gestion de tournoi de baby-foot avec :

- un frontend Flutter
- une API Flask
- une base PostgreSQL

## Architecture

- `lib/` : application Flutter
- `ynough-flask-api/` : backend Flask
- `db/migrations/001_init.sql` : schema PostgreSQL

Le frontend Flutter ne parle pas directement a PostgreSQL.
Il consomme l'API Flask via `API_BASE_URL`.

## Prerequis

- Flutter
- Python 3
- PostgreSQL

Sur la machine utilisee pour ce projet :

- PostgreSQL ecoute sur le port `5433`
- l'API Flask tourne sur le port `5000`
- l'application Flutter web peut etre lancee sur Chrome

## Initialiser la base de donnees

Creer la base :

```powershell
& "C:\Program Files\PostgreSQL\18\bin\createdb.exe" -h localhost -p 5433 -U postgres ynough
```

Executer le schema :

```powershell
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -p 5433 -U postgres -d ynough -f "C:\Users\elisa\Desktop\Challenge-48h\Ynough_dev\Ynough\db\migrations\001_init.sql"
```

Le schema cree les tables :

- `team`
- `referee`
- `game_match`

## Lancer l'API Flask

Depuis `ynough-flask-api/` :

```powershell
cd C:\Users\elisa\Desktop\Challenge-48h\Ynough_dev\Ynough\ynough-flask-api
$env:DB_HOST="localhost"
$env:DB_PORT="5433"
$env:DB_NAME="ynough"
$env:DB_USER="postgres"
$env:DB_PASS="VOTRE_MOT_DE_PASSE_POSTGRES"
$env:DB_CLIENT_ENCODING="LATIN1"
pip install flask psycopg2-binary python-dotenv
python main.py
```

L'API est alors disponible sur :

`http://localhost:5000`

## Lancer l'application Flutter sur Chrome

Depuis la racine du projet Flutter :

```powershell
cd C:\Users\elisa\Desktop\Challenge-48h\Ynough_dev\Ynough
& "C:\Users\elisa\Documents\flutter_windows_3.38.9-stable\flutter\bin\flutter.bat" pub get
& "C:\Users\elisa\Documents\flutter_windows_3.38.9-stable\flutter\bin\flutter.bat" run -d chrome --dart-define=API_BASE_URL=http://localhost:5000
```

Si `flutter` n'est pas dans le `PATH`, garder le chemin complet vers `flutter.bat`.

## Fonctionnalites principales

- page accueil connectee a l'API
- page equipes connectee a la base via l'API
- creation et suppression d'equipes
- creation de matchs a partir des equipes existantes
- gestion des matchs en cours
- augmentation et diminution du score
- fin de match avec passage automatique dans les matchs termines
- classement calcule a partir des matchs termines

## Endpoints API utiles

- `GET /api/teams`
- `POST /api/teams`
- `DELETE /teams/<id>`
- `GET /api/matches`
- `POST /api/matches`
- `PATCH /api/matches/<id>/score`
- `PATCH /api/matches/<id>/status`

## Points d'attention

- le mot de passe PostgreSQL doit etre le vrai mot de passe du user `postgres`
- les variables PowerShell `$env:...` ne valent que pour le terminal courant
- si `localhost:5432` apparait encore quelque part, la bonne configuration locale observee ici est `5433`
- si `flutter_svg` n'est pas reconnu, executer `pub get` depuis le dossier `Ynough`

## Droits d'auteur

Application créée par le pôle dev de l'entreprise Ynough composé de :
- Elisabeth Robl
- Emma De Oliveira
- Nolann Pierre-Antoine
- Pierre Assignon
