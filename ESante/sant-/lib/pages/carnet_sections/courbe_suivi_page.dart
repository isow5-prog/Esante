import 'package:flutter/material.dart';
import 'dart:math' as math;

class CourbeSuiviPage extends StatelessWidget {
  const CourbeSuiviPage({super.key});

  // Données d'exemple pour les mesures de poids
  final List<Map<String, dynamic>> _mesuresPoids = const [
    {'semaine': 8, 'poids': 62.0, 'date': '05 Mars 2025'},
    {'semaine': 12, 'poids': 63.5, 'date': '25 Avril 2025'},
    {'semaine': 16, 'poids': 64.2, 'date': '15 Mai 2025'},
    {'semaine': 20, 'poids': 64.8, 'date': '10 Juin 2025'},
    {'semaine': 24, 'poids': 65.0, 'date': '05 Janvier 2026'},
    {'semaine': 28, 'poids': 66.2, 'date': '10 Février 2026'},
    {'semaine': 32, 'poids': 67.5, 'date': '15 Mars 2026'},
    {'semaine': 36, 'poids': 68.0, 'date': '20 Avril 2026'},
  ];

  // Données d'exemple pour les mesures de tension
  final List<Map<String, dynamic>> _mesuresTension = const [
    {'semaine': 8, 'tensionSys': 120, 'tensionDia': 80, 'date': '05 Mars 2025'},
    {'semaine': 12, 'tensionSys': 118, 'tensionDia': 78, 'date': '25 Avril 2025'},
    {'semaine': 16, 'tensionSys': 122, 'tensionDia': 82, 'date': '15 Mai 2025'},
    {'semaine': 20, 'tensionSys': 120, 'tensionDia': 80, 'date': '10 Juin 2025'},
    {'semaine': 24, 'tensionSys': 122, 'tensionDia': 80, 'date': '05 Janvier 2026'},
    {'semaine': 28, 'tensionSys': 125, 'tensionDia': 82, 'date': '10 Février 2026'},
    {'semaine': 32, 'tensionSys': 124, 'tensionDia': 84, 'date': '15 Mars 2026'},
    {'semaine': 36, 'tensionSys': 126, 'tensionDia': 85, 'date': '20 Avril 2026'},
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
          'Courbe de suivi',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Courbe de poids
            _CourbeSection(
              title: 'Évolution du poids',
              icon: Icons.monitor_weight,
              color: Colors.blue,
              mesures: _mesuresPoids,
              type: 'poids',
            ),

            const SizedBox(height: 24),

            // Courbe de tension
            _CourbeSection(
              title: 'Évolution de la tension artérielle',
              icon: Icons.favorite,
              color: Colors.red,
              mesures: _mesuresTension,
              type: 'tension',
            ),

            const SizedBox(height: 24),

            // Dernières mesures
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dernières mesures',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._mesuresPoids.reversed.take(3).map((mesure) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Semaine ${mesure['semaine']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      color: Colors.grey[700],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                final tensionIndex = _mesuresTension
                                    .indexWhere((m) => m['semaine'] == mesure['semaine']);
                                return Row(
                                  children: [
                                    Icon(Icons.monitor_weight,
                                        size: 16, color: Colors.blue),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '${mesure['poids']} kg',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                          color: Colors.blue,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.favorite,
                                        size: 16, color: Colors.red),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        tensionIndex != -1
                                            ? '${_mesuresTension[tensionIndex]['tensionSys']}/${_mesuresTension[tensionIndex]['tensionDia']}'
                                            : '-',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                          color: Colors.red,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourbeSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Map<String, dynamic>> mesures;
  final String type; // 'poids' ou 'tension'

  const _CourbeSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.mesures,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Graphique amélioré
          SizedBox(
            height: 280,
            child: CustomPaint(
              size: Size.infinite,
              painter: _CourbePainter(
                mesures: mesures,
                color: color,
                type: type,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Légende
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: mesures.take(5).map((mesure) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'S${mesure['semaine']}',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Inter',
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (type == 'poids')
                        Text(
                          '${mesure['poids']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: color,
                          ),
                        )
                      else
                        Text(
                          '${mesure['tensionSys']}/${mesure['tensionDia']}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: color,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourbePainter extends CustomPainter {
  final List<Map<String, dynamic>> mesures;
  final Color color;
  final String type;

  _CourbePainter({
    required this.mesures,
    required this.color,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (mesures.isEmpty) return;

    // Trouver les valeurs min et max
    double minValue, maxValue;
    if (type == 'poids') {
      minValue = mesures.map((m) => m['poids'] as double).reduce(math.min) - 2;
      maxValue = mesures.map((m) => m['poids'] as double).reduce(math.max) + 2;
    } else {
      minValue = mesures.map((m) => (m['tensionSys'] as int).toDouble()).reduce(math.min) - 10;
      maxValue = mesures.map((m) => (m['tensionSys'] as int).toDouble()).reduce(math.max) + 10;
    }

    final range = maxValue - minValue;
    final leftPadding = 50.0;
    final rightPadding = 16.0;
    final topPadding = 30.0;
    final bottomPadding = 50.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Dessiner la grille de fond
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    // Lignes horizontales de la grille (4 lignes)
    for (int i = 0; i <= 4; i++) {
      final y = topPadding + (chartHeight * i / 4);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(leftPadding + chartWidth, y),
        gridPaint,
      );
    }

    // Lignes verticales de la grille
    for (int i = 0; i < mesures.length; i++) {
      final x = leftPadding + (chartWidth * i / (mesures.length - 1));
      canvas.drawLine(
        Offset(x, topPadding),
        Offset(x, topPadding + chartHeight),
        gridPaint,
      );
    }

    // Calculer les points de la courbe
    final List<Offset> points = [];
    for (int i = 0; i < mesures.length; i++) {
      final mesure = mesures[i];
      double value;
      if (type == 'poids') {
        value = mesure['poids'] as double;
      } else {
        value = (mesure['tensionSys'] as int).toDouble();
      }

      final x = leftPadding + (chartWidth * i / (mesures.length - 1));
      final normalizedValue = (value - minValue) / range;
      final y = topPadding + chartHeight - (chartHeight * normalizedValue);
      points.add(Offset(x, y));
    }

    // Dessiner la zone remplie sous la courbe (gradient)
    if (points.isNotEmpty) {
      final fillPath = Path();
      fillPath.moveTo(points.first.dx, topPadding + chartHeight);
      for (final point in points) {
        fillPath.lineTo(point.dx, point.dy);
      }
      fillPath.lineTo(points.last.dx, topPadding + chartHeight);
      fillPath.close();

      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.05),
          ],
        ).createShader(Rect.fromLTWH(0, topPadding, size.width, chartHeight))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, gradientPaint);
    }

    // Dessiner la ligne de la courbe
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    if (points.isNotEmpty) {
      linePath.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(linePath, linePaint);
    }

    // Dessiner les points avec cercles améliorés
    for (final point in points) {
      // Cercle extérieur (ombre)
      final shadowPaint = Paint()
        ..color = color.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 8, shadowPaint);

      // Cercle principal
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 6, pointPaint);

      // Cercle intérieur blanc
      final innerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 3, innerPaint);

      // Contour du cercle
      final outlinePaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(point, 6, outlinePaint);
    }

    // Dessiner les labels des axes Y
    final textStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 10,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
    );

    final textPainterMax = TextPainter(
      text: TextSpan(
        text: type == 'poids' 
            ? '${maxValue.toStringAsFixed(1)} kg'
            : '${maxValue.toInt()}',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterMax.layout();
    textPainterMax.paint(
      canvas,
      Offset(leftPadding - textPainterMax.width - 8, topPadding - 8),
    );

    final textPainterMin = TextPainter(
      text: TextSpan(
        text: type == 'poids'
            ? '${minValue.toStringAsFixed(1)} kg'
            : '${minValue.toInt()}',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterMin.layout();
    textPainterMin.paint(
      canvas,
      Offset(leftPadding - textPainterMin.width - 8, topPadding + chartHeight - textPainterMin.height + 8),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

