import 'package:flutter/material.dart';
import 'package:esante/models/carnet/carnet_model.dart';
import 'package:esante/pages/detail_carnet.dart';
import 'package:esante/theme/app_theme.dart';

class Carnet extends StatefulWidget {
  const Carnet({super.key});

  @override
  State<Carnet> createState() => _CarnetState();
}

class _CarnetState extends State<Carnet> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Données simulées
  final List<CarnetModel> carnets = const [
    CarnetModel(
      id: '1',
      title: 'Carnet grossesse n°1',
      lastUpdate: 'Dernière mise à jour : 12 Nov 2025',
      mamanId: 'm1',
      numeroGrossesse: 1,
      statut: 'en_cours',
    ),
    CarnetModel(
      id: '2',
      title: 'Carnet grossesse n°2',
      lastUpdate: 'Dernière mise à jour : 08 Nov 2023',
      mamanId: 'm1',
      numeroGrossesse: 2,
      statut: 'termine',
    ),
    CarnetModel(
      id: '3',
      title: 'Carnet grossesse n°3',
      lastUpdate: 'Dernière mise à jour : 02 Nov 2021',
      mamanId: 'm1',
      numeroGrossesse: 3,
      statut: 'termine',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ===== HEADER HERO =====
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Mes Carnets",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.book_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  "${carnets.length}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Suivez l'historique de vos grossesses",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.85),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===== STATISTIQUES RAPIDES =====
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.shadowMd,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuickStat(
                      icon: Icons.child_care_rounded,
                      value: '3',
                      label: 'Grossesses',
                      color: AppTheme.primaryGreen,
                    ),
                    Container(width: 1, height: 40, color: Colors.grey.shade200),
                    _QuickStat(
                      icon: Icons.check_circle_outline,
                      value: '2',
                      label: 'Terminées',
                      color: AppTheme.accentBlue,
                    ),
                    Container(width: 1, height: 40, color: Colors.grey.shade200),
                    _QuickStat(
                      icon: Icons.pending_outlined,
                      value: '1',
                      label: 'En cours',
                      color: AppTheme.accentOrange,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===== TITRE SECTION =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Historique des carnets",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== LISTE DES CARNETS =====
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final carnet = carnets[index];
                  return AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      final delay = index * 0.15;
                      final animValue = Curves.easeOut.transform(
                        ((_animController.value - delay) / (1 - delay)).clamp(0.0, 1.0),
                      );
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - animValue)),
                        child: Opacity(
                          opacity: animValue,
                          child: child,
                        ),
                      );
                    },
                    child: _CarnetCard(
                      carnet: carnet,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailCarnet(carnet: carnet),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: carnets.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== WIDGETS =====

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _CarnetCard extends StatelessWidget {
  final CarnetModel carnet;
  final VoidCallback onTap;

  const _CarnetCard({
    required this.carnet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool estEnCours = carnet.statut == 'en_cours';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: estEnCours
              ? Border.all(color: AppTheme.primaryGreen.withOpacity(0.3), width: 2)
              : null,
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: estEnCours
                    ? AppTheme.primaryGradient
                    : LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                estEnCours ? Icons.menu_book_rounded : Icons.book_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          carnet.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      _StatutBadge(statut: carnet.statut),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    carnet.lastUpdate,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.child_friendly,
                        size: 14,
                        color: AppTheme.textGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Grossesse n°${carnet.numeroGrossesse}",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Inter',
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: estEnCours ? AppTheme.primaryGreen : AppTheme.textLight,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatutBadge extends StatelessWidget {
  final String statut;

  const _StatutBadge({required this.statut});

  @override
  Widget build(BuildContext context) {
    final bool estEnCours = statut == 'en_cours';
    final Color bgColor = estEnCours 
        ? AppTheme.accentBlue.withOpacity(0.1) 
        : AppTheme.primaryGreen.withOpacity(0.1);
    final Color textColor = estEnCours ? AppTheme.accentBlue : AppTheme.primaryGreen;
    final String label = estEnCours ? 'En cours' : 'Terminé';
    final IconData icon = estEnCours ? Icons.hourglass_top_rounded : Icons.check_circle_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
