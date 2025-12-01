# 📱 API Mobile - Application Flutter des Mamans

Cette documentation décrit les endpoints de l'API mobile pour l'application Flutter des mamans.

---

## 🔗 Base URL

```
http://localhost:8000/api/mobile/
```

---

## 📋 Endpoints disponibles

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/auth/qr-login/` | Connexion par scan QR code |
| POST | `/verify-qr/` | Vérifier un QR code |
| GET | `/profile/` | Récupérer le profil complet |
| PATCH | `/profile/` | Mettre à jour le profil |
| GET | `/health-record/` | Récupérer le carnet de santé |
| GET | `/messages/` | Récupérer les messages de prévention |

---

## 🔐 Authentification par QR Code

### POST `/api/mobile/auth/qr-login/`

La maman scanne son QR code pour se connecter. L'app reçoit un token JWT.

**Corps de la requête :**
```json
{
    "qr_code": "QR-ABC12345"
}
```

**Réponse succès (200) :**
```json
{
    "success": true,
    "message": "Bienvenue Awa Diallo !",
    "tokens": {
        "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
    },
    "mother": {
        "id": 1,
        "full_name": "Awa Diallo",
        "address": "Dakar, Medina",
        "phone": "77 123 45 67",
        "birth_date": "1990-05-15",
        "profession": "Commerçante",
        "qr_card": {
            "code": "QR-ABC12345",
            "status": "validated",
            "image_url": "http://localhost:8000/media/qr_codes/QR-ABC12345.png",
            "created_at": "2025-11-20T10:30:00Z"
        },
        "center": {
            "id": 1,
            "name": "Centre de santé Medina",
            "city": "Dakar",
            "address": "Rue 10, Medina"
        },
        "health_record": {
            "id": 1,
            "father_name": "Moussa Diallo",
            "father_phone": "77 987 65 43",
            "father_profession": "Mécanicien",
            "pere_carnet_center": "CSD Médina",
            "identification_code": "ID-2025-001",
            "birth_center_detail": null,
            "birth_center_name": "",
            "allocation_info": "",
            "created_by_name": "Sage-femme Fatou",
            "created_at": "2025-11-20T11:00:00Z",
            "updated_at": "2025-11-20T11:00:00Z"
        },
        "created_at": "2025-11-20T10:45:00Z",
        "updated_at": "2025-11-20T11:00:00Z"
    }
}
```

**Erreurs possibles :**

- **400** - QR code manquant
- **400** - QR code inexistant : `{"qr_code": ["Code QR invalide ou inexistant."]}`
- **400** - Carte non activée : `{"qr_code": ["Cette carte n'a pas encore été activée par un agent de santé."]}`
- **400** - Pas de mère associée : `{"qr_code": ["Aucune mère n'est associée à cette carte."]}`

---

## ✅ Vérification QR Code

### POST `/api/mobile/verify-qr/`

Vérifie si un QR code est valide avant de faire le login complet.

**Corps de la requête :**
```json
{
    "qr_code": "QR-ABC12345"
}
```

**Réponses possibles :**

**QR code valide :**
```json
{
    "valid": true,
    "status": "active",
    "mother_name": "Awa Diallo",
    "message": "Carte active pour Awa Diallo"
}
```

**QR code inexistant :**
```json
{
    "valid": false,
    "status": "unknown",
    "message": "Ce QR code n'existe pas dans notre système."
}
```

**Carte non activée :**
```json
{
    "valid": false,
    "status": "pending",
    "message": "Cette carte n'a pas encore été activée. Veuillez consulter un agent de santé."
}
```

**Pas de mère associée :**
```json
{
    "valid": false,
    "status": "no_mother",
    "message": "Aucune mère n'est associée à cette carte."
}
```

---

## 👤 Profil de la Maman

### GET `/api/mobile/profile/`

Récupère le profil complet de la maman connectée.

**Headers requis :**
```
Authorization: Bearer <access_token>
```

**Alternative pour tests :** Query parameter `?qr_code=QR-ABC12345`

**Réponse (200) :**
```json
{
    "id": 1,
    "full_name": "Awa Diallo",
    "address": "Dakar, Medina",
    "phone": "77 123 45 67",
    "birth_date": "1990-05-15",
    "profession": "Commerçante",
    "qr_card": { ... },
    "center": { ... },
    "health_record": { ... },
    "created_at": "2025-11-20T10:45:00Z",
    "updated_at": "2025-11-20T11:00:00Z"
}
```

### PATCH `/api/mobile/profile/`

Met à jour le profil de la maman (téléphone, adresse).

**Headers requis :**
```
Authorization: Bearer <access_token>
```

**Corps de la requête :**
```json
{
    "phone": "77 111 22 33",
    "address": "Dakar, Plateau"
}
```

**Réponse (200) :**
```json
{
    "success": true,
    "message": "Profil mis à jour",
    "data": { ... profil complet ... }
}
```

---

## 📋 Carnet de Santé

### GET `/api/mobile/health-record/`

Récupère le carnet de santé de la maman.

**Headers requis :**
```
Authorization: Bearer <access_token>
```

**Alternative pour tests :** Query parameter `?qr_code=QR-ABC12345`

**Réponse avec carnet (200) :**
```json
{
    "has_record": true,
    "mother_name": "Awa Diallo",
    "health_record": {
        "id": 1,
        "father_name": "Moussa Diallo",
        "father_phone": "77 987 65 43",
        "father_profession": "Mécanicien",
        "pere_carnet_center": "CSD Médina",
        "identification_code": "ID-2025-001",
        "birth_center_detail": {
            "id": 2,
            "name": "Maternité Ile de Gorée",
            "city": "Dakar",
            "address": ""
        },
        "birth_center_name": "",
        "allocation_info": "Allocation familiale",
        "created_by_name": "Sage-femme Fatou",
        "created_at": "2025-11-20T11:00:00Z",
        "updated_at": "2025-11-20T11:00:00Z"
    }
}
```

**Réponse sans carnet (200) :**
```json
{
    "has_record": false,
    "message": "Aucun carnet de santé n'a encore été créé pour cette maman."
}
```

---

## 📢 Messages de Prévention

### GET `/api/mobile/messages/`

Récupère les messages de prévention destinés aux mamans.

**Réponse (200) :**
```json
{
    "count": 5,
    "messages": [
        {
            "id": 1,
            "title": "Importance de l'acide folique",
            "content": "L'acide folique est essentiel pour le développement du bébé...",
            "category": "prenatal",
            "category_display": "Prénatal",
            "published_at": "2025-11-25T09:00:00Z"
        },
        {
            "id": 2,
            "title": "Rappel vaccination",
            "content": "N'oubliez pas le vaccin antitétanique...",
            "category": "vaccination",
            "category_display": "Vaccination",
            "published_at": "2025-11-24T14:30:00Z"
        }
    ]
}
```

---

## 🔄 Flux complet d'utilisation

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUX APPLICATION MAMAN                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. SCAN QR CODE                                                │
│     └─> POST /verify-qr/     (vérifier que la carte est ok)     │
│                                                                 │
│  2. CONNEXION                                                   │
│     └─> POST /auth/qr-login/ (obtenir tokens + profil)          │
│                                                                 │
│  3. PAGE ACCUEIL (données du profil)                            │
│     ├─ Nom de la maman                                          │
│     ├─ QR code à afficher                                       │
│     ├─ Centre de suivi                                          │
│     └─ Prochain RDV (à implémenter)                             │
│                                                                 │
│  4. PAGE CARNET                                                 │
│     └─> GET /health-record/  (infos du père, identification)    │
│                                                                 │
│  5. PAGE MESSAGES                                               │
│     └─> GET /messages/       (conseils prévention)              │
│                                                                 │
│  6. PAGE PROFIL                                                 │
│     └─> GET /profile/        (données complètes)                │
│     └─> PATCH /profile/      (mise à jour téléphone/adresse)    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔗 Cohérence avec le Backend

### Lien avec les autres APIs

| Action Agent de Santé | Impact côté Maman |
|----------------------|-------------------|
| Valide carte QR (`POST /qr-cards/{id}/validate/`) | Maman peut se connecter |
| Crée fiche Mother (`POST /qr-cards/{id}/validate/`) | Maman voit ses infos |
| Ajoute carnet (`POST /mothers/add-record/`) | Maman voit son carnet |
| Publie message (`POST /messages/{id}/publish/`) | Maman reçoit le message |

### Schéma des relations

```
┌──────────────┐      ┌───────────┐      ┌───────────────┐
│   QRCodeCard │──────│   Mother  │──────│  HealthRecord │
│              │ 1:1  │           │ 1:1  │               │
│ • code       │      │ • full_name│     │ • father_name │
│ • status     │      │ • phone    │     │ • identif_code│
│ • image      │      │ • center   │     │ • created_by  │
└──────────────┘      └───────────┘      └───────────────┘
```

---

## 🧪 Tester avec cURL

**1. Vérifier un QR code :**
```bash
curl -X POST http://localhost:8000/api/mobile/verify-qr/ \
  -H "Content-Type: application/json" \
  -d '{"qr_code": "QR-ABC12345"}'
