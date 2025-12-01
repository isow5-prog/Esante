# 📚 Documentation Complète du Projet E-sante SN

## 🏁 Introduction

Bonjour ! 👋 Je vais t'expliquer tout ce que nous avons fait pour créer le système de connexion de l'application E-sante SN. C'est comme si on construisait une grande maison, mais au lieu de briques, on utilise du code !

## 🏗️ 1. La Structure de la Maison (Architecture)

Imagine que notre application est comme une grande maison avec plusieurs pièces :

- **Le Salon (Backend)** : C'est là que tout se passe en coulisses
- **La Cuisine (Base de données)** : Où on range toutes les informations
- **La Porte d'Entrée (Authentification)** : Pour s'assurer que seules les bonnes personnes entrent
- **Les Chambres (Différentes parties de l'application)** : Chacune a un rôle spécifique

## 🧱 2. Les Fondations (Modèle Utilisateur)

Nous avons créé un modèle spécial pour les utilisateurs, comme une fiche d'identité pour chaque personne qui utilise l'application :

- **badge_id** : Comme un numéro de badge unique pour chaque agent de santé
- **rôle** : Pour savoir si c'est un agent de santé ou quelqu'un du ministère
- **email** et **téléphone** : Pour pouvoir les contacter
- **centre de santé** : Pour savoir où travaille l'agent

## 🔑 3. Le Système de Clé (Authentification)

Pour entrer dans la maison, il faut une clé spéciale (comme un badge) :

- On utilise le `badge_id` et un mot de passe pour se connecter
- Si c'est bon, on reçoit un jeton (comme un ticket d'entrée) qu'on montre à chaque fois qu'on veut faire quelque chose
- Ce jeton expire au bout d'un moment pour la sécurité

## 📝 4. Les Formulaires (Sérialiseurs)

C'est comme des fiches à remplir pour demander quelque chose :

- Une fiche pour se connecter (avec badge et mot de passe)
- Une fiche pour voir son profil
- Une fiche pour voir la liste des utilisateurs (seulement pour les administrateurs)

## 🚪 5. Les Portes d'Entrée (Vues)

Ce sont comme des réceptionnistes qui vérifient ce qu'on peut faire :

- Un réceptionniste pour la connexion
- Un pour voir son profil
- Un pour voir la liste des utilisateurs (uniquement pour le ministère)

## 🛣️ 6. Les Couloirs (URLs)

Ce sont comme les chemins pour aller dans chaque pièce :

- `/api/token/` → Pour se connecter
- `/api/token/refresh/` → Pour rafraîchir son jeton
- `/api/auth/me/` → Pour voir son profil
- `/api/users/` → Pour voir la liste des utilisateurs (admin seulement)

## 🛡️ 7. Les Gardes du Corps (Sécurité)

Pour que personne de méchant ne puisse entrer :

- Les mots de passe sont toujours cryptés (comme dans un coffre-fort)
- Les jetons expirent après un certain temps
- Certaines actions ne sont possibles que pour certains rôles

## ✉️ 8. Le Service Courrier (Emails)

Quand un nouvel utilisateur arrive :

- On lui envoie un email de bienvenue
- On peut aussi envoyer des emails pour réinitialiser les mots de passe
- Tout est bien organisé avec des modèles d'emails jolis

## 📊 9. Le Journal de Bord (Logs)

On garde une trace de tout ce qui se passe :

- Qui s'est connecté
- Quelles actions ont été faites
- S'il y a eu des problèmes

## 🛠️ 10. Comment Faire Foncer Tout Ça ?

### Installation

1. **Installer les outils nécessaires** :
   ```bash
   pip install -r requirements.txt
   ```

2. **Préparer la base de données** :
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

3. **Créer un compte administrateur** :
   ```bash
   python manage.py createsuperuser
   ```

4. **Lancer le serveur** :
   ```bash
   python manage.py runserver
   ```

## 🔐 Authentification JWT

### 🎮 Explication Simple (Comme si tu avais 10 ans) 🎮

Imagine que l'API est une forteresse magique 🏰 :

1. **Ton badge_id et ton mot de passe** sont comme une carte d'identité avec un code secret qui prouve que c'est bien toi.

2. **Le jeton d'accès (access token)** est comme un badge de visiteur :
   - 🎫 Il te permet d'entrer dans la forteresse
   - ⏳ Il expire au bout d'un certain temps (comme un badge d'un jour)
   - 🚪 Tu dois le montrer à chaque porte (requête API)

3. **Le jeton de rafraîchissement (refresh token)** est comme une machine à badges :
   - 🔄 Quand ton badge expire, tu peux en avoir un nouveau
   - 🔒 Tu n'as pas besoin de retaper ton mot de passe à chaque fois

### 📝 Comment ça marche techniquement ?

L'API utilise JWT (JSON Web Tokens) pour l'authentification. Quand tu te connectes, tu reçois deux jetons :

1. **Jeton d'accès (access token)** :
   - Utilisé pour accéder aux routes protégées
   - Durée de vie courte (15 minutes par défaut)
   - À envoyer dans l'en-tête `Authorization: Bearer <token>`

2. **Jeton de rafraîchissement (refresh token)** :
   - Permet d'obtenir un nouveau jeton d'accès
   - Durée de vie plus longue (1 jour par défaut)
   - À envoyer à `/api/token/refresh/` pour un nouveau jeton d'accès

### 🧪 Comment tester ?

1. **Se connecter** :
   ```http
   POST /api/auth/token/
   Content-Type: application/json
   
   {
       "badge_id": "TON_BADGE_ID",
       "password": "TON_MOT_DE_PASSE"
   }
   ```
   
   Réponse réussie :
   ```json
   {
       "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
       "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
       "user": {
           "id": 1,
           "badge_id": "ADMIN-001",
           "full_name": "Admin System",
           "role": "MINISTRY",
           "email": "admin@example.com"
       }
   }
   ```

2. **Utiliser le jeton d'accès** :
   ```http
   GET /api/auth/me/
   Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
   ```

3. **Rafraîchir le jeton** (quand il expire) :
   ```http
   POST /api/token/refresh/
   Content-Type: application/json
   
   {
       "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
   }
   ```

### 🔒 Bonnes pratiques de sécurité

- **Ne jamais** exposer les jetons dans le code client
- **Toujours** utiliser HTTPS en production
- **Stocker** les jetons de manière sécurisée (HttpOnly cookies, Secure Storage)
- **Rafraîchir** régulièrement les jetons d'accès
- **Révoker** les jetons compromis immédiatement

## 🔍 Exemple Pratique

Voici à quoi ressemble une demande de connexion :

```http
POST /api/auth/token/
Content-Type: application/json

{
    "badge_id": "AGENT-ABC123",
    "password": "motdepassesecurise"
}
```

Et la réponse si tout va bien :

```json
{
    "refresh": "le_token_de_rafraichissement",
    "access": "le_token_d_acces"
}
```

## 🎉 Félicitations !

Tu as maintenant une compréhension complète de comment fonctionne le système d'authentification d'E-sante SN. C'est comme avoir les plans détaillés de notre maison !

N'hésite pas à poser des questions si quelque chose n'est pas clair. 😊
