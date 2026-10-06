class AssessmentResult {
  final String category;
  final String explanation;

  AssessmentResult({
    required this.category,
    required this.explanation,
  });
}

AssessmentResult determineCategory({
  required Map<String, String?> answers,
}) {
  final contactType = answers['contact_type'];
  final skinStatus = answers['skin_status'];
  final salivaContact = answers['saliva_contact'];
  final animalSpecies = answers['animal_species'];

  //Category I
  // Contact with the animal without an exposure.
  if (contactType == 'Touching or feeding the animal' ||
      contactType == 'Lick on intact skin') {
    return AssessmentResult(
      category: 'Category I',
      explanation:
      'The selected answers indicate contact without an identified rabies exposure.',
    );
  }

  // CATEGORY II
  // Nibbling of uncovered skin.
  if (contactType == 'Nibbling of uncovered skin') {
    return AssessmentResult(
      category: 'Category II',
      explanation:
      'The selected answers indicate an exposure involving nibbling of uncovered skin.',
    );
  }

  // Minor scratch without bleeding.
  if (contactType == 'Scratch' &&
      skinStatus == 'The skin was broken but did not bleed') {
    return AssessmentResult(
      category: 'Category II',
      explanation:
      'The selected answers indicate a minor exposure involving a scratch or abrasion without bleeding.',
    );
  }

  // CATEGORY III
  // Bite that broke the skin.
  if (contactType == 'Bite' &&
      (skinStatus == 'The skin was broken but did not bleed' ||
          skinStatus == 'The skin was broken and there was bleeding')) {
    return AssessmentResult(
      category: 'Category III',
      explanation:
      'The selected answers indicate a severe exposure involving a bite that broke the skin.',
    );
  }

  // Scratch that broke the skin and caused bleeding.
  if (contactType == 'Scratch' &&
      skinStatus == 'The skin was broken and there was bleeding') {
    return AssessmentResult(
      category: 'Category III',
      explanation:
      'The selected answers indicate a severe exposure involving a scratch that broke the skin and caused bleeding.',
    );
  }

  // Saliva contacting broken skin or mucous membranes.
  if (salivaContact == 'Yes') {
    return AssessmentResult(
      category: 'Category III',
      explanation:
      'The selected answers indicate exposure involving animal saliva contacting broken skin or a mucous membrane.',
    );
  }

  // Direct bat exposure.
  if (animalSpecies == 'Bat') {
    return AssessmentResult(
      category: 'Category III',
      explanation:
      'The selected answers indicate possible exposure involving a bat.',
    );
  }

  // ==================================================
  // UNCERTAIN
  // ==================================================

  return AssessmentResult(
    category: 'Needs Professional Assessment',
    explanation:
    'The available answers are not sufficient to confidently classify the exposure. Please seek professional assessment.',
  );
}