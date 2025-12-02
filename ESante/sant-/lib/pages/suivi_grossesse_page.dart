import 'package:flutter/material.dart';
import 'package:esante/pages/calendrier_page.dart';

class SuiviGrossessePage extends StatelessWidget {
  const SuiviGrossessePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1AAA42),
        title: const Text(
          'Suivi grossesse',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte principale avec informations de la grossesse
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5EC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0A7A33), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0A7A33),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pregnant_woman,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Semaine 24",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                                color: Color(0xFF0A7A33),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "2ème trimestre",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Inter',
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: "Date prévue d'accouchement",
                    value: "15 Mars 2026",
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.timer,
                    label: "Jours restants",
                    value: "112 jours",
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.trending_up,
                    label: "Poids actuel",
                    value: "65 kg",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Évolution du bébé
            const Text(
              "Évolution du bébé",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "À 24 semaines",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Votre bébé mesure environ 30 cm et pèse environ 600 g. "
                      "Il commence à réagir aux sons et peut entendre votre voix. "
                      "Ses organes continuent de se développer.",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Section Prochaines étapes
            const Text(
              "Prochaines étapes",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            _StepCard(
              icon: Icons.medical_services,
              title: "Consultation prénatale",
              description: "Prochaine consultation recommandée",
              date: "Dans 2 semaines",
              eventType: 'consultation',
            ),
            const SizedBox(height: 12),
            _StepCard(
              icon: Icons.vaccines,
              title: "Vaccination",
              description: "Rappel vaccinal si nécessaire",
              date: "À discuter avec le médecin",
              eventType: 'vaccin',
            ),
            const SizedBox(height: 12),
            _StepCard(
              icon: Icons.analytics,
              title: "Échographie",
              description: "Échographie du 2ème trimestre",
              date: "À planifier",
              eventType: 'examen',
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
      children: [
        Icon(icon, color: const Color(0xFF0A7A33), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A7A33),
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String date;
  final String? eventType; // 'consultation', 'vaccin', 'examen'

  const _StepCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.date,
    this.eventType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0A7A33).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF0A7A33)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Inter',
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Inter',
                color: Color(0xFF0A7A33),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF0A7A33)),
        onTap: eventType != null
            ? () {
                // Rediriger vers le calendrier avec le type d'événement
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendrierPage(
                      eventType: eventType,
                    ),
                  ),
                );
              }
            : null,
      ),
    );
  }
}

