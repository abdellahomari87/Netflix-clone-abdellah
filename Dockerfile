FROM node:16.17.0-alpine AS builder

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .

ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

RUN yarn build


FROM nginx:stable-alpine

# Remplacer complètement la conf principale nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copier le build frontend
COPY --from=builder /app/dist /usr/share/nginx/html

# Préparer les répertoires nécessaires
RUN mkdir -p /var/cache/nginx \
    /tmp/nginx/client_temp \
    /tmp/nginx/proxy_temp \
    /tmp/nginx/fastcgi_temp \
    /tmp/nginx/uwsgi_temp \
    /tmp/nginx/scgi_temp \
    && chown -R nginx:nginx /var/cache/nginx /tmp/nginx /usr/share/nginx/html

EXPOSE 8080

USER nginx

CMD ["nginx", "-g", "daemon off;"]
