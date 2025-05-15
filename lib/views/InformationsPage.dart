import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/usermodel.dart';

class InformationsPage extends StatefulWidget {
  final UserModel user;

  const InformationsPage({super.key, required this.user});

  @override
  State<InformationsPage> createState() => _InformationsPageState();
}

class _InformationsPageState extends State<InformationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF003049),
              Color(0xFF8ECAE6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(26.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Informations sur ${widget.user.nom}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Profile Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      infoLine("Nom", widget.user.nom),
                      const SizedBox(height: 12),
                      infoLine("Prénom", widget.user.prenom),
                      const SizedBox(height: 12),
                      infoLine(
                        "Mot de passe",
                        widget.user.mdp != null && widget.user.mdp!.isNotEmpty
                            ? widget.user.mdp!
                            : 'Non disponible',
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Code QR",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003049),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: widget.user.qrCode != null &&
                            widget.user.qrCode!.isNotEmpty
                            ? QrImageView(
                          data: widget.user.qrCode!,
                          version: QrVersions.auto,
                          size: 130.0,
                        )
                            : const Text(
                            "Aucun code QR disponible pour cet utilisateur."),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget infoLine(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label :",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF003049),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
