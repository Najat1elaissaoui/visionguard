import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visionguard/viewmodels/auth_viewmodel.dart';
import 'package:visionguard/viewmodels/controller_viewmodel.dart';
import 'package:visionguard/views/auth/login.dart';

void main() async {
  // Load the .env file
  await dotenv.load(fileName: ".env");
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ControllerViewModel()),
      ],
      child: MaterialApp(
        title: 'VisionGuard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 83, 180, 233),
          ),
          useMaterial3: true,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
