import 'package:flutter/material.dart';
import 'package:esante/models/carnet/carnet_model.dart';
import 'package:esante/models/users/maman_model.dart';
import 'package:esante/models/users/papa_model.dart';
import 'package:esante/models/users/enfant_model.dart';
import 'package:esante/pages/carnet_sections/identification_detail_page.dart';
import 'package:esante/pages/carnet_sections/antecedents_page.dart';
import 'package:esante/pages/carnet_sections/grossesses_anterieures_page.dart';
import 'package:esante/pages/carnet_sections/examens_complementaires_page.dart';
import 'package:esante/pages/carnet_sections/consultations_prenatales_page.dart';
import 'package:esante/pages/carnet_sections/courbe_suivi_page.dart';
import 'package:esante/pages/carnet_sections/vaccinations_page.dart';
import 'package:esante/pages/carnet_sections/traitements_page.dart';
import 'package:esante/pages/carnet_sections/evolution_grossesse_page.dart';
import 'package:esante/pages/carnet_sections/plan_accouchement_page.dart';

class DetailCarnet extends StatelessWidget {
  final CarnetModel carnet;

  const DetailCarnet({
    super.key,
    required this.carnet,
  });

  @override
  Widget build(BuildContext context) {
    // Pour l'instant les statuts sont statiques, tu pourras les lier à des données plus tard.
    final bool identificationComplete = false;
    final bool antecedentsComplete = true;
    final bool grossessesComplete = false;
    final bool examensComplete = false;
    final bool consultationsComplete = false;
    final bool courbeSuiviComplete = false;
    final bool vaccinationsComplete = false;
    final bool traitementsComplete = false;
    final bool evolutionComplete = false;
    final bool planAccouchementComplete = false;

    // Exemple de données statiques pour la maman, le papa et l'enfant.
    // Tu pourras ensuite remplacer ça par des données venant de ton backend / API.
    final maman = MamanModel(
      id: 1,
      nom: 'Diallo',
      prenom: 'Awa',
      email: 'awa@example.com',
      telephone: '+221 77 123 45 67',
      adresse: 'Dakar, Sénégal',
      dateNaissance: '12/03/1993',
      nombreEnfants: 3,
      profession: 'Commerçante',
    );

    final papa = PapaModel(
      id: 'p1',
      nom: 'Diop',
      prenom: 'Mamadou',
      telephone: '+221 76 987 65 43',
      adresse: 'Dakar, Sénégal',
      dateNaissance: '05/08/1988',
    );

    final enfant = EnfantModel(
      id: 'e1',
      nom: 'Diop',
      prenom: 'Mariama',
      sexe: 'F',
      dateNaissance: '01/01/2025',
      numeroDossier: 'CARNET-001',
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1AAA42),
        toolbarHeight: 80,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          carnet.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5EC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations du carnet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    carnet.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    carnet.lastUpdate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Statut : ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        carnet.statut == 'en_cours'
                            ? 'En cours (grossesse actuelle)'
                            : 'Terminé (ancienne grossesse)',
                        style: TextStyle(
                          fontSize: 14,
                          color: carnet.statut == 'en_cours'
                              ? const Color(0xFF1565C0)
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ===== SECTIONS DU CARNET =====
            _SectionTile(
              icon: Icons.person,
              title: 'Identifications personnelles',
              isComplete: identificationComplete,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IdentificationDetailPage(
                      carnet: carnet,
                      maman: maman,
                      papa: papa,
                      enfant: enfant,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _SectionTile(
              icon: Icons.history,
              title: 'Antécédents',
              isComplete: antecedentsComplete,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AntecedentsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _SectionTile(
              icon: Icons.pregnant_woman,
              title: 'Grossesses antérieures',
              isComplete: grossessesComplete,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GrossessesAnterieuresPage(
                      numeroGrossesse: carnet.numeroGrossesse,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _SectionTile(
              icon: Icons.biotech,
              title: 'Examens complémentaires',
              isComplete: examensComplete,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExamensComplementairesPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _SectionTile(
              icon: Icons.medical_services,
              title: 'Consultations prénatales (CPN)',
              isComplete: consultationsComplete,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConsultationsPrenatalesPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _SectionTile(
              icon: Icons.show_chart,
              title: 'Courbe de suivi',
              isComplete: courbeSuiviComplete,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CourbeSuiviPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _SectionTile(
              icon: Icons.vaccines,
              title: 'Vaccinations',
              isComplete: vaccinationsComplete,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VaccinationsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _SectionTile(
              icon: Icons.medication,
              title: 'Traitements et médicaments',
              isComplete: traitementsComplete,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TraitementsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _SectionTile(
              icon: Icons.pregnant_woman,
              title: 'Évolution de la grossesse',
              isComplete: evolutionComplete,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EvolutionGrossessePage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _SectionTile(
              icon: Icons.event,
              title: 'Plan d\'accouchement',
              isComplete: planAccouchementComplete,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlanAccouchementPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isComplete;
  final VoidCallback onTap;

  const _SectionTile({
    required this.icon,
    required this.title,
    required this.isComplete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0A7A33),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          isComplete ? 'Statut : complet' : 'Statut : incomplet',
          style: TextStyle(
            fontSize: 13,
            color: isComplete ? Colors.green[700] : Colors.red[700],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
