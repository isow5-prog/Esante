import 'package:flutter/material.dart';

class TraitementsPage extends StatelessWidget {
  const TraitementsPage({super.key});

  // Données d'exemple pour les traitements
  final List<Map<String, dynamic>> _traitements = const [
    {
      'id': 1,
      'nom': 'Acide folique',
      'dosage': '400 µg',
      'frequence': '1 fois par jour',
      'dateDebut': '05 Mars 2025',
      'dateFin': 'Fin du 1er trimestre',
      'statut': 'actif',
      'medecin': 'Dr. Diallo',
      'raison': 'Prévention des malformations du tube neural',
    },
    {
      'id': 2,
      'nom': 'Fer',
      'dosage': '60 mg',
      'frequence': '1 fois par jour',
      'dateDebut': '15 Avril 2025',
      'dateFin': 'Fin de la grossesse',
      'statut': 'actif',
      'medecin': 'Dr. Diallo',
      'raison': 'Prévention de l\'anémie',
    },
    {
      'id': 3,
      'nom': 'Calcium',
      'dosage': '1000 mg',
      'frequence': '2 fois par jour',
      'dateDebut': '10 Juin 2025',
      'dateFin': 'Fin de la grossesse',
      'statut': 'actif',
      'medecin': 'Dr. Diallo',
      'raison': 'Renforcement osseux',
    },
    {
      'id': 4,
      'nom': 'Vitamine D',
      'dosage': '1000 UI',
      'frequence': '1 fois par jour',
      'dateDebut': '05 Mars 2025',
      'dateFin': 'Fin de la grossesse',
      'statut': 'actif',
      'medecin': 'Dr. Diallo',
      'raison': 'Absorption du calcium',
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
          'Traitements et médicaments',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message informatif
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Liste des médicaments prescrits pendant la grossesse',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Inter',
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Liste des traitements
            ..._traitements.map((traitement) => _TraitementCard(
              traitement: traitement,
            )),
          ],
        ),
      ),
    );
  }
}

class _TraitementCard extends StatelessWidget {
  final Map<String, dynamic> traitement;

  const _TraitementCard({
    required this.traitement,
  });

  @override
  Widget build(BuildContext context) {
    final isActif = traitement['statut'] == 'actif';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActif ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActif 
              ? Colors.green.shade300 
              : Colors.grey.shade300,
          width: isActif ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActif 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.medication,
                  color: isActif ? Colors.green : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      traitement['nom'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        color: isActif ? Colors.green.shade800 : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${traitement['dosage']} - ${traitement['frequence']}',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Inter',
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isActif)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Actif',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Période de traitement
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Du ${traitement['dateDebut']} au ${traitement['dateFin']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Inter',
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Raison du traitement
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 6),
                    Text(
                      'Raison',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  traitement['raison'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Inter',
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Médecin
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Prescrit par ${traitement['medecin']}',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Inter',
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

