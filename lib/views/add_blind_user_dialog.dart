import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../viewmodels/controller_viewmodel.dart';

class AddBlindUserDialog extends StatefulWidget {
  const AddBlindUserDialog({super.key});

  @override
  State<AddBlindUserDialog> createState() => _AddBlindUserDialogState();
}

class _AddBlindUserDialogState extends State<AddBlindUserDialog> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  bool _showQR = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ControllerViewModel>(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Blind User',
                  style: TextStyle(
                    color: Color(0xFF003049),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nomController,
                  label: 'Nom',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _prenomController,
                  label: 'Prénom',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    final nom = _nomController.text.trim();
                    final prenom = _prenomController.text.trim();

                    if (nom.isEmpty || prenom.isEmpty) return;

                    await viewModel.createBlindUser(nom: nom, prenom: prenom);
                    await viewModel.fetchBlindUsers();

                    if (viewModel.qrCodeData != null) {
                      setState(() => _showQR = true);
                      await Future.delayed(const Duration(seconds: 3));
                    }

                    _nomController.clear();
                    _prenomController.clear();

                    if (mounted) Navigator.of(context).pop(); // ferme la popup
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF003049),
                          Color(0xFF8ECAE6),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Create Blind User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_showQR && viewModel.qrCodeData != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: QrImageView(
                      data: viewModel.qrCodeData!,
                      version: QrVersions.auto,
                      size: 150,
                      backgroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Color(0xFF003049)),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF003049)),
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF003049), fontWeight: FontWeight.bold),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF003049)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF003049)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
