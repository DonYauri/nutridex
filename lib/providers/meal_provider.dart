import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/meal.dart';
import '../services/db_service.dart';
import '../services/gemini_service.dart';
import '../services/image_hash.dart';

class MealProvider extends ChangeNotifier {
  MealProvider(this._db, this._gemini);

  final DbService _db;
  final GeminiService _gemini;

  List<Meal> _meals = [];
  bool _busy = false;
  String? _message;

  List<Meal> get meals => List.unmodifiable(_meals);
  bool get busy => _busy;
  String? get message => _message;

  int get caloriesToday {
    final now = DateTime.now();
    return _meals
        .where((m) =>
            m.loggedAt.year == now.year &&
            m.loggedAt.month == now.month &&
            m.loggedAt.day == now.day)
        .fold(0, (sum, m) => sum + m.calories);
  }

  Future<void> load() async {
    _meals = await _db.allMeals();
    notifyListeners();
  }

  /// Hash the photo, skip the API call if we've already analysed it,
  /// otherwise ask Gemini and store the result.
  Future<void> logPhoto(XFile file) async {
    _busy = true;
    _message = null;
    notifyListeners();
    try {
      final bytes = await file.readAsBytes();
      final hash = sha256Hex(bytes);

      if (await _db.findByHash(hash) != null) {
        _message = 'That photo is already logged.';
      } else {
        final mime = file.mimeType ?? 'image/jpeg';
        final meal = await _gemini.analyse(bytes, mime, hash);
        await _db.insertMeal(meal);
        _meals = await _db.allMeals();
        _message = 'Logged ${meal.name} (${meal.calories} kcal).';
      }
    } on FoodNotRecognisedException catch (e) {
      _message = e.toString();
    } catch (e) {
      _message = 'Something went wrong: $e';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> remove(Meal meal) async {
    if (meal.id == null) return;
    await _db.deleteMeal(meal.id!);
    _meals = await _db.allMeals();
    notifyListeners();
  }
}
