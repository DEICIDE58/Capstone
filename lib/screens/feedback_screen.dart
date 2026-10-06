import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final List<Map<String, String>> questions = [
    {
      'id': 'ease_of_use',
      'question': 'How easy was the app to use?',
    },
    {
      'id': 'result_clarity',
      'question': 'How clear and understandable was the assessment result?',
    },
    {
      'id': 'referral_helpfulness',
      'question': 'How helpful were the ABTC referral and directions?',
    },
  ];

  late final Map<String, int?> ratings;

  final TextEditingController commentController = TextEditingController();

  bool submitting = false;

  @override
  void initState() {
    super.initState();

    ratings = {
      for (final question in questions) question['id']!: null,
    };
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> submitFeedback() async {
    if (ratings.values.any((rating) => rating == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all 3 rating questions.'),
        ),
      );

      return;
    }

    setState(() {
      submitting = true;
    });

    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getStringList('feedback_responses') ?? [];

    saved.add(
      jsonEncode({
        'submitted_at': DateTime.now().toIso8601String(),
        'ratings': ratings,
        'comment': commentController.text.trim(),
      }),
    );

    await prefs.setStringList('feedback_responses', saved);

    if (!mounted) {
      return;
    }

    setState(() {
      submitting = false;
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Thank you!'),
          content: const Text(
            'Your feedback helps us improve RabizCheck.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                      (route) => false,
                );
              },
              child: const Text('Back to Home'),
            ),
          ],
        );
      },
    );
  }

  Widget buildRatingQuestion(int index, Map<String, String> question) {
    final id = question['id']!;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${question['question']}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final value = i + 1;

                return ChoiceChip(
                  label: Text('$value'),
                  selected: ratings[id] == value,
                  onSelected: (_) {
                    setState(() {
                      ratings[id] = value;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 = Poor', style: TextStyle(fontSize: 12)),
                Text('5 = Excellent', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Feedback')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How was your experience?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please rate your experience using RabizCheck.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 25),

              for (int i = 0; i < questions.length; i++)
                buildRatingQuestion(i, questions[i]),

              const SizedBox(height: 5),

              const Text(
                '4. Do you have any other comments or suggestions '
                    'for improving the app?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                maxLines: 5,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Type your answer here (optional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitting ? null : submitFeedback,
                  child: submitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Submit Feedback'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}