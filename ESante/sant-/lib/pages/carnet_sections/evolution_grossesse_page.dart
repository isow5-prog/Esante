import 'package:flutter/material.dart';

class EvolutionGrossessePage extends StatelessWidget {
  const EvolutionGrossessePage({super.key});

  // Données d'exemple pour l'évolution de la grossesse
  final List<Map<String, dynamic>> _evolution = const [
    {
      'semaine': 8,
      'tailleBebe': '1.6 cm',
      'poidsBebe': '1 g',
      'developpement': 'Formation des organes principaux, battements cardiaques visibles',
      'symptomes': 'Nausées matinales, fatigue',
    },
    {
      'semaine': 12,
      'tailleBebe': '5.4 cm',
      'poidsBebe': '14 g',
      'developpement': 'Organes formés, sexe peut être déterminé',
      'symptomes': 'Diminution des nausées, ventre qui commence à s\'arrondir',
    },
    {
      'semaine': 16,
      'tailleBebe': '11.6 cm',
      'poidsBebe': '100 g',
      'developpement': 'Bébé bouge, mouvements visibles à l\'échographie',
      'symptomes': 'Premiers mouvements ressentis',
    },
    {
      'semaine': 20,
      'tailleBebe': '16.4 cm',
      'poidsBebe': '300 g',
      'developpement': 'Goût et toucher développés, bébé entend',
      'symptomes': 'Mouvements plus fréquents, ventre bien visible',
    },
    {
      'semaine': 24,
      'tailleBebe': '30 cm',
      'poidsBebe': '600 g',
      'developpement': 'Système respiratoire se développe, réagit aux sons',
      'symptomes': 'Mouvements très actifs, troubles du sommeil possibles',
    },
    {
      'semaine': 28,
      'tailleBebe': '37.6 cm',
      'poidsBebe': '1 kg',
      'developpement': 'Yeux s\'ouvrent, système nerveux mature',
      'symptomes': 'Essoufflement, brûlures d\'estomac',
    },
    {
      'semaine': 32,
      'tailleBebe': '42.4 cm',
      'poidsBebe': '1.7 kg',
      'developpement': 'Poumons presque matures, bébé prend position',
      'symptomes': 'Mouvements moins amples, douleurs au dos',
    },
    {
      'semaine': 36,
      'tailleBebe': '47.4 cm',
      'poidsBebe': '2.6 kg',
      'developpement': 'Bébé est prêt pour la naissance',
      'symptomes': 'Contractions préparatoires, ventre très lourd',
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
          'Évolution de la grossesse',
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
                color: const Color(0xFF1AAA42).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1AAA42).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.pregnant_woman, color: const Color(0xFF0A7A33), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Suivi de l\'évolution de votre grossesse semaine par semaine',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Inter',
                        color: const Color(0xFF0A7A33),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Liste de l'évolution
            ..._evolution.map((etape) => _EvolutionCard(
              etape: etape,
            )),
          ],
        ),
      ),
    );
  }
}

class _EvolutionCard extends StatelessWidget {
  final Map<String, dynamic> etape;

  const _EvolutionCard({
    required this.etape,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE8F5EC),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0A7A33).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec semaine
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF0A7A33),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pregnant_woman,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semaine ${etape['semaine']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        color: Color(0xFF0A7A33),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Taille et poids du bébé
                    Row(
                      children: [
                        Icon(Icons.height, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Taille: ${etape['tailleBebe']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.monitor_weight, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Poids: ${etape['poidsBebe']}',
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
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Développement
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.baby_changing_station, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 6),
                    Text(
                      'Développement du bébé',
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
                  etape['developpement'] as String,
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

          const SizedBox(height: 12),

          // Symptômes
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 6),
                    Text(
                      'Symptômes courants',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  etape['symptomes'] as String,
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
        ],
      ),
    );
  }
}

