# Run `just` to list available recipes.
default:
    @just --list

# Install dependencies
install:
    uv sync

# Run the test suite (extra args are passed to pytest, e.g. `just test -k home`)
test *args:
    uv run pytest {{args}}

# Start the dev server (http://127.0.0.1:8000)
run:
    uv run src/manage.py runserver

# Open the app in a browser
open:
    xdg-open http://127.0.0.1:8000/

# Open the admin page in a browser
open-admin:
    xdg-open http://127.0.0.1:8000/admin

# Python shell with Django/models loaded
shell:
    uv run src/manage.py shell

# Drop into sqlite3 directly
dbshell:
    uv run src/manage.py dbshell

# Create a superuser interactively
createsuperuser:
    uv run src/manage.py createsuperuser

# Generate migrations from model changes
makemigrations:
    uv run src/manage.py makemigrations

# Apply pending migrations
migrate:
    uv run src/manage.py migrate

# Delete the local database, rebuild it from migrations, and create a superuser
[confirm("Delete src/db.sqlite3 and all its data?")]
reset-db:
    rm -f src/db.sqlite3
    uv run src/manage.py migrate
    uv run src/manage.py createsuperuser

# Run Django's system checks
check:
    uv run src/manage.py check
