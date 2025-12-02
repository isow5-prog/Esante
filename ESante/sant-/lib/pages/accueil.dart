import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Accueil extends StatelessWidget {
  const Accueil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===== BARRE NAVIGATION BAS =====
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 10, top: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _BottomItem(icon: Icons.home, label: "Accueil", active: true),
            _BottomItem(icon: Icons.book, label: "Carnet"),
            _BottomItem(icon: Icons.person, label: "Profiles"),
            _BottomItem(icon: Icons.settings, label: "Parametre"),
          ],
        ),
      ),

      // ===== CONTENU =====
      body: Column(
        children: [
          // ===== HEADER VERT =====
          Container(
            height: 230,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF23A036),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 60,
                  right: 25,
                  child: Icon(Icons.notifications_none,
                      color: Colors.white, size: 30),
                ),
              ],
            ),
          ),

          // ===== SECTION QR GAUCHE =====
          Transform.translate(
            offset: const Offset(0, -120),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF1AAA42),
                borderRadius: BorderRadius.circular(35),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: "qr-data-example",
                          version: QrVersions.auto,
                          size: 150,
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 20),
                            SizedBox(width: 6),
                            Text("Scanner"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: -80),

          // ===== TEXTE TELECHARGER =====
          Transform.translate(
            offset: const Offset(0, -130),
            child: Column(
              children: const [
                Text(
                  "Techarger",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 5),
                Icon(Icons.download, size: 25),
              ],
            ),
          ),

          // ===== NOMBRE DE CARNETS =====
          Transform.translate(
            offset: const Offset(0, -110),
            child: Container(
              width: 110,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F9),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text(
                "3",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -105),
            child: const Text(
              "Nombres de carnets",
              style: TextStyle(fontSize: 16),
            ),
          ),

          // ===== BOUTON CONSULTER MES CARNETS =====
          Transform.translate(
            offset: const Offset(0, -80),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              margin: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.black12, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.calendar_month,
                      color: Color(0xFF1AAA42), size: 25),
                  SizedBox(width: 10),
                  Text(
                    "Consulter mes carnets",
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _BottomItem({
    required this.icon,
    required this.label,
    this.active = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? Color(0xFF23A036) : Colors.black54),
        Text(
          label,
          style: TextStyle(
            color: active ? Color(0xFF23A036) : Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
