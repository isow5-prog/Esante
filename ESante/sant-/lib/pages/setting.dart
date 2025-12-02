import 'package:flutter/material.dart';
import 'package:esante/theme/app_theme.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ===== HEADER =====
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
                            "Réglages",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Personnalisez votre expérience",
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

          // ===== CONTENU =====
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // SECTION COMPTE
                _SectionHeader(
                  icon: Icons.person_outline_rounded,
                  title: "Compte",
                ),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.badge_outlined,
                      iconColor: AppTheme.primaryGreen,
                      title: "Informations personnelles",
                      subtitle: "Nom, prénom, date de naissance",
                      onTap: () {},
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      iconColor: AppTheme.accentBlue,
                      title: "Changer le mot de passe",
                      subtitle: "Sécurisez votre compte",
                      onTap: () {},
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.fingerprint_rounded,
                      iconColor: AppTheme.accentPurple,
                      title: "Authentification biométrique",
                      trailing: Switch(
                        value: _biometricEnabled,
                        onChanged: (val) => setState(() => _biometricEnabled = val),
                        activeColor: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // SECTION PRÉFÉRENCES
                _SectionHeader(
                  icon: Icons.tune_rounded,
                  title: "Préférences",
                ),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_active_outlined,
                      iconColor: AppTheme.accentOrange,
                      title: "Notifications",
                      subtitle: "Rappels et alertes",
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (val) => setState(() => _notificationsEnabled = val),
                        activeColor: AppTheme.primaryGreen,
                      ),
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      iconColor: AppTheme.textGrey,
                      title: "Mode sombre",
                      subtitle: "Activer le thème sombre",
                      trailing: Switch(
                        value: _darkModeEnabled,
                        onChanged: (val) => setState(() => _darkModeEnabled = val),
                        activeColor: AppTheme.primaryGreen,
                      ),
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      iconColor: AppTheme.accentBlue,
                      title: "Langue",
                      subtitle: "Français",
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // SECTION AIDE & SUPPORT
                _SectionHeader(
                  icon: Icons.help_outline_rounded,
                  title: "Aide & Support",
                ),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.question_answer_outlined,
                      iconColor: AppTheme.primaryGreen,
                      title: "FAQ",
                      subtitle: "Questions fréquentes",
                      onTap: () {},
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.headset_mic_outlined,
                      iconColor: AppTheme.accentBlue,
                      title: "Contacter le support",
                      subtitle: "Nous sommes là pour vous aider",
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // SECTION À PROPOS
                _SectionHeader(
                  icon: Icons.info_outline_rounded,
                  title: "À propos",
                ),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: AppTheme.accentPurple,
                      title: "Politique de confidentialité",
                      onTap: () {},
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      iconColor: AppTheme.accentOrange,
                      title: "Conditions d'utilisation",
                      onTap: () {},
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.verified_outlined,
                      iconColor: AppTheme.primaryGreen,
                      title: "Version de l'application",
                      subtitle: "v1.0.0 (Build 2025)",
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // BOUTON DÉCONNEXION
                Container(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.accentRed),
                    label: const Text(
                      "Se déconnecter",
                      style: TextStyle(
                        color: AppTheme.accentRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.accentRed),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // COPYRIGHT
                Center(
                  child: Text(
                    "E-Santé SN © 2025\nMinistère de la Santé du Sénégal",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded, color: AppTheme.accentRed),
            ),
            const SizedBox(width: 12),
            const Text("Déconnexion"),
          ],
        ),
        content: const Text("Êtes-vous sûre de vouloir vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Annuler",
              style: TextStyle(color: AppTheme.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Déconnexion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Déconnecter",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== WIDGETS =====

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textGrey),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textGrey,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 60,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ?? (onTap != null
                ? Icon(Icons.chevron_right_rounded, color: AppTheme.textLight)
                : const SizedBox()),
          ],
        ),
      ),
    );
  }
}
