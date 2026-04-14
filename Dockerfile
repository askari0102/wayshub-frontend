# ------ Stage 1: Build ------
FROM node:14-alpine AS builder
WORKDIR /app
# Cache package
COPY package*.json ./

# Install dependecy tanpa audit/fund dan hapus cache npm
RUN npm install --no-audit --no-fund && npm cache clean --force

# Hanya copy source code utama
COPY public/ ./public
COPY src/ ./src
RUN npm run build

# ------ Stage 2: Serve pakai nginx ------
FROM nginx:stable-alpine

# Buat user non-root agar container tidak jalan sebagai root
RUN addgroup -g 10001 -S frontendgroup && \
    adduser -u 10001 -S frontenduser -G frontendgroup

# Berikan akses folder sistem Nginx ke user non-root
RUN touch /var/run/nginx.pid && \
    chown -R 10001:10001 /var/run/nginx.pid /var/cache/nginx /var/log/nginx /etc/nginx/conf.d

# Copy hasil build dan config
COPY --from=builder --chown=10001:10001 /app/build /usr/share/nginx/html
COPY --chown=10001:10001 nginx.conf /etc/nginx/conf.d/default.conf

# Pindah ke user
USER frontenduser

EXPOSE 80
# Jalankan nginx di foreground agar container tidak mati
CMD ["nginx", "-g", "daemon off;"]