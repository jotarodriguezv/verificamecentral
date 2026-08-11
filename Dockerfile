FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html terminos.html privacidad.html eliminacion-datos.html styles.css /usr/share/nginx/html/

EXPOSE 80
