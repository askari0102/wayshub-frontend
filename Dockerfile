# Stage 1 - Build
FROM node:14-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install --no-audit --no-fund && npm cache clean --force
COPY public/ ./public
COPY src/ ./src
RUN npm run build

# Stage 2 - Serve pakai nginx
FROM nginx:stable-alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]