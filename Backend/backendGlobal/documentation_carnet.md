# 📋 Documentation - Carnet de Santé

**PRINCIPE : TOUT passe par le QR code !**

La sage-femme scanne le QR code de la maman et peut tout faire.
Elle travaille automatiquement avec la **grossesse en cours**.

---

## 🔗 Base URL

```
/api/carnet/
```

---

## 📱 Point d'entrée principal

### POST `/api/carnet/scan/`

**La sage-femme scanne le QR code → Elle voit TOUT le dossier.**

```json
{
    "qr_code": "QR-ABC12345"
}
```

**Réponse :**
```json
{
    "mother": {
        "full_name": "Awa Diallo",
        "phone": "77 123 45 67",
        "address": "Dakar, Medina"
    },
    "qr_code": "QR-ABC12345",
    "has_health_record": true,
    "pregnancies_count": 2,
    "pregnancies": [...],
    "current_pregnancy": {
        "numero": 2,
        "semaine_actuelle": 24,
        "consultations": [...],
        "vaccinations": [...]
    },
    "medical_histories": [...],
    "spouse_info": {...}
}
```

---

## 📋 Tableau complet des endpoints

### Vue d'ensemble rapide

| Endpoint | Description |
|----------|-------------|
| `POST /api/carnet/scan/` | Scanner QR → voir TOUT le dossier |
| `GET/POST /api/carnet/pregnancies/` | Grossesses |
| `GET/PUT /api/carnet/current-pregnancy/` | Grossesse en cours |
| `GET/POST /api/carnet/consultations/` | Consultations prénatales (CPN) |
| `GET/POST /api/carnet/vaccinations/` | Vaccinations |
| `GET/POST /api/carnet/exams/` | Examens (échographies, analyses) |
| `GET/POST /api/carnet/treatments/` | Traitements et médicaments |
| `GET/POST /api/carnet/evolutions/` | Courbe de suivi (poids, tension) |
| `GET/POST /api/carnet/birth-plan/` | Plan d'accouchement |
| `GET/POST /api/carnet/appointments/` | Rendez-vous |
| `GET/POST /api/carnet/medical-history/` | Antécédents médicaux |
| `GET/POST /api/carnet/spouse/` | Informations du conjoint |
| `GET/POST /api/carnet/children/` | Enfants |

### Détail des méthodes HTTP

| Endpoint | GET | POST | PUT | DELETE |
|----------|-----|------|-----|--------|
| `/scan/` | - | ✅ Scanner | - | - |
| `/pregnancies/` | ✅ Liste | ✅ Créer | - | - |
| `/current-pregnancy/` | ✅ Grossesse en cours | - | ✅ Modifier | - |
| `/children/` | ✅ Liste | ✅ Ajouter | - | - |
| `/medical-history/` | ✅ Liste | ✅ Ajouter | ✅ Modifier | ✅ Supprimer |
| `/spouse/` | ✅ Info | ✅ Créer | ✅ Modifier | - |
| `/consultations/` | ✅ Liste | ✅ Ajouter | ✅ Modifier | ✅ Supprimer |
| `/vaccinations/` | ✅ Liste | ✅ Ajouter | ✅ Modifier | ✅ Supprimer |
| `/exams/` | ✅ Liste | ✅ Ajouter | ✅ Modifier | ✅ Supprimer |
| `/treatments/` | ✅ Liste | ✅ Ajouter | - | - |
| `/evolutions/` | ✅ Liste | ✅ Ajouter | - | - |
| `/birth-plan/` | ✅ Info | ✅ Créer | ✅ Modifier | - |
| `/appointments/` | ✅ Liste | ✅ Ajouter | ✅ Modifier | ✅ Supprimer |

### Correspondance avec les sections Flutter

| Section Flutter | Endpoint Backend | Modèle |
|-----------------|------------------|--------|
| Identifications (maman) | `/api/carnet/scan/` | `Mother` |
| Identifications (papa) | `/api/carnet/spouse/` | `SpouseInfo` |
| Identifications (enfant) | `/api/carnet/children/` | `Child` |
| Antécédents médicaux | `/api/carnet/medical-history/` | `MedicalHistory` (type=medical) |
| Antécédents chirurgicaux | `/api/carnet/medical-history/` | `MedicalHistory` (type=chirurgical) |
| Antécédents familiaux | `/api/carnet/medical-history/` | `MedicalHistory` (type=familial) |
| Allergies | `/api/carnet/medical-history/` | `MedicalHistory` (type=allergie) |
| Conjoint | `/api/carnet/spouse/` | `SpouseInfo` |
| Grossesses antérieures | `/api/carnet/pregnancies/` | `Pregnancy` |
| Consultations prénatales | `/api/carnet/consultations/` | `PrenatalConsultation` |
| Échographies | `/api/carnet/exams/` | `MedicalExam` (type=echographie) |
| Analyses sanguines | `/api/carnet/exams/` | `MedicalExam` (type=analyse_sang) |
| Autres examens | `/api/carnet/exams/` | `MedicalExam` (type=autre) |
| Vaccinations | `/api/carnet/vaccinations/` | `Vaccination` |
| Traitements | `/api/carnet/treatments/` | `Treatment` |
| Courbe de suivi | `/api/carnet/evolutions/` | `PregnancyEvolution` |
| Plan d'accouchement | `/api/carnet/birth-plan/` | `BirthPlan` |
| Rendez-vous | `/api/carnet/appointments/` | `Appointment` |

