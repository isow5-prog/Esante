# Documentation – API Backend E-sante SN

Cette documentation décrit toutes les API disponibles dans le backend du projet E-sante SN.

### 📚 Fichiers de documentation

| Fichier | Description |
|---------|-------------|
| `documentation.md` | API principales (ce fichier) |
| `documentation_carnet.md` | Carnet de santé des mères |
| `DOCUMENTATION_Authentification.md` | Guide d'authentification |

---

## 📋 Table des matières

1. [Authentification](#1-authentification)
2. [Gestion des Utilisateurs](#2-gestion-des-utilisateurs)
3. [QR Codes](#3-qr-codes)
4. [Mères](#4-mères)
5. [Centres de Santé](#5-centres-de-santé)
6. [Statistiques](#6-statistiques)
7. [Messages de Prévention](#7-messages-de-prévention)

---

## 1. Authentification

### POST `/api/token/`
Connexion avec badge_id et mot de passe.

**Requête :**
```json
{
  "badge_id": "AGENT-XXXXXXXX",
  "password": "motdepasse"
}
```

**Réponse :**
```json
{
  "refresh": "eyJ...",
  "access": "eyJ...",
  "user": {
    "id": 1,
    "badge_id": "AGENT-XXXXXXXX",
    "full_name": "Prénom Nom",
    "role": "HEALTH_WORKER",
    "email": "email@exemple.com"
  }
}
```

### POST `/api/token/refresh/`
Rafraîchir le token d'accès.

### GET `/api/auth/me/`
Récupérer le profil de l'utilisateur connecté.

---

## 2. Gestion des Utilisateurs

> **Permission requise :** Ministère uniquement (`IsMinistry`)

### GET `/api/auth/users/`
Liste tous les utilisateurs avec filtres et statistiques.

**Paramètres de requête :**
| Paramètre | Type | Description |
|-----------|------|-------------|
| `role` | string | Filtrer par rôle (`MINISTRY`, `HEALTH_WORKER`) |
| `search` | string | Rechercher par nom, email ou badge_id |
| `is_active` | boolean | Filtrer par statut actif |

**Réponse :**
```json
{
  "users": [
    {
      "id": 1,
      "badge_id": "AGENT-XXXXXXXX",
      "first_name": "Prénom",
      "last_name": "Nom",
      "full_name": "Prénom Nom",
      "email": "email@exemple.com",
      "role": "HEALTH_WORKER",
      "phone": "77 123 45 67",
      "health_center_id": 1,
      "center": { "id": 1, "name": "Centre X", "city": "Dakar" },
      "is_active": true,
      "date_joined": "2025-11-27T10:00:00Z"
    }
  ],
  "stats": {
    "total": 10,
    "ministry": 2,
    "health_workers": 8,
    "active": 9
  }
}
```

### POST `/api/auth/users/`
Créer un nouvel utilisateur.

**Requête :**
```json
{
  "first_name": "Prénom",
  "last_name": "Nom",
  "email": "email@exemple.com",
  "phone": "77 123 45 67",
  "role": "HEALTH_WORKER",
  "health_center_id": 1,
  "password": "motdepasse123"
}
```

### GET `/api/auth/users/<id>/`
Détail d'un utilisateur.

### PATCH `/api/auth/users/<id>/`
Mise à jour partielle d'un utilisateur.

### DELETE `/api/auth/users/<id>/`
Désactiver un utilisateur (ne supprime pas, met `is_active=false`).

---

## 3. QR Codes

### GET `/api/qr-cards/`
Liste tous les QR codes générés.

### POST `/api/qr-cards/ `
Générer un nouveau QR code.

**Requête (optionnelle) :**
```json
{
  "code": "MON-CODE-PERSO"
}
```

**Réponse :**
```json
{
  "id": 1,
  "code": "QR-XXXXXXXX",
  "status": "pending",
  "image_url": "/media/qr_codes/QR-XXXXXXXX.png",
  "created_at": "2025-11-28T10:00:00Z"
}
```

### POST `/api/qr-cards/validate/`
Valider une carte QR et créer la fiche mère.

> **Permission requise :** Agent de santé uniquement (`IsHealthWorker`)

**Requête :**
```json
{
  "code": "QR-XXXXXXXX",
  "full_name": "Fatou Diallo",
  "address": "Dakar, Médina",
  "phone": "77 123 45 67",
  "birth_date": "1995-03-15",
  "profession": "Commerçante"
}
```

---

## 4. Mères

### GET `/api/mothers/`
Liste complète des mères avec filtres et pagination.

**Paramètres de requête :**
| Paramètre | Type | Description |
|-----------|------|-------------|
| `status` | string | Filtrer par statut QR (`validated`, `pending`) |
| `center` | int | Filtrer par ID du centre |
| `search` | string | Rechercher par nom ou code QR |
| `page` | int | Numéro de page (défaut: 1) |
| `page_size` | int | Taille de page (défaut: 20, max: 100) |

**Réponse :**
```json
{
  "mothers": [
    {
      "id": 1,
      "full_name": "Fatou Diallo",
      "address": "Dakar, Médina",
      "phone": "77 123 45 67",
      "birth_date": "1995-03-15",
      "profession": "Commerçante",
      "qr_code": "QR-XXXXXXXX",
      "qr_status": "validated",
      "center": { "id": 1, "name": "Centre X", "city": "Dakar" },
      "created_at": "2025-11-28T10:00:00Z"
    }
  ],
  "pagination": {
    "total": 100,
    "page": 1,
    "page_size": 20,
    "total_pages": 5
  },
  "stats": {
    "total": 100,
    "validated": 85,
    "pending": 15
  }
}
```

### GET `/api/mothers/recent/`
Les 20 dernières mères inscrites.

### GET `/api/mothers/<id>/`
Détail d'une mère.

### POST `/api/mothers/add-record/`
Ajouter un carnet de santé à une mère existante.

> 📄 Voir **[documentation_carnet.md](./documentation_carnet.md)** pour les détails complets.

---

## 5. Centres de Santé

### GET `/api/centers/`
Liste tous les centres de santé.

**Réponse :**
```json
[
  {
    "id": 1,
    "name": "Centre de Santé Grand-Yoff",
    "code": "CS-GY",
    "city": "Dakar",
    "address": "Rue 10, Grand-Yoff",
    "mothers_count": 45
  }
]
```

### POST `/api/centers/`
Créer un nouveau centre de santé.

**Requête :**
```json
{
  "name": "Centre de Santé Parcelles",
  "code": "CS-PA",
  "city": "Dakar",
  "address": "Parcelles Assainies U17"
}
```

---

## 6. Statistiques

### GET `/api/stats/overview/`
Statistiques générales (tous utilisateurs).

**Réponse :**
```json
{
  "mothers": 150,
  "consultations": 245,
  "children_followed": 78,
  "vaccinations": 312,
  "filles": 42,
  "garcons": 36
}
```

| Champ | Description |
|-------|-------------|
| `mothers` | Nombre total de mères inscrites |
| `consultations` | Nombre total de CPN effectuées |
| `children_followed` | Nombre total d'enfants enregistrés |
| `vaccinations` | Nombre total de vaccinations effectuées |
| `filles` | Nombre de bébés filles |
| `garcons` | Nombre de bébés garçons |

### GET `/api/stats/detailed/`
Statistiques détaillées (ministère uniquement).

> **Permission requise :** Ministère uniquement (`IsMinistry`)

**Paramètres de requête :**
| Paramètre | Type | Description |
|-----------|------|-------------|
| `period` | string | Période (`week`, `month`, `quarter`, `year`) |

**Réponse :**
```json
{
  "global": {
    "mothers": 150,
    "consultations": 245,
    "children_followed": 78,
    "vaccinations": 312,
    "filles": 42,
    "garcons": 36,
    "centers": 5,
    "growth": 12.5
  },
  "monthly": [
    { 
      "month": "Jan", 
      "mothers": 45, 
      "consultations": 120, 
      "children": 15, 
      "vaccinations": 30,
      "filles": 8,
      "garcons": 7
    },
    { 
      "month": "Fév", 
      "mothers": 52, 
      "consultations": 145, 
      "children": 18, 
      "vaccinations": 35,
      "filles": 10,
      "garcons": 8
    }
  ],
  "gender": {
    "filles": 42,
    "garcons": 36,
    "total": 78,
    "pourcentage_filles": 53.8,
    "pourcentage_garcons": 46.2
  },
  "centers": [
    {
      "id": 1,
      "name": "Centre Grand-Yoff",
      "city": "Dakar",
      "mothers": 45,
      "consultations": 120,
      "children": 25,
      "vaccinations": 85,
      "growth": 15
    }
  ],
  "recent_activity": [
    {
      "type": "mother",
      "message": "Nouvelle mère inscrite à Grand-Yoff",
      "time": "Il y a 5 min"
    }
  ]
}
```

#### Détails des champs de réponse :

| Section | Champ | Description |
|---------|-------|-------------|
| **global** | `mothers` | Total mères inscrites |
| | `consultations` | Total CPN effectuées |
| | `children_followed` | Total enfants enregistrés |
| | `vaccinations` | Total vaccinations effectuées |
| | `filles` | Total bébés filles |
| | `garcons` | Total bébés garçons |
| | `centers` | Nombre de centres de santé |
| | `growth` | Croissance en % par rapport à la période précédente |
| **monthly** | - | Évolution mensuelle sur 12 mois |
| | `month` | Mois (Jan, Fév, Mar...) |
| | `mothers` | Mères inscrites ce mois |
| | `consultations` | CPN effectuées ce mois |
| | `children` | Enfants nés ce mois |
| | `vaccinations` | Vaccinations ce mois |
| | `filles` | Filles nées ce mois |
| | `garcons` | Garçons nés ce mois |
| **gender** | - | Répartition par sexe (pour graphiques) |
| | `filles` | Total filles |
| | `garcons` | Total garçons |
| | `total` | Total enfants |
| | `pourcentage_filles` | % de filles |
| | `pourcentage_garcons` | % de garçons |
| **centers** | - | Stats par centre de santé |
| | `vaccinations` | Vaccinations effectuées au centre |

---

## 7. Messages de Prévention

> **Permission requise :** Ministère uniquement (`IsMinistry`)

### GET `/api/messages/`
Liste tous les messages de prévention.

**Paramètres de requête :**
| Paramètre | Type | Description |
|-----------|------|-------------|
| `status` | string | Filtrer par statut (`draft`, `published`, `scheduled`) |
| `category` | string | Filtrer par catégorie (`vaccination`, `prenatal`, `nutrition`, `info`, `urgence`) |
| `search` | string | Rechercher par titre ou contenu |

**Réponse :**
```json
{
  "messages": [
    {
      "id": 1,
      "title": "Campagne de vaccination",
      "content": "Rappel important...",
      "category": "vaccination",
      "category_display": "Vaccination",
      "status": "published",
      "status_display": "Publié",
      "target": "all",
      "target_display": "Tous",
      "author": 1,
      "author_name": "Admin System",
      "scheduled_at": null,
      "published_at": "2025-11-28T10:00:00Z",
      "views_count": 125,
      "created_at": "2025-11-28T09:00:00Z"
    }
  ],
  "stats": {
    "total": 10,
    "published": 5,
    "draft": 3,
    "scheduled": 2,
    "total_views": 1500
  }
}
```

### POST `/api/messages/`
Créer un nouveau message.

**Requête :**
```json
{
  "title": "Nouveau message",
  "content": "Contenu du message...",
  "category": "info",
  "target": "mothers"
}
```

### GET `/api/messages/<id>/`
Détail d'un message (incrémente le compteur de vues).

### PATCH `/api/messages/<id>/`
Mise à jour d'un message.

### DELETE `/api/messages/<id>/`
Supprimer un message.

### POST `/api/messages/<id>/publish/`
Publier un message immédiatement.

---

## 🔧 Modèles de données

### User
| Champ | Type | Description |
|-------|------|-------------|
| `badge_id` | string | Identifiant unique (généré automatiquement pour les agents) |
| `first_name` | string | Prénom |
| `last_name` | string | Nom |
| `email` | string | Email unique |
| `phone` | string | Téléphone |
| `role` | enum | `MINISTRY` ou `HEALTH_WORKER` |
| `health_center_id` | int | ID du centre (pour les agents) |
| `is_active` | bool | Compte actif |

### Mother
| Champ | Type | Description |
|-------|------|-------------|
| `qr_card` | FK | Carte QR associée (OneToOne) |
| `full_name` | string | Nom complet |
| `address` | string | Adresse |
| `phone` | string | Téléphone |
| `birth_date` | date | Date de naissance |
| `profession` | string | Profession |
| `center` | FK | Centre de santé de suivi |

### HealthCenter
| Champ | Type | Description |
|-------|------|-------------|
| `name` | string | Nom du centre |
| `code` | string | Code unique |
| `city` | string | Ville |
| `address` | string | Adresse |

 ### HealthRecord (Carnet de santé)
> 📄 Voir **[documentation_carnet.md](./documentation_carnet.md)** pour les détails complets.

### PreventionMessage
| Champ | Type | Description |
|-------|------|-------------|
| `title` | string | Titre du message |
| `content` | text | Contenu |
| `category` | enum | `vaccination`, `prenatal`, `nutrition`, `info`, `urgence` |
| `status` | enum | `draft`, `published`, `scheduled` |
| `target` | enum | `all`, `mothers`, `agents` |
| `author` | FK | Auteur (utilisateur) |
| `scheduled_at` | datetime | Date de publication programmée |
| `published_at` | datetime | Date de publication effective |
| `views_count` | int | Nombre de vues |

---

## 🔐 Permissions

| Permission | Description |
|------------|-------------|
| `IsAuthenticated` | Utilisateur connecté |
| `IsMinistry` | Utilisateur avec rôle `MINISTRY` |
| `IsHealthWorker` | Utilisateur avec rôle `HEALTH_WORKER` |

---

*Documentation mise à jour le 29/11/2025*

---

## 📊 Résumé des statistiques disponibles

| Donnée | Endpoint | Description |
|--------|----------|-------------|
| Mères inscrites | `/api/stats/overview/` | Total des mères dans le système |
| CPN effectuées | `/api/stats/overview/` | Consultations prénatales complétées |
| Enfants suivis | `/api/stats/overview/` | Total des enfants enregistrés |
| Vaccinations | `/api/stats/overview/` | Total des vaccinations effectuées |
| **Filles** | `/api/stats/overview/` | Nombre de bébés filles |
| **Garçons** | `/api/stats/overview/` | Nombre de bébés garçons |
| Évolution mensuelle | `/api/stats/detailed/` | Tendances sur 12 mois |
| Répartition par sexe | `/api/stats/detailed/` | Pourcentages filles/garçons |
| Stats par centre | `/api/stats/detailed/` | Performance de chaque centre |
