import 'package:flutter/material.dart';

class AntecedentsPage extends StatelessWidget {
  const AntecedentsPage({super.key});

  // Données d'exemple pour les antécédents médicaux
  final List<Map<String, String>> _antecedentsMedicaux = const [
    {
      'type': 'Hypertension artérielle',
      'date': 'Diagnostiquée en 2019',
      'details': 'Sous traitement médical régulier. Contrôle tensionnel trimestriel.',
    },
    {
      'type': 'Anémie ferriprive',
      'date': 'Décembre 2023',
      'details': 'Traitement par supplémentation en fer. Suivi hématologique.',
    },
  ];

  // Données d'exemple pour les antécédents chirurgicaux
  final List<Map<String, String>> _antecedentsChirurgicaux = const [
    {
      'type': 'Césarienne',
      'date': 'Janvier 2021',
      'details': 'Césarienne programmée pour présentation en siège. Récupération normale.',
    },
    {
      'type': 'Appendicectomie',
      'date': 'Mai 2015',
      'details': 'Appendicectomie en urgence. Aucune complication post-opératoire.',
    },
  ];

  // Données d'exemple pour les antécédents familiaux
  final List<Map<String, String>> _antecedentsFamiliaux = const [
    {
      'type': 'Diabète de type 2',
      'relation': 'Mère',
      'details': 'Diabète diagnostiqué à l\'âge de 55 ans. Traitement par antidiabétiques oraux.',
    },
    {
      'type': 'Hypertension artérielle',
      'relation': 'Père',
      'details': 'Hypertension traitée depuis 2010. Contrôle régulier.',
    },
    {
      'type': 'Maladie cardiaque',
      'relation': 'Grand-père paternel',
      'details': 'Infarctus du myocarde à l\'âge de 65 ans.',
    },
  ];

  // Données pour le conjoint
  final Map<String, String> _conjointInfo = const {
    'nom': 'Mamadou Diop',
    'groupeSanguin': 'O+',
    'antecedents': 'Aucun antécédent médical notable',
    'allergies': 'Aucune allergie connue',
    'dateNaissance': '05/08/1988',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1AAA42),
        title: const Text(
          'Antécédents',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Antécédents médicaux
            _AntecedentSection(
              icon: Icons.health_and_safety,
              title: 'Antécédents médicaux',
              description:
                  'Ex : hypertension, diabète, asthme, maladies chroniques, hospitalisations fréquentes, etc.',
              items: _antecedentsMedicaux,
              itemType: 'medical',
            ),
            const SizedBox(height: 12),
            // Antécédents chirurgicaux
            _AntecedentSection(
              icon: Icons.healing,
              title: 'Antécédents chirurgicaux',
              description:
                  'Ex : césarienne, chirurgie abdominale, interventions gynécologiques, autres opérations importantes.',
              items: _antecedentsChirurgicaux,
              itemType: 'chirurgical',
            ),
            const SizedBox(height: 12),
            // Antécédents familiaux
            _AntecedentSection(
              icon: Icons.group,
              title: 'Antécédents familiaux',
              description:
                  'Ex : antécédents de diabète, hypertension, maladies cardiaques, génétiques dans la famille.',
              items: _antecedentsFamiliaux,
              itemType: 'familial',
            ),
            const SizedBox(height: 12),
            // Conjoint
            _ConjointSection(
              icon: Icons.favorite,
              title: 'Conjoint',
              description:
                  'Infos sur le conjoint : état de santé général, antécédents médicaux importants, groupe sanguin, etc.',
              conjointInfo: _conjointInfo,
            ),
          ],
        ),
      ),
    );
  }
}

class _AntecedentSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Map<String, String>> items;
  final String itemType;

  const _AntecedentSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.items,
    required this.itemType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF0A7A33),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: const Color(0xFF0A7A33),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['type'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0A7A33),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (itemType == 'familial' && item['relation'] != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 16, bottom: 4),
                              child: Text(
                                'Relation : ${item['relation']}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 4),
                            child: Text(
                              item['date'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              item['details'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConjointSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Map<String, String> conjointInfo;

  const _ConjointSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.conjointInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF0A7A33),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.person,
                    label: 'Nom',
                    value: conjointInfo['nom'] ?? '',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.cake,
                    label: 'Date de naissance',
                    value: conjointInfo['dateNaissance'] ?? '',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.bloodtype,
                    label: 'Groupe sanguin',
                    value: conjointInfo['groupeSanguin'] ?? '',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.medical_services,
                    label: 'Antécédents médicaux',
                    value: conjointInfo['antecedents'] ?? '',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.warning,
                    label: 'Allergies',
                    value: conjointInfo['allergies'] ?? '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF0A7A33),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

