import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class BabyCryResult {
  const BabyCryResult({
    required this.label,
    required this.score,
    required this.predictions,
    required this.source,
    required this.model,
    required this.debug,
  });

  final String label;
  final double score;
  final List<BabyCryPrediction> predictions;
  final String source;
  final String model;
  final Map<String, dynamic> debug;

  String get displayText {
    final confidence = (score * 100).toStringAsFixed(1);
    return 'AI result: $label ($confidence% confidence)';
  }

  factory BabyCryResult.fromJson(Map<String, dynamic> json) {
    return BabyCryResult(
      label: json['label']?.toString() ?? 'Unknown',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      predictions: (json['predictions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(BabyCryPrediction.fromJson)
          .toList(),
      source: json['source']?.toString() ?? 'unknown',
      model: json['model']?.toString() ?? 'unknown',
      debug: json['debug'] as Map<String, dynamic>? ?? const {},
    );
  }
}

class BabyCryPrediction {
  const BabyCryPrediction({
    required this.label,
    required this.score,
  });

  final String label;
  final double score;

  factory BabyCryPrediction.fromJson(Map<String, dynamic> json) {
    return BabyCryPrediction(
      label: json['label']?.toString() ?? 'Unknown',
      score: (json['score'] as num?)?.toDouble() ?? 0,
    );
  }
}

class BabyCryService {
  static String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  static Future<BabyCryResult> analyzeAudio(String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/baby-cry/analyze'),
    );

    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send().timeout(
          const Duration(seconds: 120),
        );
    final response = await http.Response.fromStream(streamedResponse).timeout(
      const Duration(seconds: 120),
    );

    if (response.statusCode != 200) {
      throw Exception('Baby cry analysis failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['error'] != null) {
      throw Exception(data['error']);
    }

    return BabyCryResult.fromJson(data);
  }
}
