# PARTIE 1 — Diagnostic complet des problèmes

## PROBLÈME 1 : Frontend ne peut pas appeler l'API

### Symptôme
Le frontend essaie d'appeler l'API directement via `http://localhost:3000` au lieu de passer par Nginx.

### Localisation
- **Fichier** : `frontend/src/App.jsx`
- **Ligne 5** : `const API_BASE = "http://localhost:3000";`

### Problème identifié
- Le frontend utilise une URL absolue pointant vers `localhost:3000`
- Dans un navigateur, `localhost:3000` pointe vers la machine hôte, pas vers le conteneur backend
- Le frontend devrait utiliser une URL relative (`/api/...`) pour passer par Nginx (même origine)
- Ou utiliser la variable d'environnement `VITE_API_BASE_URL` qui est définie dans docker-compose mais non utilisée

### Impact
- Les requêtes API échouent depuis le navigateur
-  Violation CORS possible
- Architecture non respectée (devrait passer par Nginx)

---

##  PROBLÈME 2 : Configuration Nginx incorrecte - Backend

### Symptôme
Nginx ne peut pas router les requêtes vers le backend.

### Localisation
- **Fichier** : `nginx/nginx.conf`
- **Ligne 17** : `server backend:5000;`

### Problème identifié
- Nginx pointe vers le port `5000` du backend
- Mais le backend écoute sur le port `3000` (voir `docker-compose.yml` ligne 21 et `backend/src/index.js` ligne 7)
- Le port est incorrect dans la configuration upstream

### Impact
- Toutes les requêtes `/api/*` échouent
- Nginx ne peut pas joindre le backend

---

##  PROBLÈME 3 : Configuration Nginx incorrecte - Frontend

### Symptôme
Nginx ne peut pas router les requêtes vers le frontend.

### Localisation
- **Fichier** : `nginx/nginx.conf`
- **Ligne 12** : `server front:5173;`

### Problème identifié
- Nginx utilise le nom de service `front` 
- Mais dans `docker-compose.yml`, le service s'appelle `frontend` (ligne 33)
- Le nom du service est incorrect

### Impact
-  Nginx ne peut pas résoudre le nom `front`
-  Le frontend n'est pas accessible via Nginx

---

## PROBLÈME 4 : Backend ne peut pas se connecter à la base de données

### Symptôme
Le backend crash ou ne peut pas se connecter à PostgreSQL.

### Localisation
- **Fichier** : `docker-compose.yml`
- **Ligne 24** : `DATABASE_URL: postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:5432/${POSTGRES_DB}`

### Problème identifié
- La `DATABASE_URL` utilise `localhost` comme hostname
- Dans Docker, `localhost` pointe vers le conteneur lui-même, pas vers le service `db`
- Devrait utiliser le nom du service : `db` (ou `m2_db` selon le container_name)
- Le commentaire ligne 23 indique "Volontairement faux : ne doit pas être localhost en Docker"

### Impact
- Le backend ne peut pas se connecter à PostgreSQL
-  Les endpoints `/api/health` et `/api/message` échouent si la DB est requise
-  L'application ne fonctionne pas

---

##  PROBLÈME 5 : Base de données ne répond pas immédiatement

### Symptôme
Le backend démarre avant que PostgreSQL soit prêt à accepter des connexions.

### Localisation
- **Fichier** : `docker-compose.yml`
- **Lignes 27-28** : `depends_on: - db`
- **Ligne 14** : Commentaire "Pas de healthcheck au départ (à ajouter)"

### Problème identifié
- `depends_on` garantit seulement l'ordre de démarrage, pas que le service est prêt
- PostgreSQL peut prendre plusieurs secondes avant d'accepter des connexions
- Pas de healthcheck sur le service `db`
- Pas de condition `service_healthy` dans `depends_on` du backend

### Impact
-  Le backend peut démarrer avant que PostgreSQL soit prêt
-  Erreurs de connexion au démarrage
-  Application instable au démarrage

---

##  PROBLÈME 6 : Pas de healthcheck sur les services

### Symptôme
Aucun mécanisme pour vérifier que les services sont opérationnels.

### Localisation
- **Fichier** : `docker-compose.yml`
- **Services** : `db` (ligne 14), `backend` (ligne 31)

### Problème identifié
- Pas de healthcheck défini pour PostgreSQL
- Pas de healthcheck défini pour le backend API
- Impossible de savoir si les services sont vraiment prêts

### Impact
-  Impossible d'orchestrer correctement les dépendances
-  `depends_on` ne garantit pas la disponibilité
-  Application peut démarrer avec des services non fonctionnels

---

##  PROBLÈME 7 : Credentials exposés en clair

### Symptôme
Les mots de passe sont visibles dans le fichier docker-compose.yml.

### Localisation
- **Fichier** : `docker-compose.yml`
- **Ligne 9** : `POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}`
- **Ligne 24** : Mot de passe dans `DATABASE_URL`

### Problème identifié
- Le mot de passe PostgreSQL est passé via variable d'environnement en clair
- Le mot de passe apparaît dans `DATABASE_URL`
- Pas d'utilisation de Docker secrets
- Le dossier `secrets/` existe mais n'est pas utilisé

### Impact
-  Sécurité compromise
-  Mots de passe potentiellement visibles dans les logs
-  Non conforme aux bonnes pratiques

---

##  PROBLÈME 8 : Dockerfile backend non optimisé

### Symptôme
Rebuild très lent, image volumineuse.

### Localisation
- **Fichier** : `backend/Dockerfile`

### Problèmes identifiés
- `COPY . .` copie tout avant `npm install` (ligne 4)
- Pas de cache efficace pour les dépendances npm
- Pas de multi-stage build
- Probablement exécution en root (pas d'utilisateur non-root)
- Image de base `node:20` complète (non alpine)

### Impact
-  Rebuild lent (télécharge toutes les dépendances à chaque fois)
-  Image volumineuse
-  Sécurité réduite (exécution root)

---

##  PROBLÈME 9 : Dockerfile frontend non optimisé

### Symptôme
Mêmes problèmes que le backend.

### Localisation
- **Fichier** : `frontend/Dockerfile`

### Problèmes identifiés
- Même structure que le backend (non optimisée)
- `COPY . .` avant `npm install`
- Pas de cache efficace
- Pas de multi-stage build

### Impact
-  Rebuild lent
-  Image volumineuse

---

##  PROBLÈME 10 : Variables d'environnement manquantes

### Symptôme
Les variables d'environnement référencées dans docker-compose.yml ne sont pas définies.

### Localisation
- **Fichier** : `docker-compose.yml`
- Variables utilisées : `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `API_PORT`, `NODE_ENV`, `VITE_API_BASE_URL`

### Problème identifié
- Aucun fichier `.env` trouvé dans le projet
- Les variables sont référencées mais non définies
- L'application peut ne pas démarrer correctement

### Impact
- ❌ Services peuvent ne pas démarrer avec les bonnes valeurs
- ❌ Configuration non reproductible

---


##  Prochaines étapes

1. **PARTIE 2** : Corriger les problèmes de configuration Docker Compose
2. **PARTIE 3** : Optimiser les Dockerfiles
3. **PARTIE 4** : Implémenter la gestion des secrets
4. **PARTIE 5** : Ajouter les healthchecks
5. **PARTIE 6** : Optimiser pour le développement

