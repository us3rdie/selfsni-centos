#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-}"

if [[ $EUID -ne 0 ]]; then
    echo "Run as root" >&2
    exit 1
fi

if [[ ! "$DOMAIN" =~ ^[A-Za-z0-9][A-Za-z0-9.-]*[A-Za-z0-9]$ ]] || [[ "$DOMAIN" == *..* ]]; then
    echo "Usage: $0 domain.tld" >&2
    exit 1
fi

if [[ ! -f "/etc/letsencrypt/renewal/$DOMAIN.conf" ]]; then
    echo "Certbot renewal configuration for $DOMAIN was not found." >&2
    echo "Run selfsni-centos.sh for this domain first." >&2
    exit 1
fi

if ! command -v certbot >/dev/null || ! command -v systemctl >/dev/null; then
    echo "certbot and systemctl are required." >&2
    exit 1
fi

dnf install -y cronie
systemctl enable --now crond

CERTBOT_BIN="$(command -v certbot)"
SYSTEMCTL_BIN="$(command -v systemctl)"
CRON_NAME="${DOMAIN//./_}"
CRON_FILE="/etc/cron.d/selfsni-cert-renew-$CRON_NAME"
TEMP_FILE="$(mktemp /etc/cron.d/.selfsni-cert-renew.XXXXXX)"
trap 'rm -f -- "$TEMP_FILE"' EXIT

cat > "$TEMP_FILE" <<EOF
SHELL=/bin/sh
PATH=/usr/sbin:/usr/bin:/sbin:/bin
17 3 * * * root $CERTBOT_BIN renew --quiet --cert-name $DOMAIN --pre-hook "$SYSTEMCTL_BIN stop nginx" --post-hook "$SYSTEMCTL_BIN start nginx" >> /var/log/selfsni-cert-renew-$DOMAIN.log 2>&1
EOF

chmod 644 "$TEMP_FILE"
mv -f -- "$TEMP_FILE" "$CRON_FILE"
trap - EXIT

echo "Daily renewal check installed: $CRON_FILE"
echo "Log: /var/log/selfsni-cert-renew-$DOMAIN.log"
echo "Test it with: certbot renew --dry-run --cert-name $DOMAIN --pre-hook '$SYSTEMCTL_BIN stop nginx' --post-hook '$SYSTEMCTL_BIN start nginx'"
