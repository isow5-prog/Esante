import 'package:flutter/material.dart';

class GrossessesAnterieuresPage extends StatelessWidget {
  final int numeroGrossesse;

  const GrossessesAnterieuresPage({
    super.key,
    required this.numeroGrossesse,
  });

  // Données d'exemple : rendez-vous/étapes pour chaque grossesse
  final Map<int, List<Map<String, dynamic>>> _rendezVousParGrossesse = const {
    1: [
      {
        'terme': '10 semaines',
        'sexe': 'Non déterminé',
        'mode': 'Consultation',
        'poids': '-',
        'vivant': true,
        'incident': 'Premier rendez-vous, confirmation de grossesse',
      },
      {
        'terme': '21 semaines',
        'sexe': 'Fille',
        'mode': 'Échographie',
        'poids': '-',
        'vivant': true,
        'incident': 'Échographie morphologique, sexe déterminé',
      },
      {
        'terme': '33 semaines',
        'sexe': 'Fille',
        'mode': 'Consultation',
        'poids': '2.1 kg',
        'vivant': true,
        'incident': 'Suivi de croissance, poids estimé',
      },
      {
        'terme': '38 semaines',
        'sexe': 'Fille',
        'mode': 'Césarienne',
        'poids': '3.2 kg',
        'vivant': true,
        'incident': 'Césarienne programmée pour présentation en siège',
      },
    ],
    2: [
      {
        'terme': '10 semaines',
        'sexe': 'Non déterminé',
        'mode': 'Consultation',
        'poids': '-',
        'vivant': true,
        'incident': 'Premier rendez-vous, confirmation de grossesse',
      },
      {
        'terme': '21 semaines',
        'sexe': 'Garçon',
        'mode': 'Échographie',
        'poids': '-',
        'vivant': true,
        'incident': 'Échographie morphologique, sexe déterminé',
      },
      {
        'terme': '33 semaines',
        'sexe': 'Garçon',
        'mode': 'Consultation',
        'poids': '2.8 kg',
        'vivant': true,
        'incident': 'Suivi de croissance, poids estimé',
      },
      {
        'terme': '40 semaines',
        'sexe': 'Garçon',
        'mode': 'Voie basse',
        'poids': '3.5 kg',
        'vivant': true,
        'incident': 'Accouchement par voie basse, épisiotomie réalisée',
      },
    ],
    3: [
      {
        'terme': '10 semaines',
        'sexe': 'Non déterminé',
        'mode': 'Consultation',
        'poids': '-',
        'vivant': true,
        'incident': 'Premier rendez-vous, confirmation de grossesse',
      },
      {
        'terme': '21 semaines',
        'sexe': 'Fille',
        'mode': 'Échographie',
        'poids': '-',
        'vivant': true,
        'incident': 'Échographie morphologique, sexe déterminé',
      },
      {
        'terme': '33 semaines',
        'sexe': 'Fille',
        'mode': 'Consultation',
        'poids': '2.5 kg',
        'vivant': true,
        'incident': 'Suivi de croissance, poids estimé',
      },
      {
        'terme': '37 semaines',
        'sexe': 'Fille',
        'mode': 'Voie basse',
        'poids': '2.8 kg',
        'vivant': true,
        'incident': 'Accouchement prématuré à 37 semaines',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    // Récupérer les rendez-vous/étapes de la grossesse correspondant au numéro
    final rendezVous = _rendezVousParGrossesse[numeroGrossesse] ?? 
        _rendezVousParGrossesse[1] ?? [];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1AAA42),
        title: Text(
          'Grossesse n°$numeroGrossesse',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A7A33),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.pregnant_woman,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grossesse n°$numeroGrossesse',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Historique des grossesses antérieures',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Tableau
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1.2),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(1),
                    5: FlexColumnWidth(1.8),
                  },
                  children: [
                    // En-tête du tableau
                    TableRow(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A7A33).withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      children: [
                        _TableHeaderCell('Terme'),
                        _TableHeaderCell('Sexe'),
                        _TableHeaderCell('Mode'),
                        _TableHeaderCell('Poids'),
                        _TableHeaderCell('Vivant'),
                        _TableHeaderCell('Incident'),
                      ],
                    ),
                    // Lignes de données pour les rendez-vous/étapes de cette grossesse
                    ...rendezVous.map((rdv) => TableRow(
                      children: [
                        _TableCell(rdv['terme'] as String),
                        _TableCell(rdv['sexe'] as String),
                        _TableCell(rdv['mode'] as String),
                        _TableCell(rdv['poids'] as String),
                        _TableCell(
                          (rdv['vivant'] as bool) ? 'Oui' : 'Non',
                          isVivant: rdv['vivant'] as bool,
                        ),
                        _TableCell(rdv['incident'] as String),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0A7A33),
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isVivant;

  const _TableCell(
    this.text, {
    this.isVivant = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isVivant) ...[
            Icon(
              text == 'Oui' ? Icons.check_circle : Icons.cancel,
              size: 14,
              color: text == 'Oui' ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}


