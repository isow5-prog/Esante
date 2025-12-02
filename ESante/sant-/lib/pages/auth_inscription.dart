import 'package:flutter/material.dart';
import 'package:esante/pages/carnet.dart';

class AuthInscriptionPage extends StatefulWidget {
  final String? qrValue;

  const AuthInscriptionPage({super.key, this.qrValue});

  @override
  State<AuthInscriptionPage> createState() => _AuthInscriptionPageState();
}

class _AuthInscriptionPageState extends State<AuthInscriptionPage> {
  // Infos maman (obligatoires)
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _dateNaissanceController =
      TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();

  // Champs optionnels
  String? _languePreferee;
  String? _niveauInstruction;
  final TextEditingController _occupationController = TextEditingController();

  // Santé maman
  bool _grossesseEnCours = true;
  final TextEditingController _dpaController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _antecedentsController = TextEditingController();

  // Infos enfant (optionnelles)
  final TextEditingController _nomEnfantController = TextEditingController();
  String? _sexeEnfant;
  final TextEditingController _dateNaissanceEnfantController =
      TextEditingController();
  final TextEditingController _poidsNaissanceController =
      TextEditingController();
  final TextEditingController _tailleNaissanceController =
      TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _dateNaissanceController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _occupationController.dispose();
    _dpaController.dispose();
    _allergiesController.dispose();
    _antecedentsController.dispose();
    _nomEnfantController.dispose();
    _dateNaissanceEnfantController.dispose();
    _poidsNaissanceController.dispose();
    _tailleNaissanceController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    // Pour l'instant, aucune validation : on enregistre (mock) puis on redirige vers la page Carnet.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Inscription enregistrée (mock).")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Carnet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrValue = widget.qrValue;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A7A33),
        title: const Text(
          'Inscription',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Informations personnelles de la maman
            const Text(
              '1. Informations personnelles de la maman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _prenomController,
              decoration: const InputDecoration(
                labelText: 'Prénom *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateNaissanceController,
              decoration: const InputDecoration(
                labelText: 'Date de naissance ou âge *',
                hintText: 'Ex : 12/03/1993 ou 31 ans',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _telephoneController,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _adresseController,
              decoration: const InputDecoration(
                labelText: 'Adresse / Localité / Village *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Numéro de la carte QR',
                border: const OutlineInputBorder(),
                hintText: 'Scanné automatiquement',
                helperText: qrValue != null ? null : 'Aucun QR scanné',
              ),
              controller: TextEditingController(text: qrValue ?? ''),
            ),
            const SizedBox(height: 16),

            // Champs optionnels langue / niveau / occupation
            const Text(
              'Préférences (optionnel)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _languePreferee,
              items: const [
                DropdownMenuItem(value: 'wolof', child: Text('Wolof')),
                DropdownMenuItem(value: 'pulaar', child: Text('Pulaar')),
                DropdownMenuItem(value: 'serere', child: Text('Sérère')),
                DropdownMenuItem(value: 'fr', child: Text('Français')),
              ],
              onChanged: (value) => setState(() => _languePreferee = value),
              decoration: const InputDecoration(
                labelText: 'Langue préférée',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _niveauInstruction,
              items: const [
                DropdownMenuItem(value: 'aucun', child: Text('Aucun')),
                DropdownMenuItem(value: 'primaire', child: Text('Primaire')),
                DropdownMenuItem(
                    value: 'secondaire', child: Text('Secondaire')),
                DropdownMenuItem(value: 'superieur', child: Text('Supérieur')),
              ],
              onChanged: (value) => setState(() => _niveauInstruction = value),
              decoration: const InputDecoration(
                labelText: 'Niveau d’instruction',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _occupationController,
              decoration: const InputDecoration(
                labelText: 'Occupation / Profession',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Informations liées à la santé de la maman
            const Text(
              '2. Informations liées à la santé de la maman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grossesse en cours ?'),
                Switch(
                  value: _grossesseEnCours,
                  onChanged: (v) => setState(() => _grossesseEnCours = v),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dpaController,
              decoration: const InputDecoration(
                labelText: 'Date prévue d’accouchement (DPA)',
                hintText: 'Ex : 15/06/2025',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _allergiesController,
              decoration: const InputDecoration(
                labelText: 'Allergies connues',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _antecedentsController,
              decoration: const InputDecoration(
                labelText: 'Antécédents médicaux importants',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // 3. Informations sur l’enfant (si déjà né)
            const Text(
              '3. Informations sur l’enfant (si déjà né)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nomEnfantController,
              decoration: const InputDecoration(
                labelText: 'Nom de l’enfant',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _sexeEnfant,
              items: const [
                DropdownMenuItem(value: 'M', child: Text('Masculin (M)')),
                DropdownMenuItem(value: 'F', child: Text('Féminin (F)')),
              ],
              onChanged: (value) => setState(() => _sexeEnfant = value),
              decoration: const InputDecoration(
                labelText: 'Sexe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateNaissanceEnfantController,
              decoration: const InputDecoration(
                labelText: 'Date de naissance',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _poidsNaissanceController,
              decoration: const InputDecoration(
                labelText: 'Poids à la naissance (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tailleNaissanceController,
              decoration: const InputDecoration(
                labelText: 'Taille à la naissance (cm)',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),

            // 4. Informations administratives (affichage read-only)
            const Text(
              '4. Informations administratives',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _AdminInfoRow(
              label: 'ID unique du compte',
              value: 'Généré automatiquement',
            ),
            _AdminInfoRow(
              label: 'QR code associé',
              value: qrValue ?? 'À partir du scan',
            ),
            _AdminInfoRow(
              label: 'Date d’inscription',
              value: 'Remplie automatiquement',
            ),
            _AdminInfoRow(
              label: 'Agent de santé inscrit',
              value: 'Utilisateur connecté (à définir)',
            ),
            const SizedBox(height: 24),

            // Bouton S'inscrire (sans blocage)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A7A33),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _onSubmit,
                child: const Text(
                  "S'inscrire",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _AdminInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

