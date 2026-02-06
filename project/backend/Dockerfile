# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copier uniquement les fichiers de dépendances pour optimiser le cache
COPY package.json package-lock.json* ./

# Installer toutes les dépendances (devDependencies pour nodemon en dev)
# Cache efficace : cette étape ne sera réexécutée que si package.json change
RUN npm install && npm cache clean --force

# Copier le reste du code source
COPY . .

# Stage 2: Production
FROM node:20-alpine AS production

WORKDIR /app

# Créer un utilisateur non-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copier les node_modules depuis le stage builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copier le code source depuis le stage builder
COPY --from=builder --chown=nodejs:nodejs /app/src ./src
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./

# Passer à l'utilisateur non-root
USER nodejs

EXPOSE 3000

# Utiliser npm run dev pour le développement (nodemon disponible)
# En production, on peut utiliser: CMD ["node", "src/index.js"]
CMD ["npm", "run", "dev"]
