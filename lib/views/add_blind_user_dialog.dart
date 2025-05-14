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
  final _mdpController = TextEditingController();
  String? selectedSex;
  String? selectedAvatar;
  final List<String> womanAvatars = [
    'assets/avatars/women_avatar_1.PNG',
    'assets/avatars/women_avatar_2.PNG',
    'assets/avatars/women_avatar_3.PNG',
    'assets/avatars/women_avatar_4.PNG',
    'assets/avatars/women_avatar_5.PNG',
    'assets/avatars/women_avatar_6.PNG',
  ];

  final List<String> manAvatars = [
    'assets/avatars/men_avatar_1.PNG',
    'assets/avatars/men_avatar_2.PNG',
    'assets/avatars/men_avatar_3.PNG',
    'assets/avatars/men_avatar_4.PNG',
    'assets/avatars/men_avatar_5.PNG',
    'assets/avatars/men_avatar_6.PNG',
  ];
  bool _showQR = false;
  String? _errorMessage;
  String? _blindUserName;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ControllerViewModel>(context);
    List<String> avatarOptions = selectedSex == 'Woman'
        ? womanAvatars
        : selectedSex == 'Man'
        ? manAvatars
        : [];
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
                if (!_showQR) ...[
                  // Titre visible uniquement avant la création du client
                  const Text(
                    'Add Blind User',
                    style: TextStyle(
                      color: Color(0xFF003049),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _nomController,
                    label: 'Nom',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _prenomController,
                    label: 'Prénom',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _mdpController,
                    label: 'Mot de passe',
                    icon: Icons.lock,
                  ),const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedSex,
                    decoration: const InputDecoration(
                      labelText: 'Sex',
                      prefixIcon: Icon(Icons.wc),
                      border: OutlineInputBorder(),
                    ),
                    items: ['Woman', 'Man'].map((sex) {
                      return DropdownMenuItem(
                        value: sex,
                        child: Text(sex),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSex = value;
                        selectedAvatar = null; // Reset avatar when sex changes
                      });
                    },),const SizedBox(height: 12),
                  if (avatarOptions.isNotEmpty) ...[
                    const Text("Choose an avatar:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      itemCount: avatarOptions.length,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final avatar = avatarOptions[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAvatar = avatar;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedAvatar == avatar ? Colors.blue : Colors.transparent,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(avatar),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    if (selectedAvatar != null)
                      Column(
                        children: [
                          const Text('Selected Avatar:'),
                          const SizedBox(height: 8),
                          Image.asset(selectedAvatar!, height: 80),
                        ],
                      ),
                  ],
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      final nom = _nomController.text.trim();
                      final prenom = _prenomController.text.trim();
                      final mdp = _mdpController.text.trim();

                      if (nom.isEmpty || prenom.isEmpty || mdp.isEmpty || selectedSex == null || selectedAvatar == null) {
                        setState(() {
                          _errorMessage = 'Veuillez remplir tous les champs';
                        });
                        return;
                      }

                      try {
                        // Vérifier si le mot de passe existe déjà dans la base de données
                        final existingUser = await viewModel.checkMdpExist(mdp);

                        if (existingUser) {
                          setState(() {
                            _errorMessage = 'Ce mot de passe existe déjà.';
                          });
                          return;
                        }

                        setState(() => _showQR = false);

                        await viewModel.createBlindUser(
                          nom: nom,
                          prenom: prenom,
                          mdp: mdp,
                          sex: selectedSex!,
                          avatarPath: selectedAvatar!,
                        );
                        await viewModel.fetchBlindUsers();

                        if (viewModel.qrCodeData != null && mounted) {
                          setState(() {
                            _blindUserName = "$nom $prenom";  // Récupère le nom complet
                            _showQR = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Client ajouté avec succès')),
                          );
                          await Future.delayed(const Duration(seconds: 3));
                          if (mounted) Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: ${e.toString()}')),
                          );
                        }
                      } finally {
                        _nomController.clear();
                        _prenomController.clear();
                        _mdpController.clear();
                      }
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
                ] else ...[
                  // Après la création du client aveugle, ne pas afficher le titre
                  const SizedBox(height: 12),
                  Text(
                    'Client ajouté avec succès',
                    style: TextStyle(
                      color: Color(0xFF003049),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nom : $_blindUserName',
                    style: TextStyle(
                      color: Color(0xFF003049),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  QrImageView(
                    data: viewModel.qrCodeData!,
                    version: QrVersions.auto,
                    size: 150,
                    backgroundColor: Colors.white,
                  ),
                ],
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
