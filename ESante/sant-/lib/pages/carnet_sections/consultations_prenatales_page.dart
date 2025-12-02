import 'package:flutter/material.dart';

class ConsultationsPrenatalesPage extends StatelessWidget {
  const ConsultationsPrenatalesPage({super.key});

  // Données d'exemple pour les consultations prénatales
  final List<Map<String, dynamic>> _consultations = const [
    {
      'id': 1,
      'date': '05 Mars 2025',
      'semaine': 8,
      'cpn': 'CPN 1',
      'poids': '62 kg',
      'tension': '120/80',
      'tailleUterine': '12 cm',
      'position': 'Céphalique',
      'observations': 'Bonne évolution. Battements cardiaques présents. Prescription d\'acide folique.',
      'medecin': 'Dr. Diallo',
      'confirme': true,
    },
    {
      'id': 2,
      'date': '25 Avril 2025',
      'semaine': 12,
      'cpn': 'CPN 2',
      'poids': '63.5 kg',
      'tension': '118/78',
      'tailleUterine': '18 cm',
      'position': 'Céphalique',
      'observations': 'Croissance normale. Première échographie prescrite.',
      'medecin': 'Dr. Diallo',
      'confirme': true,
    },
    {
      'id': 3,
      'date': '05 Janvier 2026',
      'semaine': 24,
      'cpn': 'CPN 3',
      'poids': '65 kg',
      'tension': '122/80',
      'tailleUterine': '24 cm',
      'position': 'Céphalique',
      'observations': 'Évolution normale. Bébé actif. Suivi continu.',
      'medecin': 'Dr. Diallo',
      'confirme': false,
    },
    {
      'id': 4,
      'date': '10 Février 2026',
      'semaine': 28,
      'cpn': 'CPN 4',
      'poids': '-',
      'tension': '-',
      'tailleUterine': '-',
      'position': '-',
      'observations': 'Consultation à venir',
      'medecin': 'Dr. Diallo',
      'confirme': false,
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
          'Consultations prénatales',
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
                      'Historique de vos consultations prénatales (CPN)',
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

            // Liste des consultations
            ..._consultations.map((consultation) => _ConsultationCard(
              consultation: consultation,
            )),
          ],
        ),
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final Map<String, dynamic> consultation;

  const _ConsultationCard({
    required this.consultation,
  });

  @override
  Widget build(BuildContext context) {
    final isFuture = !(consultation['confirme'] as bool);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFuture ? Colors.grey.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFuture 
              ? Colors.grey.shade300 
              : const Color(0xFF0A7A33),
          width: isFuture ? 1 : 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec CPN et date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A7A33),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  consultation['cpn'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              if (consultation['confirme'] as bool)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 12, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Effectuée',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'À venir',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Date et semaine
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                consultation['date'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1AAA42).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Semaine ${consultation['semaine']}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: Color(0xFF1AAA42),
                  ),
                ),
              ),
            ],
          ),

          if (consultation['confirme'] as bool) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Mesures
            Row(
              children: [
                Expanded(
                  child: _MeasureBox(
                    icon: Icons.monitor_weight,
                    label: 'Poids',
                    value: consultation['poids'] as String,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MeasureBox(
                    icon: Icons.favorite,
                    label: 'Tension',
                    value: consultation['tension'] as String,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MeasureBox(
                    icon: Icons.height,
                    label: 'Taille utérine',
                    value: consultation['tailleUterine'] as String,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Position du bébé
            Row(
              children: [
                Icon(Icons.child_care, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  'Position : ${consultation['position']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Inter',
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Observations
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
                      Icon(Icons.description, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Observations',
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
                    consultation['observations'] as String,
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
                  consultation['medecin'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              consultation['observations'] as String,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Inter',
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MeasureBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MeasureBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0A7A33)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              color: Color(0xFF0A7A33),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Inter',
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

