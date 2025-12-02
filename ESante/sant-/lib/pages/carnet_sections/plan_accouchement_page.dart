import 'package:flutter/material.dart';

class PlanAccouchementPage extends StatelessWidget {
  const PlanAccouchementPage({super.key});

  // Données d'exemple pour le plan d'accouchement
  final Map<String, dynamic> _planAccouchement = const {
    'datePrevue': '15 Mars 2026',
    'semainePrevue': 40,
    'lieu': 'Hôpital Principal de Dakar',
    'adresse': 'Rue X, Dakar, Sénégal',
    'modePrevu': 'Voie basse',
    'modeAlternatif': 'Césarienne si nécessaire',
    'accompagnant': 'Mamadou Diop (Papa)',
    'preferences': [
      'Accouchement naturel sans péridurale si possible',
      'Contact peau à peau immédiat après la naissance',
      'Allaitement maternel dès la naissance',
    ],
    'preparations': [
      'Valise de maternité préparée',
      'Documents d\'identité et carnet de santé',
      'Numéros d\'urgence à portée de main',
    ],
    'medecin': 'Dr. Diallo',
    'telephone': '+221 77 123 45 67',
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
          'Plan d\'accouchement',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte principale avec date prévue
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1AAA42),
                    const Color(0xFF0A7A33),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1AAA42).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.event,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Date prévue d\'accouchement',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _planAccouchement['datePrevue'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Semaine ${_planAccouchement['semainePrevue']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Lieu d'accouchement
            _InfoCard(
              icon: Icons.local_hospital,
              title: 'Lieu d\'accouchement',
              color: Colors.blue,
              children: [
                Text(
                  _planAccouchement['lieu'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _planAccouchement['adresse'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Mode d'accouchement
            _InfoCard(
              icon: Icons.pregnant_woman,
              title: 'Mode d\'accouchement prévu',
              color: Colors.purple,
              children: [
                Text(
                  _planAccouchement['modePrevu'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _planAccouchement['modeAlternatif'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Inter',
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Accompagnant
            _InfoCard(
              icon: Icons.person,
              title: 'Personne accompagnante',
              color: Colors.orange,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      _planAccouchement['accompagnant'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Préférences
            _InfoCard(
              icon: Icons.favorite_border,
              title: 'Préférences',
              color: Colors.pink,
              children: [
                ...(_planAccouchement['preferences'] as List<String>).map((pref) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.pink),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pref,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),

            const SizedBox(height: 16),

            // Préparations
            _InfoCard(
              icon: Icons.checklist,
              title: 'Préparations',
              color: Colors.green,
              children: [
                ...(_planAccouchement['preparations'] as List<String>).map((prep) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              prep,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),

            const SizedBox(height: 16),

            // Contact médecin
            _InfoCard(
              icon: Icons.phone,
              title: 'Contact médecin',
              color: const Color(0xFF0A7A33),
              children: [
                Text(
                  _planAccouchement['medecin'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      _planAccouchement['telephone'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

