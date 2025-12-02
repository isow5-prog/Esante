import 'package:esante/pages/home.dart';
import 'package:esante/pages/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:esante/pages/auth_inscription.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  bool _hasScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    final String? value = barcode?.rawValue;
    if (value == null) return;

    setState(() {
      _hasScanned = true;
    });

    // Pour l'instant : dès qu'on scanne la carte, on redirige vers la page d'inscription
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            // AuthInscriptionPage(qrValue: value),
            // AccueilPage(),
            MainNavigation(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        iconTheme: const IconThemeData(
          color: Colors.white, // couleur du bouton retour
        ),
        title: const Text('Scanner le QR Code',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF0A7A33),
      ),
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Zone de scan centrée, plus petite (style Wave / OM)
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: MobileScanner(
                  onDetect: _onDetect,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Placez le QR Code dans le cadre pour le scanner',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}


