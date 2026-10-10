# Sitio verificame.co — despliegue

Sitio estático (nginx + 3 páginas: inicio, términos, privacidad) pensado para desplegarse
en tu VPS con Dokploy, igual que ya tienes vmenus.co.

## Antes de publicar

Reemplaza estos marcadores (resaltados en verde) en `privacidad.html`, `terminos.html` y `eliminacion-datos.html`:

- `[RAZÓN SOCIAL COMPLETA DE VERIFÍCAME]` → nombre legal exacto (ej. "Verifícame S.A.S.")
- `[NIT]` → NIT de la empresa
- `[CIUDAD, COLOMBIA]` → ciudad de domicilio
- `[correo@verificame.co]` → correo real de contacto/privacidad
- `[FECHA]` → fecha en que publicas cada documento (ej. "11 de agosto de 2026")

Y en `index.html`:

- `[NUMERO_WHATSAPP]` (aparece dos veces) → tu número en formato internacional sin signos,
  ej. `573001234567`, para que los botones de WhatsApp abran el chat correcto.

Esto importa porque Meta valida que la política de privacidad describa con precisión
a la empresa detrás de la app, y porque legalmente el documento debe identificar
correctamente al responsable del tratamiento.

## Sobre el formulario de contacto

No incluí un formulario que "envía" datos a ningún lado — sería un formulario que aparenta
funcionar pero no llega a ningún sitio, porque este es un sitio estático sin backend. En su
lugar, el CTA final usa un botón de WhatsApp (clic-to-chat) y un `mailto:`, que sí funcionan
sin necesidad de servidor. Si más adelante quieres un formulario real, se puede conectar a un
servicio externo (Formspree, o un webhook a tu propio n8n) — lo vemos cuando quieras.

## Enlaces de reseña (`/r/`)

`verificame.co/r/<código>` no es una página de este sitio: `nginx.conf` lo reenvía a la
función `r` de Supabase (proyecto `verificame-core`), que es del producto V Reviews. Registra
el clic y redirige a la página de reseñas de Google del restaurante. Este sitio sigue sin
backend propio; si el reenvío falla, solo se caen esos enlaces, no las páginas.

Después de desplegar un cambio en `nginx.conf`, comprobar que la regla funciona (con un
código inventado debe contestar **404 «Enlace no válido»**, que viene de la función):

```bash
curl -i https://verificame.co/r/zzzzzzzzzzzz
```

Y que las páginas de siempre siguen respondiendo (`/`, `/privacidad`, `/terminos`).

## Páginas incluidas

- `/` — landing
- `/terminos` — términos y condiciones
- `/privacidad` — política de tratamiento de datos (Ley 1581)
- `/eliminacion-datos` — instrucciones de eliminación de datos (Meta también la exige en el
  App Dashboard como URL separada de la de privacidad)

## Opción A — Dokploy (recomendada, misma ruta que vmenus.co)

1. Sube esta carpeta a un repositorio de Git (GitHub/GitLab), o a uno privado si prefieres.
2. En Dokploy: **Create → Application**, conecta el repo.
3. Build type: **Dockerfile** (ya está incluido en la carpeta, no necesitas configurar nada más).
4. En **Domains**, agrega `verificame.co` (y `www.verificame.co` si lo vas a usar) y activa
   HTTPS — Dokploy pedirá el certificado a Let's Encrypt automáticamente, igual que con
   vmenus.co.
5. Deploy. Con eso quedan activas:
   - `verificame.co/`
   - `verificame.co/terminos`
   - `verificame.co/privacidad`

## Opción B — manual por SSH (si quieres saltarte el paso de Git)

```bash
# En tu VPS, dentro de la carpeta del proyecto
docker build -t verificame-web .
docker network ls   # confirma el nombre de la red que usa tu Traefik/Dokploy

docker run -d \
  --name verificame-web \
  --network <TU_RED_DE_TRAEFIK> \
  --label "traefik.enable=true" \
  --label "traefik.http.routers.verificame.rule=Host(\`verificame.co\`)" \
  --label "traefik.http.routers.verificame.entrypoints=websecure" \
  --label "traefik.http.routers.verificame.tls.certresolver=letsencrypt" \
  --label "traefik.http.services.verificame.loadbalancer.server.port=80" \
  --restart unless-stopped \
  verificame-web
```

Ajusta el nombre de la red y del certresolver a como estén configurados en tu Traefik
actual (los mismos que usa vmenus.co). Esta ruta es más rápida para una prueba, pero
la Opción A es más fácil de mantener cuando conviertas `index.html` en la landing
completa de los proyectos.

## Siguiente paso

Cuando quieras, seguimos con la landing completa de `index.html` (resumen de VFoodie,
VMenus y el servicio de marketing) — por ahora dejé un placeholder simple y funcional
para no bloquear el registro en Meta.
