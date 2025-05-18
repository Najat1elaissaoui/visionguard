import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionguard/views/HomeController.dart';
import 'package:visionguard/widgets/button.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/text_field.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    numController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signupUser() async {
    final viewmodel = Provider.of<AuthViewModel>(context, listen: false);

    final success = await viewmodel.signUp(
      usernameController.text.trim(),
      emailController.text.trim(),
      numController.text.trim(),
      passwordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Homecontroller()),
      );
    } else if (mounted && viewmodel.errorMessage != null) {
      showSnackBar(context, viewmodel.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF003049),
              Color(0xFF8ECAE6),
                ],
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Create Your\nAccount',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFieldInput(
                      icon: Icons.person,
                      textEditingController: usernameController,
                      hintText: 'Enter your username',
                      textInputType: TextInputType.text,
                    ),
                    TextFieldInput(
                      icon: Icons.email,
                      textEditingController: emailController,
                      hintText: 'Enter your email',
                      textInputType: TextInputType.text,
                    ),
                    TextFieldInput(
                      icon: Icons.phone,
                      textEditingController: numController,
                      hintText: 'Enter your phone',
                      textInputType: TextInputType.text,
                    ),
                    TextFieldInput(
                      icon: Icons.lock,
                      textEditingController: passwordController,
                      hintText: 'Enter your password',
                      textInputType: TextInputType.text,
                      isPass: true,
                    ),
                    const SizedBox(height: 20),
                    viewmodel.isLoading
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                            onTap: signupUser,
                            child: Container(
                              height: 55,
                              width: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF003049),
              Color(0xFF8ECAE6),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'SIGN UP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'images/loogoo.png',
                            height: 60,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
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
