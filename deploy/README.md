# Deploying Locomotive to the VPS

The server runs:

- **Caddy**: public entry point; gets HTTPS certificates automatically and forwards to the app.
- **The `locomotive` container**: run by systemd through Podman's Quadlet, listening on `127.0.0.1:8000` only.
- **SQLite** in the Podman volume `locomotive-data`.

Commands below run as root on the server unless they say "locally".

## One-time setup

1. **DNS**: point your domain's A (and AAAA) record at the server's IP address.

2. **Packages**:

   ```sh
   dnf install podman caddy          # Fedora / RHEL family
   apt install podman caddy          # Debian / Ubuntu
   ```

   Open ports 80 and 443 in the firewall. Caddy needs both, port 80 for the certificate challenge and the HTTP→HTTPS redirect.

3. **Domain**: in `deploy/locomotive.container` and `deploy/Caddyfile`, replace `locomotive.example.org` with your domain. In the `justfile`, set `deploy_host` to your SSH destination.

4. **Copy the files** (locally):

   ```sh
   scp deploy/locomotive.container root@your-vps:/etc/containers/systemd/locomotive.container
   scp deploy/Caddyfile root@your-vps:/etc/caddy/Caddyfile
   ```

   If Caddy already serves other sites, add the `locomotive.example.org { ... }` block to the existing `/etc/caddy/Caddyfile` instead of replacing it.

5. **Secret key**: generate a new one on the server. Don't reuse your dev key.

   ```sh
   python3 -c "import secrets; print(secrets.token_urlsafe(50))" | podman secret create locomotive_secret_key -
   ```

6. **First deploy** (locally): copy the image over:

   ```sh
   podman save localhost/locomotive:latest | gzip | ssh root@your-vps podman load
   ```

   (`just image` first if you haven't built it.)

7. **Start everything**:

   ```sh
   systemctl daemon-reload            # turns the Quadlet file into locomotive.service
   systemctl start locomotive
   systemctl enable --now caddy
   systemctl reload caddy             # if Caddy was already running
   ```

   The Quadlet's `[Install]` section makes the service start at boot. There's no `systemctl enable` for it.

8. **Admin account**:

   ```sh
   podman exec -it locomotive python manage.py createsuperuser
   ```

Then open `https://your-domain/`.

## Updating

Locally: `just deploy`. It builds the image, copies it to the server and restarts the service. Migrations run automatically when the container starts.

If you edit `locomotive.container`, copy it again, then run `systemctl daemon-reload && systemctl restart locomotive` on the server.

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
