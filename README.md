# Locomotive: Coopérative Locale de Mobilité

Une application web de réservation de voiture partagée

# Dev Requirements

- [`just`](https://just.systems/man/en/packages.html) for admin commands
- [`uv`](https://docs.astral.sh/uv/getting-started/installation/) for python project

# Test the application

- `just install`: install python interpreter and packages
- `just createsuperuser`: create a user with admin privileges
- `just run`: run a development server
- `just open-admin`: open the admin panel in a browser
- Login with the admin credentials and create a user in the admin interface
- `just open`: open the app login page in a browser
- Login with the user credentials
# Deployment

The app is deployed as a container built from the `Containerfile` with [Podman](https://podman.io/). Development stays native.

- `just image`: build the production image
- `just container-run`: run it on http://127.0.0.1:8080
- `just container-createsuperuser`: create an admin user in the running container

The container is configured through environment variables:

| Variable | Purpose | Image default |
|---|---|---|
| `DJANGO_SECRET_KEY_FILE` | Path to the secret key file | `/run/secrets/django_secret_key` |
| `DJANGO_ALLOWED_HOSTS` | Comma-separated host names the app answers to | (none, so set it) |
| `DJANGO_CSRF_TRUSTED_ORIGINS` | Comma-separated origins, needed behind HTTPS, e.g. `https://locomotive.example.org` | (none) |
| `DJANGO_DB_PATH` | SQLite database file; mount a volume on `/data` | `/data/db.sqlite3` |
| `DJANGO_DEBUG` | Debug mode | `false` |
