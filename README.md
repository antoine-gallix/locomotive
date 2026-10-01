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