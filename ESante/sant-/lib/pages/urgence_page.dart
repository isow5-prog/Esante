import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrgencePage extends StatelessWidget {
  const UrgencePage({super.key});

  Future<void> _callNumber(BuildContext context, String phoneNumber) async {
    try {
      // Nettoyer le numéro (enlever espaces, tirets, X, etc.)
      String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)X]'), '');
      
      // Créer l'URI pour l'appel téléphonique
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanedNumber);
      
      // Lancer directement l'appel sans vérification préalable
      // Cela évite le problème de canal avec canLaunchUrl
      await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
      
    } catch (e) {
      // En cas d'erreur, essayer avec platformDefault
      try {
        String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)X]'), '');
        final Uri phoneUri = Uri(scheme: 'tel', path: cleanedNumber);
        await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
      } catch (e2) {
        // Afficher l'erreur à l'utilisateur
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: Impossible d\'appeler $phoneNumber.\nEssayez de composer le numéro manuellement.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Urgence',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte d'urgence principale
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'En cas d\'urgence médicale',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Appelez immédiatement le SAMU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _callNumber(context, '1515'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone, size: 28),
                        SizedBox(width: 12),
                        Text(
                          '15 - SAMU',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Signes d'urgence
            const Text(
              'Signes d\'urgence pendant la grossesse',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                color: Color(0xFF0A7A33),
              ),
            ),
            const SizedBox(height: 16),

            _UrgencyCard(
              icon: Icons.water_drop,
              title: 'Perte de liquide ou saignement',
              description: 'Perte de liquide amniotique ou saignement vaginal important',
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _UrgencyCard(
              icon: Icons.sick,
              title: 'Douleurs abdominales intenses',
              description: 'Douleurs persistantes et fortes dans le ventre',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _UrgencyCard(
              icon: Icons.visibility_off,
              title: 'Maux de tête avec vision trouble',
              description: 'Maux de tête sévères accompagnés de troubles visuels',
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _UrgencyCard(
              icon: Icons.baby_changing_station,
              title: 'Absence de mouvements du bébé',
              description: 'Si vous ne sentez plus bébé bouger (après 28 semaines)',
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _UrgencyCard(
              icon: Icons.thermostat,
              title: 'Fièvre élevée',
              description: 'Température supérieure à 38°C',
              color: Colors.orange,
            ),

            const SizedBox(height: 24),

            // Numéros d'urgence
            const Text(
              'Numéros d\'urgence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                color: Color(0xFF0A7A33),
              ),
            ),
            const SizedBox(height: 16),

            _EmergencyContactCard(
              icon: Icons.local_hospital,
              title: 'SAMU',
              number: '1515',
              description: 'Service d\'aide médicale urgente',
              color: Colors.red,
              onTap: () => _callNumber(context, '1515'),
            ),
            const SizedBox(height: 12),
            _EmergencyContactCard(
              icon: Icons.fire_truck,
              title: 'Pompiers',
              number: '18',
              description: 'Secours d\'urgence',
              color: Colors.orange,
              onTap: () => _callNumber(context, '18'),
            ),
            const SizedBox(height: 12),
            _EmergencyContactCard(
              icon: Icons.phone,
              title: 'Votre agent de santé',
              number: '+221 XX XXX XX XX',
              description: 'Contactez votre agent de santé',
              color: const Color(0xFF0A7A33),
              onTap: () => _callNumber(context, '+221XXXXXXXXX'),
            ),

            const SizedBox(height: 24),

            // Conseils
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Conseil important',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'En cas de doute, n\'hésitez jamais à appeler. '
                    'Il vaut mieux prévenir que guérir. '
                    'Votre santé et celle de votre bébé sont prioritaires.',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _UrgencyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _UrgencyCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Inter',
                    color: Colors.grey[700],
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

class _EmergencyContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String number;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyContactCard({
    required this.icon,
    required this.title,
    required this.number,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.phone, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}

