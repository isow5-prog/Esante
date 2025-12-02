import 'package:flutter/material.dart';

class ConseilSantePage extends StatelessWidget {
  const ConseilSantePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1AAA42),
        title: const Text(
          'Conseil santé',
          style: TextStyle(color: Colors.white),
        ),

      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Alimentation
          _ConseilSection(
            icon: Icons.restaurant,
            title: "Alimentation",
            color: const Color(0xFF0A7A33),
            conseils: const [
              "Mangez équilibré avec des fruits et légumes frais",
              "Évitez les aliments crus (poisson, viande, fromages)",
              "Buvez au moins 1,5L d'eau par jour",
              "Limitez le café et les boissons sucrées",
            ],
          ),

          const SizedBox(height: 16),

          // Section Activité physique
          _ConseilSection(
            icon: Icons.directions_walk,
            title: "Activité physique",
            color: const Color(0xFF1AAA42),
            conseils: const [
              "Marchez 30 minutes par jour si possible",
              "Évitez les sports à risque de chute",
              "Pratiquez la natation ou le yoga prénatal",
              "Écoutez votre corps et reposez-vous",
            ],
          ),

          const SizedBox(height: 16),

          // Section Hygiène
          _ConseilSection(
            icon: Icons.clean_hands,
            title: "Hygiène et soins",
            color: const Color(0xFF0A7A33),
            conseils: const [
              "Lavez-vous les mains régulièrement",
              "Évitez les produits chimiques agressifs",
              "Prenez des douches plutôt que des bains chauds",
              "Portez des vêtements amples et confortables",
            ],
          ),

          const SizedBox(height: 16),

          // Section Sommeil
          _ConseilSection(
            icon: Icons.bedtime,
            title: "Sommeil",
            color: const Color(0xFF1AAA42),
            conseils: const [
              "Dormez sur le côté gauche si possible",
              "Utilisez un oreiller entre les genoux",
              "Évitez les écrans avant de dormir",
              "Essayez de dormir 7-9 heures par nuit",
            ],
          ),

          const SizedBox(height: 16),

          // Section Signes d'alerte
          _ConseilSection(
            icon: Icons.warning,
            title: "Signes d'alerte",
            color: Colors.orange,
            conseils: const [
              "Consultez immédiatement en cas de saignements",
              "Attention aux contractions régulières avant terme",
              "Signalez toute perte de liquide amniotique",
              "Surveillez les maux de tête persistants",
            ],
          ),

          const SizedBox(height: 16),

          // Section Vaccination
          _ConseilSection(
            icon: Icons.vaccines,
            title: "Vaccination",
            color: const Color(0xFF0A7A33),
            conseils: const [
              "Respectez le calendrier vaccinal",
              "Parlez-en avec votre médecin",
              "Certains vaccins sont recommandés pendant la grossesse",
              "Protégez-vous et votre bébé",
            ],
          ),
        ],
      ),
    );
  }
}

class _ConseilSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<String> conseils;

  const _ConseilSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.conseils,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...conseils.map((conseil) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6, right: 12),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          conseil,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter',
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

