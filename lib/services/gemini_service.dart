import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/meal.dart';

class FoodNotRecognisedException implements Exception {
  @override
  String toString() => 'No food could be recognised in that photo.';
}

/// Sends a food photo to Gemini Vision and parses a structured JSON reply.
/// Run with: --dart-define=GEMINI_API_KEY=... [--dart-define=GEMINI_MODEL=...]
class GeminiService {
  static const apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const modelName =
      String.fromEnvironment('GEMINI_MODEL', defaultValue: 'gemini-2.0-flash');

  static const _prompt = '''
You are a nutrition analyst. Identify the meal in the photo and estimate one
serving as shown. Reply with JSON only, in exactly this shape:
{"food_detected": true, "name": "string", "calories": 0,
 "protein_g": 0.0, "carbs_g": 0.0, "fat_g": 0.0}
If there is no food in the image, reply {"food_detected": false}.''';

  late final GenerativeModel _model = GenerativeModel(
    model: modelName,
    apiKey: apiKey,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      temperature: 0.2,
    ),
  );

  Future<Meal> analyse(Uint8List bytes, String mimeType, String imageHash) async {
    if (apiKey.isEmpty) {
      throw StateError('Missing GEMINI_API_KEY (use --dart-define).');
    }
    final response = await _model.generateContent([
      Content.multi([TextPart(_prompt), DataPart(mimeType, bytes)]),
    ]);

    final json = jsonDecode(response.text ?? '{}') as Map<String, dynamic>;
    if (json['food_detected'] != true) throw FoodNotRecognisedException();

    return Meal(
      name: json['name'] as String,
      calories: (json['calories'] as num).round(),
      protein: (json['protein_g'] as num).toDouble(),
      carbs: (json['carbs_g'] as num).toDouble(),
      fat: (json['fat_g'] as num).toDouble(),
      imageHash: imageHash,
      loggedAt: DateTime.now(),
    );
  }
}
