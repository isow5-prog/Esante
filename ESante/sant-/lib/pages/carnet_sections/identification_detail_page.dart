import 'package:flutter/material.dart';
import 'package:esante/models/carnet/carnet_model.dart';
import 'package:esante/models/users/maman_model.dart';
import 'package:esante/models/users/papa_model.dart';
import 'package:esante/models/users/enfant_model.dart';

class IdentificationDetailPage extends StatelessWidget {
  final CarnetModel carnet;
  final MamanModel maman;
  final PapaModel papa;
  final EnfantModel enfant;

  const IdentificationDetailPage({
    super.key,
    required this.carnet,
    required this.maman,
    required this.papa,
    required this.enfant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1AAA42),
        title: const Text(
          'Identifications personnelles',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SubSectionCard(
              icon: Icons.woman,
              title: 'Informations de la maman',
              lignes: [
                maman.nomComplet,
                'Date de naissance : ${maman.dateNaissance}',
                'Téléphone : ${maman.telephone}',
                'Adresse : ${maman.adresse}',
                'Nombre d\'enfants : ${maman.nombreEnfants}',
              ],
            ),
            const SizedBox(height: 12),
            _SubSectionCard(
              icon: Icons.man,
              title: 'Informations du papa',
              lignes: [
                papa.nomComplet,
                'Date de naissance : ${papa.dateNaissance}',
                'Téléphone : ${papa.telephone}',
                'Adresse : ${papa.adresse}',
              ],
            ),
            const SizedBox(height: 12),
            _SubSectionCard(
              icon: Icons.child_care,
              title: 'Informations de l’enfant',
              lignes: [
                enfant.nomComplet,
                'Sexe : ${enfant.sexe}',
                'Date de naissance : ${enfant.dateNaissance}',
                'Numéro de dossier : ${enfant.numeroDossier}',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> lignes;

  const _SubSectionCard({
    required this.icon,
    required this.title,
    required this.lignes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
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
                  ...lignes.map(
                    (ligne) => Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        ligne,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
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

