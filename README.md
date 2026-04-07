## nginx-labs-badssl (Aroche)

Laboratorio estilo **badssl** con 3 subdominios:

- **secure**: HTTPS “bueno” (TLS moderno + ciphers fuertes)
- **insecure**: HTTPS “muy débil” (ciphers débiles + `@SECLEVEL=0`)
- **daza-level-security**: HTTP (sin TLS)

Cada subdominio muestra un **login** que hace un `POST` real a un backend (`httpbin`) para que puedas capturar tráfico con Wireshark.

### 1) Requisitos

- Docker + Docker Compose
- Wireshark/tshark (para capturar en `lo` o en la interfaz que uses)

### 2) DNS local (hosts)

Añade estas líneas a `/etc/hosts` (o a tu DNS local), apuntando a tu máquina:

```text
127.0.0.1 aroche.local
127.0.0.1 secure.aroche.local
127.0.0.1 insecure.aroche.local
127.0.0.1 daza-level-security.aroche.local
```

Si vas a acceder desde otra máquina, cambia `127.0.0.1` por la IP del host donde corre Docker.

### 3) Generar certificados

Desde esta carpeta:

```bash
./scripts/make-certs.sh
```

Genera:
- `certs/secure/secure.crt` + `secure.key` (RSA 3072, válido)
- `certs/insecure/insecure.crt` + `insecure.key` (RSA 1024, válido pero “débil”)

### 4) Levantar el laboratorio

```bash
docker compose up -d --build
```

Puertos:
- HTTP: `80`
- HTTPS: `443`

### 5) URLs

- Portada: `http://aroche.local/` (y también por HTTPS)
- Secure: `https://secure.aroche.local/`
- Insecure (débil): `https://insecure.aroche.local/`
- HTTP plano: `http://daza-level-security.aroche.local/`

### 6) Captura con Wireshark

- Si navegas desde **este mismo host**, captura en la interfaz **loopback** (`lo`) o en la interfaz de salida según tu setup.
- Filtra por ejemplo:
  - `tcp.port == 80 || tcp.port == 443`
  - `http` (para el subdominio HTTP)

En **HTTP** verás el `POST` y credenciales en claro. En **HTTPS** verás handshake/ciphers y el tráfico cifrado.

### 7) Portada / imagen Sierra de Aroche

Pon tu imagen en:

- `site/main/assets/hero.png`

Y refresca. (Hay un placeholder por defecto.)

