import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cnn_service.dart';
import 'assessment_screen.dart';

class WoundImageScreen extends StatefulWidget {
  const WoundImageScreen({super.key});

  @override
  State<WoundImageScreen> createState() => _WoundImageScreenState();
}

class _WoundImageScreenState extends State<WoundImageScreen> {
  XFile? selectedImage;

  bool analyzing = false;

  CnnResult? cnnResult;

  final ImagePicker picker = ImagePicker();
  final CnnService cnnService = CnnService();

  Future<void> takePhoto() async {
    final image = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (image != null) {
      setState(() {
        selectedImage = image;
        cnnResult = null;
      });
    }
  }

  Future<void> choosePhoto() async {
    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = image;
        cnnResult = null;
      });
    }
  }

  Future<void> analyzeImage() async {
    if (selectedImage == null) {
      return;
    }

    setState(() {
      analyzing = true;
      cnnResult = null;
    });

    final result = await cnnService.analyzeImage(
      selectedImage!.path,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      analyzing = false;
      cnnResult = result;
    });
  }

  void continueToQuestionnaire() {
    if (cnnResult == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentScreen(
          cnnCategory: cnnResult!.category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wound Image Assessment'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Animal Bite Wound',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Take or upload a clear photo of the wound '
                    'for AI-assisted assessment.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(selectedImage!.path),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 80,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take a Photo'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: choosePhoto,
                      icon: const Icon(Icons.photo),
                      label: const Text('Choose Photo'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                  selectedImage != null && !analyzing
                      ? analyzeImage
                      : null,
                  child: analyzing
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )
                      : const Text('Analyze Image'),
                ),
              ),

              if (cnnResult != null) ...[
                const SizedBox(height: 30),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI-Assisted Assessment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          cnnResult!.category,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Temporary CNN confidence: '
                              '${(cnnResult!.confidence * 100).toStringAsFixed(0)}%',
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'This is a preliminary AI-assisted '
                              'assessment and does not replace '
                              'professional medical evaluation.',
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                            continueToQuestionnaire,
                            child: const Text(
                              'Continue to Animal Bite Assessment',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}