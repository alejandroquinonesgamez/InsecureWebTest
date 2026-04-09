#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

AUTH_USER="${AUTH_USER:-Manuel}"
AUTH_PASS="${AUTH_PASS:-SierraArocheLove88}"
REGEN_CERTS=0

usage() {
  cat <<'EOF'
Uso:
  ./scripts/run.sh [--user USER] [--pass PASS] [--regen-certs]

Ejemplos:
  ./scripts/run.sh
  ./scripts/run.sh --user Manuel --pass SierraArocheLove88
  ./scripts/run.sh --regen-certs
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)
      AUTH_USER="${2:-}"; shift 2;;
    --pass)
      AUTH_PASS="${2:-}"; shift 2;;
    --regen-certs)
      REGEN_CERTS=1; shift;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Argumento desconocido: $1" >&2
      usage
      exit 2;;
  esac
done

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker no está instalado o no está en PATH." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon no está accesible. ¿Está arrancado (systemctl start docker)?" >&2
  exit 1
fi

cat > .env <<EOF
AUTH_USER=${AUTH_USER}
AUTH_PASS=${AUTH_PASS}
EOF

if [[ "$REGEN_CERTS" == "1" ]]; then
  rm -rf certs/secure certs/insecure || true
fi

./scripts/make-certs.sh

# Limpieza para evitar conflictos/huérfanos
docker compose down --remove-orphans || true

# Arranque
docker compose up -d --build

echo
echo "[OK] Levantado."
echo "Portada: http://localhost/"
echo "Secure:  https://secure.localhost/"
echo "Insecure:https://insecure.localhost/"
echo "HTTP:    http://daza-level-security.localhost/"

