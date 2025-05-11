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
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TITRE EN DEHORS DE LA CARTE
                Text(
                  "Informations sur ${widget.user.nom}",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // CARTE AVEC INFOS
                Container(
                  width: 300,
                  height: 380,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          infoLine("Nom :", widget.user.nom),
                          const SizedBox(height: 8),
                          infoLine("Prénom :", widget.user.prenom),
                          const SizedBox(height: 8),
                          infoLine(
                            "Mot de passe :",
                            widget.user.mdp != null && widget.user.mdp!.isNotEmpty
                                ? widget.user.mdp!
                                : 'Non disponible',
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Code QR :",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF003049),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          widget.user.qrCode != null && widget.user.qrCode!.isNotEmpty
                              ? QrImageView(
                                  data: widget.user.qrCode!,
                                  version: QrVersions.auto,
                                  size: 130.0,
                                )
                              : const Text("Aucun code QR disponible pour cet utilisateur."),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fonction utilitaire pour ligne d'info (label en bleu, donnée en noir)
  Widget infoLine(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF003049),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
