import 'package:flutter/material.dart';

class MedicamentsPage extends StatefulWidget {
  const MedicamentsPage({super.key});

  @override
  State<MedicamentsPage> createState() => _MedicamentsPageState();
}

class _MedicamentsPageState extends State<MedicamentsPage> {
  // Historique des prises : Map<medicament_id, Map<date, List<heures>>>
  final Map<int, Map<String, List<String>>> _historiquePrises = {};
  
  final List<Map<String, dynamic>> _medicaments = [
    {
      'id': 0,
      'nom': 'Acide folique',
      'dosage': '400 µg',
      'frequence': '1 fois par jour',
      'heure': '08:00',
      'type': 'vitamine',
      'nombrePrisesParJour': 1,
    },
    {
      'id': 1,
      'nom': 'Fer',
      'dosage': '60 mg',
      'frequence': '1 fois par jour',
      'heure': '20:00',
      'type': 'mineral',
      'nombrePrisesParJour': 1,
    },
    {
      'id': 2,
      'nom': 'Calcium',
      'dosage': '1000 mg',
      'frequence': '2 fois par jour',
      'heure': '12:00',
      'type': 'mineral',
      'nombrePrisesParJour': 2,
    },
  ];

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool _estPrisAujourdhui(int medicamentId) {
    final today = _getTodayKey();
    final historique = _historiquePrises[medicamentId];
    if (historique == null) return false;
    final prisesAujourdhui = historique[today];
    if (prisesAujourdhui == null) return false;
    
    final medicament = _medicaments.firstWhere((m) => m['id'] == medicamentId);
    final nombrePrisesRequises = medicament['nombrePrisesParJour'] as int;
    
    return prisesAujourdhui.length >= nombrePrisesRequises;
  }

  int _nombrePrisesAujourdhui(int medicamentId) {
    final today = _getTodayKey();
    final historique = _historiquePrises[medicamentId];
    if (historique == null) return 0;
    final prisesAujourdhui = historique[today];
    return prisesAujourdhui?.length ?? 0;
  }

  void _marquerPris(int medicamentId) {
    setState(() {
      final today = _getTodayKey();
      final now = DateTime.now();
      final heurePrise = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      if (_historiquePrises[medicamentId] == null) {
        _historiquePrises[medicamentId] = {};
      }
      
      if (_historiquePrises[medicamentId]![today] == null) {
        _historiquePrises[medicamentId]![today] = [];
      }
      
      _historiquePrises[medicamentId]![today]!.add(heurePrise);
    });
  }

  void _annulerPrise(int medicamentId) {
    setState(() {
      final today = _getTodayKey();
      final historique = _historiquePrises[medicamentId];
      if (historique != null && historique[today] != null) {
        historique[today]!.removeLast();
        if (historique[today]!.isEmpty) {
          historique.remove(today);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        backgroundColor: const Color(0xFF0A7A33),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mes médicaments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: Column(
        children: [
          // Statistiques rapides
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A7A33).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
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
                          'Médicaments prescrits par votre agent de santé',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBox(
                      label: 'À prendre',
                      value: '${_medicaments.where((m) => !_estPrisAujourdhui(m['id'] as int)).length}',
                      color: Colors.orange,
                    ),
                    _StatBox(
                      label: 'Pris aujourd\'hui',
                      value: '${_medicaments.where((m) => _estPrisAujourdhui(m['id'] as int)).length}',
                      color: Colors.green,
                    ),
                    _StatBox(
                      label: 'Total',
                      value: '${_medicaments.length}',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste des médicaments
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _medicaments.length,
              itemBuilder: (context, index) {
                final medicament = _medicaments[index];
                final medicamentId = medicament['id'] as int;
                final estPris = _estPrisAujourdhui(medicamentId);
                final nombrePrises = _nombrePrisesAujourdhui(medicamentId);
                final nombrePrisesRequises = medicament['nombrePrisesParJour'] as int;
                
                return _MedicamentCard(
                  medicament: medicament,
                  estPris: estPris,
                  nombrePrises: nombrePrises,
                  nombrePrisesRequises: nombrePrisesRequises,
                  onMarquerPris: () => _marquerPris(medicamentId),
                  onAnnulerPrise: () => _annulerPrise(medicamentId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Inter',
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

class _MedicamentCard extends StatelessWidget {
  final Map<String, dynamic> medicament;
  final bool estPris;
  final int nombrePrises;
  final int nombrePrisesRequises;
  final VoidCallback onMarquerPris;
  final VoidCallback onAnnulerPrise;

  const _MedicamentCard({
    required this.medicament,
    required this.estPris,
    required this.nombrePrises,
    required this.nombrePrisesRequises,
    required this.onMarquerPris,
    required this.onAnnulerPrise,
  });

  @override
  Widget build(BuildContext context) {
    final type = medicament['type'] as String;
    
    IconData typeIcon;
    Color typeColor;
    
    if (type == 'vitamine') {
      typeIcon = Icons.medication_liquid;
      typeColor = Colors.orange;
    } else {
      typeIcon = Icons.medication;
      typeColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: estPris ? Colors.green : Colors.grey.shade300,
          width: estPris ? 2 : 1,
        ),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: typeColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicament['nom'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        decoration: estPris
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: estPris ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medicament['dosage']} - ${medicament['frequence']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.medical_services,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Prescrit par votre agent de santé',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Inter',
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (nombrePrisesRequises > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: nombrePrises >= nombrePrisesRequises
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$nombrePrises/$nombrePrisesRequises',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: nombrePrises >= nombrePrisesRequises
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: estPris ? onAnnulerPrise : onMarquerPris,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: estPris
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: estPris ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        estPris ? Icons.check : Icons.circle_outlined,
                        color: estPris ? Colors.green : Colors.grey,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'À prendre à ${medicament['heure']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Inter',
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (estPris) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      nombrePrisesRequises > 1 
                          ? 'Pris ($nombrePrises/$nombrePrisesRequises)'
                          : 'Pris aujourd\'hui',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        color: Colors.green,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

