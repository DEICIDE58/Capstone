import 'package:flutter/material.dart';
import 'assessment_screen.dart';
import 'wound_image_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RabizCheck'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('RabizCheck',
              style: TextStyle(fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Animal Bite Assessment & Referral',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const WoundImageScreen(),
              ),
              );
            }, child: const Text(
                'Assess an Animal Bite'
            ),
            ),
            const SizedBox(height: 15),
            OutlinedButton(onPressed: () {}, child: const Text('Find an ABTC'),
            ),
          ],
        ),
      ),
    );
  }
}