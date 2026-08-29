# Etapa 1: compilar el bundle estático de React con Vite
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Etapa 2: servir SOLO los archivos estáticos compilados con Nginx.
# La imagen final no contiene Node.js, npm ni el código fuente: es más
# pequeña y tiene menos superficie de ataque (buena práctica de producción).
FROM nginx:1.27-alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
