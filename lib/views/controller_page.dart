import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../viewmodels/controller_viewmodel.dart';

class ControllerPage extends StatefulWidget {
  @override
  _ControllerPageState createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  bool _showQR = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ControllerViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Add Blind User")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: _prenomController,
              decoration: InputDecoration(labelText: 'Prénom'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final nom = _nomController.text.trim();
                final prenom = _prenomController.text.trim();

                await viewModel.createBlindUser(nom: nom, prenom: prenom);

                await viewModel.fetchBlindUsers();

                if (viewModel.qrCodeData != null) {
                  setState(() {
                    _showQR = true;
                  });

                  Future.delayed(Duration(seconds: 5), () {
                    if (mounted) {
                      setState(() {
                        _showQR = false;
                      });
                    }
                  });
                }

                // Optionnel : nettoyer les champs
                _nomController.clear();
                _prenomController.clear();
              },

              child: Text("Create Blind User"),
            ),
            SizedBox(height: 20),
            if (_showQR && viewModel.qrCodeData != null)
              QrImageView(
                data: viewModel.qrCodeData!,
                version: QrVersions.auto,
                size: 200,
              ),
          ],
        ),
      ),
    );
  }
}
