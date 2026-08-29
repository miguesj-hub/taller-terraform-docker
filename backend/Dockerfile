# Imagen ligera y con actualizaciones de seguridad frecuentes
FROM node:20-alpine

WORKDIR /app

# Copiar primero solo los manifiestos de dependencias aprovecha la caché
# de capas de Docker: si el código cambia pero package.json no, esta capa
# no se reconstruye.
COPY package*.json ./
RUN npm install --omit=dev

COPY src ./src

EXPOSE 3000

# Buena práctica de producción: no correr el proceso como root.
# La imagen node:*-alpine ya trae un usuario "node" preparado para esto.
USER node

CMD ["npm", "start"]
