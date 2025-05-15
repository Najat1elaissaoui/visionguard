import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionguard/viewmodels/auth_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    _displayNameController.text = viewModel.displayName ?? '';
    _emailController.text = viewModel.displayEmail ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveAll() async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final name = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty && email.isEmpty && password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nothing to update")),
      );
      return;
    }

    bool success = true;

    if (name.isNotEmpty && name != viewModel.displayName) {
      success &= await viewModel.updateDisplayName(name);
    }
    if (email.isNotEmpty && email != viewModel.displayEmail) {
      success &= await viewModel.updateEmail(email);
    }
    if (password.isNotEmpty) {
      success &= await viewModel.updatePassword(password);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User info updated successfully')),
        );
        _passwordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? "An error occurred")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar + Name Section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    viewModel.displayName?.isNotEmpty == true
                        ? viewModel.displayName![0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  viewModel.displayName ?? 'No Name',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            "Profile Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Name Field
          TextField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),

          // Email Field
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Password Field
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          GestureDetector(
            onTap: viewModel.isLoading ? null : _saveAll,
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
              child: Center(
                child: viewModel.isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.save, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