```

**2. Se connecter :**
```bash
curl -X POST http://localhost:8000/api/mobile/auth/qr-login/ \
  -H "Content-Type: application/json" \
  -d '{"qr_code": "QR-ABC12345"}'
```

**3. Récupérer le profil (avec token) :**
```bash
curl -X GET http://localhost:8000/api/mobile/profile/ \
  -H "Authorization: Bearer <access_token>"
```

**4. Récupérer le profil (sans token, pour tests) :**
```bash
curl -X GET "http://localhost:8000/api/mobile/profile/?qr_code=QR-ABC12345"
```

**5. Récupérer les messages :**
```bash
curl -X GET http://localhost:8000/api/mobile/messages/
```

---

## 📱 Intégration Flutter

### Exemple de service API en Dart

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class MobileApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/mobile'; // Pour émulateur Android
  
  String? _accessToken;
  
  Future<Map<String, dynamic>> loginWithQR(String qrCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/qr-login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'qr_code': qrCode}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['tokens']['access'];
      return data;
    }
    throw Exception('Erreur de connexion');
  }
  
  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur de récupération du profil');
  }
  
  Future<Map<String, dynamic>> getHealthRecord() async {
    final response = await http.get(
      Uri.parse('$baseUrl/health-record/'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur de récupération du carnet');
  }
  
  Future<List<dynamic>> getMessages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['messages'];
    }
    throw Exception('Erreur de récupération des messages');
  }
}
```

