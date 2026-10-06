import 'package:flutter/material.dart';
import 'package:rabiz_check/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class UserRegistrationPage extends StatefulWidget {
  const UserRegistrationPage({super.key});

  @override
  State<UserRegistrationPage> createState() =>
      _UserRegistrationPageState();
}

class _UserRegistrationPageState
    extends State<UserRegistrationPage> {

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController ageController =
  TextEditingController();

  final TextEditingController locationController =
  TextEditingController();

  String? selectedGender;

  final List<String> genders = [
    'Male',
    'Female',
    'Prefer not to say',
  ];

  Future<void> registerUser() async {
    if (nameController.text.trim().isEmpty ||
        selectedGender == null ||
        ageController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all required information.',
          ),
        ),
      );

      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'user_name',
      nameController.text.trim(),
    );

    await prefs.setString(
      'user_gender',
      selectedGender!,
    );

    await prefs.setString(
      'user_age',
      ageController.text.trim(),
    );

    await prefs.setBool(
      'user_registered',
      true,
    );

    if (!mounted) return;


    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 40),

              const Text(
                'RABIZCHECK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'User Registration',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Please provide your information to continue.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 35),

              const Text(
                'Full Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Gender',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(
                  hintText: 'Select your gender',
                  border: OutlineInputBorder(),
                ),
                items: genders.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Age',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter your age',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: registerUser,
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Your information will be used to personalize '
                    'your RabizCheck experience and support assessment '
                    'and referral services.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}