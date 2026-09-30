# Run `just` to list available recipes.
default:
    @just --list

# Start the dev server (http://127.0.0.1:8000)
run:
    uv run src/manage.py runserver

# Open the app in a browser (nothing's mounted at / yet, so this opens /admin/)
open:
    xdg-open http://127.0.0.1:8000/admin/

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

# Run Django's system checks
check:
    uv run src/manage.py check
