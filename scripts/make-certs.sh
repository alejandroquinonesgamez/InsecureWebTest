#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
CERTS_DIR="$ROOT_DIR/certs"

mkdir -p "$CERTS_DIR/secure" "$CERTS_DIR/insecure"

make_secure() {
  echo "[*] Generando certificado SECURE (RSA 3072)..."
  openssl req -x509 -newkey rsa:3072 -sha256 -days 3650 -nodes \
    -keyout "$CERTS_DIR/secure/secure.key" \
    -out "$CERTS_DIR/secure/secure.crt" \
    -subj "/C=ES/ST=Huelva/L=Aroche/O=nginx-labs/CN=secure.aroche.local" \
    -addext "subjectAltName=DNS:secure.aroche.local,DNS:aroche.local"
}

make_insecure() {
  echo "[*] Generando certificado INSECURE (RSA 1024)..."
  # Nota: RSA 1024 es deliberadamente débil. OpenSSL puede advertir, pero lo generará.
  openssl req -x509 -newkey rsa:1024 -sha256 -days 3650 -nodes \
    -keyout "$CERTS_DIR/insecure/insecure.key" \
    -out "$CERTS_DIR/insecure/insecure.crt" \
    -subj "/C=ES/ST=Huelva/L=Aroche/O=nginx-labs/CN=insecure.aroche.local" \
    -addext "subjectAltName=DNS:insecure.aroche.local"
}

if [ ! -f "$CERTS_DIR/secure/secure.crt" ] || [ ! -f "$CERTS_DIR/secure/secure.key" ]; then
  make_secure
else
  echo "[=] SECURE ya existe, no regenero."
fi

if [ ! -f "$CERTS_DIR/insecure/insecure.crt" ] || [ ! -f "$CERTS_DIR/insecure/insecure.key" ]; then
  make_insecure
else
  echo "[=] INSECURE ya existe, no regenero."
fi

echo "[+] OK. Certificados en: $CERTS_DIR"

