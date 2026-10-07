# Empaqueta un build web YA compilado (flutter build web --release
# --base-href /mobile/app/) en nginx. No compila Flutter: el workflow lo hace
# con el SDK pineado de CI y no hay imagen pública de Flutter 3.47.
FROM nginx:alpine

ARG APP_VERSION=dev

COPY build/web /usr/share/nginx/html/app
COPY deploy/preview.html /usr/share/nginx/html/index.html
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf

RUN sed -i "s/__APP_VERSION__/${APP_VERSION}/" /usr/share/nginx/html/index.html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
