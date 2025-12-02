import 'package:flutter/material.dart';
import 'package:esante/models/users/maman_model.dart';
import 'package:esante/theme/app_theme.dart';

class Profil extends StatelessWidget {
  const Profil({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemple de maman connectée (statique pour l'instant)
    const maman = MamanModel(
      id: 1,
      nom: 'Diop',
      prenom: 'Awa',
      email: 'awa.diop@example.com',
      telephone: '+221 77 123 45 67',
      adresse: 'Dakar, Yoff',
      dateNaissance: '12/03/1992',
      nombreEnfants: 3,
      profession: 'Commerçante',
    );

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
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    children: [
                      // Top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mon Profil',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.white),
                              onPressed: () {
                                // TODO: Modifier profil
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Avatar & Infos principales
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            maman.prenom[0] + maman.nom[0],
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        maman.nomComplet,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.child_friendly, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${maman.nombreEnfants} enfants',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
                      icon: Icons.pregnant_woman,
                      value: '3',
                      label: 'Grossesses',
                      color: AppTheme.primaryGreen,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade200,
                    ),
                    _QuickStat(
                      icon: Icons.calendar_today,
                      value: '12',
                      label: 'Consultations',
                      color: AppTheme.accentBlue,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade200,
                    ),
                    _QuickStat(
                      icon: Icons.vaccines,
                      value: '8',
                      label: 'Vaccins',
                      color: AppTheme.accentOrange,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===== SECTIONS D'INFORMATIONS =====
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Informations personnelles
                _ProfileSection(
                  title: 'Informations personnelles',
                  icon: Icons.person_outline,
                  children: [
                    _ProfileInfoRow(
                      icon: Icons.cake_outlined,
                      iconColor: AppTheme.accentPink,
                      label: 'Date de naissance',
                      value: maman.dateNaissance,
                    ),
                    _ProfileInfoRow(
                      icon: Icons.work_outline,
                      iconColor: AppTheme.accentPurple,
                      label: 'Profession',
                      value: maman.profession,
                    ),
                    _ProfileInfoRow(
                      icon: Icons.location_on_outlined,
                      iconColor: AppTheme.accentOrange,
                      label: 'Adresse',
                      value: maman.adresse,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Contact
                _ProfileSection(
                  title: 'Contact',
                  icon: Icons.contact_mail_outlined,
                  children: [
                    _ProfileInfoRow(
                      icon: Icons.phone_outlined,
                      iconColor: AppTheme.primaryGreen,
                      label: 'Téléphone',
                      value: maman.telephone,
                    ),
                    _ProfileInfoRow(
                      icon: Icons.email_outlined,
                      iconColor: AppTheme.accentBlue,
                      label: 'Email',
                      value: maman.email,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Sécurité
                _ProfileSection(
                  title: 'Sécurité',
                  icon: Icons.security_outlined,
                  children: [
                    _ProfileActionRow(
                      icon: Icons.lock_outline,
                      iconColor: AppTheme.textGrey,
                      label: 'Changer le mot de passe',
                      onTap: () {
                        // TODO: Changer mot de passe
                      },
                    ),
                    _ProfileActionRow(
                      icon: Icons.fingerprint,
                      iconColor: AppTheme.textGrey,
                      label: 'Authentification biométrique',
                      trailing: Switch(
                        value: false,
                        onChanged: (val) {},
                        activeColor: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Bouton déconnexion
                Container(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Déconnexion
                    },
                    icon: const Icon(Icons.logout, color: AppTheme.accentRed),
                    label: const Text(
                      'Se déconnecter',
                      style: TextStyle(
                        color: AppTheme.accentRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.accentRed),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== WIDGETS RÉUTILISABLES =====

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
          child: Icon(icon, color: color, size: 24),
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
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.textGrey),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textDark,
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

class _ProfileActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ProfileActionRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }
}
