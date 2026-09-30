from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    """The project's user model.

    Custom from day one (per Django's recommendation) so it can be
    extended later without a disruptive migration. Currently identical
    to AbstractUser; add fields here as needed.
    """
