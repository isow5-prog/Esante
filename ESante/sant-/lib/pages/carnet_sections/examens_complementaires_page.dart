import 'package:flutter/material.dart';

class ExamensComplementairesPage extends StatelessWidget {
  const ExamensComplementairesPage({super.key});

  // Données d'exemple pour les échographies
  final List<Map<String, String>> _echographies = const [
    {
      'date': '15 Nov 2025',
      'terme': '24 semaines',
      'type': 'Échographie morphologique',
      'resultat': 'Morphologie normale, croissance harmonieuse',
      'medecin': 'Dr. Diallo',
    },
    {
      'date': '10 Oct 2025',
      'terme': '12 semaines',
      'type': 'Échographie du 1er trimestre',
      'resultat': 'Clarté nucale normale, développement normal',
      'medecin': 'Dr. Diallo',
    },
    {
      'date': '05 Sep 2025',
      'terme': '8 semaines',
      'type': 'Échographie de datation',
      'resultat': 'Battements cardiaques présents, développement conforme',
      'medecin': 'Dr. Diallo',
    },
  ];

  // Données d'exemple pour les analyses sanguines
  final List<Map<String, String>> _analysesSanguines = const [
    {
      'date': '20 Nov 2025',
      'type': 'Numération formule sanguine (NFS)',
      'resultat': 'Hémoglobine: 11.5 g/dL, Hématocrite: 35%',
      'statut': 'Normal',
    },
    {
      'date': '20 Nov 2025',
      'type': 'Glycémie à jeun',
      'resultat': '0.85 g/L',
      'statut': 'Normal',
    },
    {
      'date': '15 Oct 2025',
      'type': 'Groupe sanguin et Rhésus',
      'resultat': 'O+, Rhésus positif',
      'statut': 'Normal',
    },
    {
      'date': '15 Oct 2025',
      'type': 'Sérologie toxoplasmose',
      'resultat': 'Immunité acquise',
      'statut': 'Normal',
    },
    {
      'date': '15 Oct 2025',
      'type': 'Sérologie rubéole',
      'resultat': 'Immunité acquise',
      'statut': 'Normal',
    },
  ];

  // Données d'exemple pour les autres examens
  final List<Map<String, String>> _autresExamens = const [
    {
      'date': '18 Nov 2025',
      'type': 'Test de dépistage du diabète gestationnel',
      'resultat': 'Négatif',
      'statut': 'Normal',
    },
    {
      'date': '12 Nov 2025',
      'type': 'Frottis cervico-vaginal',
      'resultat': 'Normal, pas de cellules anormales',
      'statut': 'Normal',
    },
    {
      'date': '05 Nov 2025',
      'type': 'Bandelette urinaire',
      'resultat': 'Protéinurie: négative, Glycosurie: négative',
      'statut': 'Normal',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1AAA42),
        title: const Text(
          'Examens complémentaires',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Échographies
            _ExamenSection(
              icon: Icons.monitor_heart,
              title: 'Échographies',
              color: Colors.blue,
              items: _echographies,
              isEchographie: true,
            ),
            const SizedBox(height: 16),
            // Section Analyses sanguines
            _ExamenSection(
              icon: Icons.bloodtype,
              title: 'Analyses sanguines',
              color: Colors.red,
              items: _analysesSanguines,
              isEchographie: false,
            ),
            const SizedBox(height: 16),
            // Section Autres examens
            _ExamenSection(
              icon: Icons.medical_services,
              title: 'Autres examens',
              color: Colors.green,
              items: _autresExamens,
              isEchographie: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamenSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<Map<String, String>> items;
  final bool isEchographie;

  const _ExamenSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.items,
    required this.isEchographie,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de section
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Liste des examens
            ...items.map((examen) => Padding(
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
                              color: color,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                examen['type'] ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0A7A33),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          value: examen['date'] ?? '',
                        ),
                        if (isEchographie && examen['terme'] != null) ...[
                          const SizedBox(height: 6),
                          _InfoRow(
                            icon: Icons.pregnant_woman,
                            label: 'Terme',
                            value: examen['terme'] ?? '',
                          ),
                        ],
                        if (examen['medecin'] != null) ...[
                          const SizedBox(height: 6),
                          _InfoRow(
                            icon: Icons.person,
                            label: 'Médecin',
                            value: examen['medecin'] ?? '',
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.description,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Résultat',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      examen['resultat'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (examen['statut'] != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Statut: ${examen['statut']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                )),
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
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}