---

## 📝 Exemples d'utilisation

### Lire les données (GET)

**Tous les GET utilisent `?qr_code=QR-XXX`**

```
GET /api/carnet/consultations/?qr_code=QR-ABC12345
GET /api/carnet/vaccinations/?qr_code=QR-ABC12345
GET /api/carnet/medical-history/?qr_code=QR-ABC12345
```

### Ajouter des données (POST)

**Tous les POST incluent le `qr_code` dans le body**

**Ajouter une consultation :**
```json
POST /api/carnet/consultations/
{
    "qr_code": "QR-ABC12345",
    "date": "2025-03-15",
    "semaine": 12,
    "poids": 65.5,
    "tension_systolique": 120,
    "tension_diastolique": 80,
    "taille_uterine": 18.5,
    "position_bebe": "Céphalique",
    "observations": "Évolution normale",
    "is_completed": true
}
```

**Ajouter une vaccination :**
```json
POST /api/carnet/vaccinations/
{
    "qr_code": "QR-ABC12345",
    "nom": "DTCP",
    "description": "Diphtérie, Tétanos, Coqueluche, Polio",
    "date": "2025-03-15",
    "semaine": 12,
    "is_completed": true
}
```

**Ajouter un antécédent :**
```json
POST /api/carnet/medical-history/
{
    "qr_code": "QR-ABC12345",
    "type": "medical",
    "title": "Hypertension",
    "date_diagnostic": "2019",
    "details": "Sous traitement"
}
```

**Ajouter un rendez-vous :**
```json
POST /api/carnet/appointments/
{
    "qr_code": "QR-ABC12345",
    "type": "cpn",
    "title": "CPN 3",
    "date": "2025-04-15",
    "heure": "10:00"
}
```

### Modifier des données (PUT)

**Pour modifier, on ajoute l'ID de l'élément à modifier**

```json
PUT /api/carnet/consultations/
{
    "qr_code": "QR-ABC12345",
    "consultation_id": 5,
    "observations": "Nouvelle observation"
}
```

```json
PUT /api/carnet/vaccinations/
{
    "qr_code": "QR-ABC12345",
    "vaccination_id": 3,
    "is_completed": true
}
```

### Supprimer des données (DELETE)

```json
DELETE /api/carnet/consultations/
{
    "qr_code": "QR-ABC12345",
    "consultation_id": 5
}
```

---

## 🔄 Flux complet

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUX SAGE-FEMME                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Maman arrive avec sa carte QR                               │
│     ↓                                                           │
│  2. Sage-femme scanne → POST /api/carnet/scan/                  │
│     Body: {"qr_code": "QR-ABC12345"}                            │
│     ↓                                                           │
│  3. Elle voit TOUT le dossier                                   │
│     ↓                                                           │
│  4. Elle peut tout faire avec le QR code :                      │
│     ├─ POST /api/carnet/consultations/                          │
│     ├─ POST /api/carnet/vaccinations/                           │
│     ├─ POST /api/carnet/exams/                                  │
│     ├─ POST /api/carnet/treatments/                             │
│     └─ POST /api/carnet/appointments/                           │
│                                                                 │
│  Tous avec {"qr_code": "QR-ABC12345", ...}                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📱 API Mobile Maman

La maman utilise aussi son QR code pour voir ses données :

| Endpoint | Description |
|----------|-------------|
| `GET /api/mobile/full-health-record/?qr_code=QR-XXX` | Carnet complet |
| `GET /api/mobile/consultations/?qr_code=QR-XXX` | Consultations |
| `GET /api/mobile/vaccinations/?qr_code=QR-XXX` | Vaccinations |
| `GET /api/mobile/appointments/?qr_code=QR-XXX` | Rendez-vous |
| `GET /api/mobile/medical-history/?qr_code=QR-XXX` | Antécédents |

---

## 📝 Notes

1. **QR code = Seul identifiant** : Pas d'ID à retenir !

2. **Grossesse en cours automatique** : Les consultations, vaccinations, etc. sont automatiquement ajoutées à la grossesse en cours.

3. **Numéro CPN auto** : Le numéro de consultation est calculé automatiquement.

4. **Types d'antécédents** : `medical`, `chirurgical`, `familial`, `allergie`

5. **Types de RDV** : `cpn`, `vaccination`, `echographie`, `analyse`, `autre`

---

*Documentation mise à jour le 29/11/2025*
