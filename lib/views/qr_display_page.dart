import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRDisplayPage extends StatelessWidget {
  final String qrData;

  // Le constructeur prend en paramètre les données à afficher dans le QR
  const QRDisplayPage({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Code")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Affichage du QR code
           QrImageView(
  data: qrData,
  version: QrVersions.auto,
  size: 320,
  gapless: false,
),
            SizedBox(height: 20),
            // Bouton pour revenir à la page précédente
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Retour à la page précédente
              },
              child: Text("Retour"),
            ),
          ],
        ),
      ),
    );
  }
}
