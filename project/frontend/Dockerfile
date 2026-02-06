FROM node:20-alpine

WORKDIR /app

# Copier uniquement les fichiers de dépendances pour optimiser le cache
COPY package.json package-lock.json* ./

# Installer les dépendances (cache efficace : cette étape ne sera réexécutée que si package.json change)
RUN npm install && npm cache clean --force

# Copier le reste du code source
COPY . .

EXPOSE 5173
CMD ["npm", "run", "dev"]
