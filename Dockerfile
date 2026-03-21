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

# Supprimer la config par défaut
RUN rm -f /etc/nginx/conf.d/default.conf

# Copier notre config nginx custom
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copier le build Vite
COPY --from=builder /app/dist /usr/share/nginx/html

# Préparer les répertoires utilisés par nginx
RUN mkdir -p /var/cache/nginx /tmp/nginx \
    && chown -R nginx:nginx /var/cache/nginx /tmp/nginx /usr/share/nginx/html

EXPOSE 8080

USER nginx

CMD ["nginx", "-g", "daemon off;"]
