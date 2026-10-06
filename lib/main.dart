import 'package:flutter/material.dart';
import 'package:rabiz_check/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_registration.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final registered = prefs.getBool('user_registered') ?? false;

  runApp(
    RabizCheckApp(
      registered: registered,
    ),
  );
}

class RabizCheckApp extends StatelessWidget {
  final bool registered;

  const RabizCheckApp({
    super.key,
    required this.registered,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RabizCheck',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: registered
          ? const HomeScreen()
          : const UserRegistrationPage(),
    );
  }
}