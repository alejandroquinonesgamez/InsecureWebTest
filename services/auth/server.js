const express = require("express");

const app = express();
app.disable("x-powered-by");
app.use(express.urlencoded({ extended: false }));

const VALID_USER = process.env.AUTH_USER ?? "Manuel";
const VALID_PASS = process.env.AUTH_PASS ?? "SierraArocheLove88";

function escapeHtml(s) {
  return String(s)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function page({ ok, username, host }) {
  const title = ok ? "Login correcto" : "Login incorrecto";
  const statusColor = ok ? "#10b981" : "#ef4444";
  const hint = ok
    ? "Perfecto. Credenciales válidas."
    : "Usuario o contraseña incorrectos.";

  return `<!doctype html>
<html lang="es">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>${title}</title>
    <style>
      :root { color-scheme: light; }
      body { margin: 0; font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial; background: #0b1220; color: #e5e7eb; }
      .wrap { max-width: 720px; margin: 0 auto; padding: 34px 16px 56px; }
      .box { border: 1px solid rgba(255,255,255,.14); border-radius: 16px; padding: 16px; background: rgba(255,255,255,.06); box-shadow: 0 26px 80px rgba(0,0,0,.45); }
      h1 { margin: 0 0 8px; font-size: 22px; letter-spacing: -0.02em; }
      .pill { display: inline-block; padding: 6px 10px; border-radius: 999px; border: 1px solid rgba(255,255,255,.18); background: rgba(255,255,255,.08); font-size: 12px; }
      .status { margin-top: 10px; padding: 12px 12px; border-radius: 14px; border: 1px solid rgba(255,255,255,.16); background: rgba(0,0,0,.25); }
      .dot { display:inline-block; width:10px; height:10px; border-radius:999px; background:${statusColor}; margin-right:8px; box-shadow: 0 0 0 5px rgba(255,255,255,.06); }
      .muted { color: rgba(229,231,235,.78); font-size: 12px; line-height: 1.55; margin-top: 10px; }
      a { color: #93c5fd; text-decoration: none; }
      a:hover { text-decoration: underline; }
      code { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; }
    </style>
  </head>
  <body>
    <div class="wrap">
      <div class="box">
        <span class="pill">Host: <code>${escapeHtml(host)}</code></span>
        <h1>${title}</h1>
        <div class="status"><span class="dot"></span>${escapeHtml(hint)}</div>
        <p class="muted">
          Usuario recibido: <code>${escapeHtml(username ?? "")}</code><br />
          Vuelve atrás para repetir el login (o recarga la página del laboratorio).
        </p>
        <p class="muted"><a href="/">Volver al laboratorio</a></p>
      </div>
    </div>
  </body>
</html>`;
}

app.get("/healthz", (_req, res) => res.status(200).send("ok"));

app.post("/login", (req, res) => {
  const username = req.body?.username ?? "";
  const password = req.body?.password ?? "";
  const host = req.headers.host ?? "";
  const ok = username === VALID_USER && password === VALID_PASS;

  res.status(ok ? 200 : 401).type("html").send(page({ ok, username, host }));
});

app.get("/login", (req, res) => {
  const host = req.headers.host ?? "";
  res.status(405).type("html").send(page({ ok: false, username: "", host }));
});

const port = Number(process.env.PORT ?? 3000);
app.listen(port, "0.0.0.0", () => {
  // eslint-disable-next-line no-console
  console.log(`[auth] listening on :${port}`);
});

