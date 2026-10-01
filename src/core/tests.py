import pytest
from django.core.management import call_command


@pytest.mark.django_db
def test_migrations_are_in_sync_with_models():
    """Fails if a model changed without a matching migration."""
    call_command("makemigrations", "--check", "--dry-run")
