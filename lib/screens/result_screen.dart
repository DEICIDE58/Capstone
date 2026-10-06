import 'package:flutter/material.dart';
import '../data/assessment_questions.dart';
import 'referral_screen.dart';

class ResultScreen extends StatelessWidget {
  final String category;
  final Map<String, String?> answers;

  const ResultScreen({
    super.key,
    required this.category,
    required this.answers,
  });

  String getQuestionText(String id) {
    final question = assessmentQuestions.firstWhere(
          (question) => question['id'] == id,
      orElse: () => {
        'question': id,
      },
    );

    return question['question'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Result'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assessment Complete',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preliminary AI-Assisted Assessment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'The image-based assessment provides '
                            'preliminary guidance based on the '
                            'information available. This result '
                            'does not replace evaluation by a '
                            'healthcare professional.',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Animal Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ...answers.entries.map(
                    (entry) {
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            getQuestionText(entry.key),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            entry.value ?? 'Not answered',
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              const Card(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Important: RabizCheck provides '
                        'preliminary AI-assisted guidance only. '
                        'It does not provide a medical diagnosis '
                        'or replace professional assessment.',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReferralScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Find an Animal Bite Treatment Center',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}