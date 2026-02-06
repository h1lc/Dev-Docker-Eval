# Résumé des modifications - TP Docker Evaluation

## PARTIE 1 - Diagnostic
Fichier créé : `PARTIE1_DIAGNOSTIC.md` avec liste complète des problèmes identifiés.

## PARTIE 2 - Debugging Docker Compose

### Modifications dans `docker-compose.yml` :
- **DATABASE_URL** : `localhost` → `db` (ligne 23)
- Réseaux Docker : vérifiés et corrects
- Ports : vérifiés et corrects
- Dépendances : vérifiées et correctes

## PARTIE 3 - Dockerfile backend optimisé 

### Modifications dans `backend/Dockerfile` :
- Multi-stage build (builder + production)
- Cache optimisé : `package.json` copié avant `COPY . .`
- Image Alpine : `node:20-alpine` au lieu de `node:20`
- Exécution non-root : utilisateur `nodejs` créé
- Nettoyage du cache npm

## PARTIE 4 - Gestion des secrets 

### Fichiers secrets créés :
- `secrets/postgres_user.txt` : `postgres`
- `secrets/postgres_db.txt` : `m2_eval`
- `secrets/postgres_password.txt` : `secure_password_123`
- Fichiers `.sample.txt` correspondants créés

### Modifications dans `docker-compose.yml` :
- Service `db` : utilise `POSTGRES_USER_FILE`, `POSTGRES_DB_FILE`, `POSTGRES_PASSWORD_FILE`
- Service `backend` : utilise `POSTGRES_USER_FILE`, `POSTGRES_DB_FILE`, `POSTGRES_PASSWORD_FILE`
- Section `secrets` : définie avec les 3 secrets
- Script d'entrypoint : `docker-entrypoint-secrets.sh` créé pour PostgreSQL

### Modifications dans `backend/src/index.js` :
- Fonction `readSecret()` pour lire les fichiers secrets
- Fonction `buildDatabaseUrl()` qui lit tous les secrets depuis les fichiers `_FILE`
- Masquage du mot de passe dans les logs

## PARTIE 5 - Healthchecks et résilience 

### Modifications dans `docker-compose.yml` :

#### Healthcheck PostgreSQL :
```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres} || exit 1"]
  interval: 5s
  timeout: 3s
  retries: 5
  start_period: 10s
```

#### Healthcheck backend API :
```yaml
healthcheck:
  test: ["CMD-SHELL", "node -e \"require('http').get('http://localhost:3000/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)}).on('error', () => process.exit(1))\" || exit 1"]
  interval: 10s
  timeout: 5s
  retries: 3
  start_period: 15s
```

#### Dépendances conditionnelles :
- `backend` → `db` : `condition: service_healthy`
- `frontend` → `backend` : `condition: service_healthy`
- `nginx` → `backend` : `condition: service_healthy`
- `nginx` → `frontend` : `condition: service_started`

## PARTIE 6 - Optimisation développeur 

### Modifications dans `frontend/Dockerfile` :
- ✅ Cache optimisé : `package.json` copié avant `COPY . .`
- ✅ Image Alpine : `node:20-alpine`
- ✅ Nettoyage du cache npm

### Modifications dans `docker-compose.yml` :
- **Volumes pour hot reload backend** :
  - `./backend/src:/app/src`
  - `backend_node_modules:/app/node_modules` (volume nommé)
  
- **Volumes pour hot reload frontend** :
  - `./frontend/src:/app/src`
  - `./frontend/index.html:/app/index.html`
  - `./frontend/vite.config.js:/app/vite.config.js`
  - `frontend_node_modules:/app/node_modules` (volume nommé)

## Corrections supplémentaires (problèmes PARTIE 1) 

### Modifications dans `nginx/nginx.conf` :
- `front:5173` → `frontend:5173` (nom de service corrigé)
- `backend:5000` → `backend:3000` (port corrigé)
- Amélioration des headers proxy

### Modifications dans `frontend/src/App.jsx` :
- `http://localhost:3000` → URL relative `""` (passe par Nginx)
- Les requêtes API utilisent maintenant `/api/...` via Nginx

## Résultat final

###  Fonctionnalités :
- Stack fonctionnelle et reproductible
- Secrets gérés via Docker secrets (pas de credentials en clair)
- Healthchecks sur PostgreSQL et backend API
- Dépendances conditionnelles (service_healthy)
- Hot reload fonctionnel (volumes montés)
- Cache npm efficace (rebuild rapide)

###  Architecture :
- Nginx (reverse proxy) sur port 8080
- Frontend accessible via Nginx
- Backend accessible via Nginx (`/api/*`)
- PostgreSQL avec persistance (volume)
- Réseaux Docker correctement configurés

### Sécurité :
- Pas de credentials en clair
- Utilisation de Docker secrets
- Exécution non-root (backend)
- Images Alpine (plus légères et sécurisées)

###  Performance :
- Multi-stage builds
- Cache Docker optimisé
- Volumes nommés pour node_modules
- Hot reload sans rebuild

## Commandes de test

```bash
# Démarrer la stack
docker compose up -d --build

# Vérifier l'état des services
docker compose ps

# Voir les logs
docker compose logs -f --tail=200

# Vérifier les healthchecks
docker compose ps

# Accéder à l'application
# http://localhost:8080 (via Nginx)
# http://localhost:5173 (frontend direct)
# http://localhost:3000 (API direct)
```

## Variables d'environnement nécessaires

Créer un fichier `.env` à la racine du projet `project/` :

```env
POSTGRES_DB=m2_eval
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secure_password_123
API_PORT=3000
NODE_ENV=development
VITE_API_BASE_URL=/api
```

**Note** : Les valeurs POSTGRES_* sont aussi dans les fichiers secrets, mais certaines variables peuvent être nécessaires pour d'autres usages.

