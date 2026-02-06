# TP ÉVALUATION — Advanced Docker Debugging & Architecture (5h)
Master 2 — Développement Web

---

## Contexte

Vous rejoignez une équipe ayant quitté un projet web en urgence.

Une stack Docker existe déjà mais :

- l'application ne fonctionne pas correctement
- plusieurs erreurs runtime sont présentes
- la configuration n'est pas sécurisée
- les performances sont mauvaises

Votre mission :

Analyser, corriger et améliorer la stack existante afin d'obtenir une application fonctionnelle et robuste.

---

## Important

Aucune solution détaillée ne sera fournie.

Vous devez :

- analyser
- comprendre
- tester
- corriger

---

## Stack fournie

Une archive contient :

```
project/
│
├── docker-compose.yml
├── frontend/        (React)
├── backend/         (Node API)
├── nginx/
└── secrets/
```

---

## Architecture cible attendue

```
Browser
   |
Nginx (reverse proxy)
   |
Frontend (React)
   |
Backend API (Node.js)
   |
PostgreSQL
```

---

## État actuel (volontairement problématique)

Sans modification :

- frontend accessible mais API ne répond pas
- backend crash parfois
- base de données instable
- rebuild très lent
- credentials exposés
- healthchecks inexistants

---

## Durée

5 heures

---

## PARTIE 1 — Diagnostic complet (30 min)

Identifier :

- pourquoi le frontend ne peut pas appeler l'API
- pourquoi la base de données ne répond pas immédiatement
- quels services ne communiquent pas correctement

Livrable :

- liste des problèmes identifiés

---

## PARTIE 2 — Debugging Docker Compose (1h)

Corriger :

- réseaux Docker
- ports incorrects
- variables d’environnement invalides
- dépendances entre services

Contraintes :

- ne pas supprimer de services
- architecture globale conservée

---

## PARTIE 3 — Dockerfile avancé backend (1h)

Le backend possède un Dockerfile non optimisé.

Objectifs :

- réduire taille image
- améliorer cache build
- ajouter multi-stage build
- exécution non-root

---

## PARTIE 4 — Gestion des secrets (45 min)

Actuellement :

- mot de passe DB visible dans compose

Objectifs :

- supprimer credentials en clair
- utiliser Docker secrets
- adaptation backend si nécessaire

---

## PARTIE 5 — Healthchecks et résilience (45 min)

Ajouter :

- healthcheck PostgreSQL
- healthcheck backend API
- dépendances conditionnelles

Attendu :

- application démarre même si DB lente

---

## PARTIE 6 — Optimisation développeur (30 min)

Améliorer :

- rebuild rapide
- hot reload fonctionnel
- cache npm efficace

---

## BONUS — Diagnostic expert (30 min)

Identifier :

- pourquoi COPY . . est dangereux
- pourquoi depends_on ne suffit pas
- pourquoi une image node officielle peut être mauvaise par défaut

---

## Critères d’évaluation

| Compétence | Points |
|---|---|
| Diagnostic architecture | 5 |
| Debugging Compose | 5 |
| Dockerfile avancé | 4 |
| Secrets sécurisés | 3 |
| Healthchecks | 3 |

---

## Contraintes

- utilisation de Docker Compose obligatoire
- aucune installation locale runtime (Node, Postgres…)
- solution reproductible

---

## Attendus implicites

- comprendre networking Docker
- comprendre startup order
- comprendre layers Docker
- comprendre secrets vs env
