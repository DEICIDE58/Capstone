import 'package:flutter/material.dart';
import '../data/assessment_questions.dart';
import 'result_screen.dart';

class AssessmentScreen extends StatefulWidget {
  final String cnnCategory;

  const AssessmentScreen({
    super.key,
    required this.cnnCategory,
  });

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int currentQuestion = 0;
  String? selectedAnswer;

  final questions = assessmentQuestions;

  late Map<String, String?> answers;

  @override
  void initState() {
    super.initState();

    answers = {};

    for (final question in questions) {
      answers[question['id'] as String] = null;
    }
  }

  void nextQuestion() {
    final questionId = questions[currentQuestion]['id'] as String;

    answers[questionId] = selectedAnswer;

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;

        final nextQuestionId =
        questions[currentQuestion]['id'] as String;

        selectedAnswer = answers[nextQuestionId];
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            category: widget.cnnCategory,
            answers: answers,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];
    final answerList = question['answers'] as List;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Information'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question['section'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Question ${currentQuestion + 1} of ${questions.length}',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question['question'] as String,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      ...List.generate(
                        answerList.length,
                            (index) {
                          final answer = answerList[index] as String;

                          return RadioListTile<String>(
                            title: Text(answer),
                            value: answer,
                            groupValue: selectedAnswer,
                            onChanged: (value) {
                              setState(() {
                                selectedAnswer = value;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedAnswer == null ? null : nextQuestion,
                  child: Text(
                    currentQuestion == questions.length - 1
                        ? 'Finish'
                        : 'Next',
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