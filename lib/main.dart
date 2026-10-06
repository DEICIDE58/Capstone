import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const RabizCheckApp());
}

class RabizCheckApp extends StatelessWidget {
  const RabizCheckApp({super.key});

  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      title: 'RabizCheck',
      theme: ThemeData(useMaterial3: true,),
      home: const HomeScreen(),
    );
  }
}
