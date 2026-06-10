import 'dart:math';

class FakeAIService {
  static final Random _random = Random();

  static String analyzeBabyCry() {
    const results = [
      'AI result: The baby may be hungry 🍼',
      'AI result: The baby may be sleepy 😴',
      'AI result: The baby may need a diaper change 👶',
      'AI result: The baby may want attention ❤️',
      'AI result: The baby may feel uncomfortable 🌡️',
    ];

    return results[_random.nextInt(results.length)];
  }

  static String emergencyTip(String title) {
    const tips = {
      'Fever':
          'Keep the child hydrated, monitor temperature, and contact a doctor if the fever remains high.',
      'Choking':
          'Stay calm, check the airway, and seek emergency help immediately if breathing is difficult.',
      'Crying Nonstop':
          'Check hunger, diaper, temperature, and other discomfort signs. If crying continues, seek medical advice.',
      'Fall':
          'Check for injuries, swelling, vomiting, or unusual sleepiness. Go to emergency care if symptoms appear.',
    };

    return tips[title] ??
        'Monitor the symptoms and contact medical help when needed.';
  }

  static String generateGrowthComment(double weight, double height) {
    if (weight <= 0 || height <= 0) {
      return 'Please enter valid weight and height values first.';
    }

    if (weight < 5) {
      return 'AI note: Weight looks a little low for a baby profile. Keep monitoring regularly.';
    }

    if (weight > 20) {
      return 'AI note: Weight looks high for a baby profile. Double-check the entered value.';
    }

    return 'AI note: Growth data looks stable for this demo profile.';
  }
}
