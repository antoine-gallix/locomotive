# Deploying Locomotive to the VPS

The server runs:

- **Caddy**: public entry point; gets HTTPS certificates automatically and forwards to the app.
- **The `locomotive` container**: run by systemd through Podman's Quadlet, listening on `127.0.0.1:8000` only.
- **SQLite** in the Podman volume `locomotive-data`.

Deployment is done by the Ansible playbook `deploy/playbook.yml`, run from your machine. Commands below run locally unless they say "on the server".

## One-time setup

1. **DNS**: point your domain's A (and AAAA) record at the server's IP address.

2. **Server**: Caddy must already be installed and running, with ports 80 and 443 open in the firewall. Caddy needs both, port 80 for the certificate challenge and the HTTP→HTTPS redirect. The playbook installs Podman itself.

3. **Ansible**: install it locally, for example `uv tool install ansible-core`.

4. **Inventory**: in `deploy/inventory.yml`, replace `your-vps` with your SSH destination and `locomotive.example.org` with your domain.

5. **Deploy**:

   ```sh
   just deploy
   ```

   The playbook:

   - builds the image and copies it to the server, if it changed;
   - generates the Django secret key as the Podman secret `locomotive_secret_key`, on the first run only;
   - installs the Quadlet unit to `/etc/containers/systemd/locomotive.container`;
   - adds the site to `/etc/caddy/Caddyfile`, between `# BEGIN locomotive` and `# END locomotive` markers, leaving the rest of the file alone;
   - restarts the app and reloads Caddy when something they depend on changed.

   If your Caddy config lives elsewhere, set `caddyfile_path` in the inventory vars.

6. **Admin account** (on the server):

   ```sh
   podman exec -it locomotive python manage.py createsuperuser
   ```

Then open `https://your-domain/`.

## Updating

`just deploy` again. It is safe to re-run: only what changed is applied. Migrations run automatically when the container starts.

`deploy/locomotive.container` and `deploy/Caddyfile` are templates, the playbook fills in the domain. Edit them here and redeploy, not on the server.

## Day to day

| Task | Command (on the server) |
|---|---|
| Status | `systemctl status locomotive` |
| Logs | `journalctl -u locomotive -f` |
| Django shell | `podman exec -it locomotive python manage.py shell` |
| Back up the database | `podman exec locomotive python -c "import sqlite3; sqlite3.connect('/data/db.sqlite3').backup(sqlite3.connect('/data/backup.sqlite3'))"` then copy it out with `podman cp locomotive:/data/backup.sqlite3 .` |

## Notes

- **CPU architecture**: the image is built for your laptop's architecture (x86_64). If the VPS is ARM, for example Hetzner CAX, build with `podman build --platform linux/arm64 -t locomotive .` instead.
- **Single instance**: SQLite allows only one writer, so run only one container.
