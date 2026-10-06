class CnnResult {
  final String category;
  final double confidence;

  CnnResult({
    required this.category,
    required this.confidence,
  });
}

class CnnService {
  Future<CnnResult> analyzeImage(String imagePath) async {
    //temporary sa

    await Future.delayed(
      const Duration(seconds: 2),
    );

    return CnnResult(
      category: 'Category II',
      confidence: 0.85,
    );
  }
}