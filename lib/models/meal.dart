class Meal {
  final int? id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String imageHash; // SHA-256 of the photo, used to avoid re-analysing
  final DateTime loggedAt;

  const Meal({
    this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.imageHash,
    required this.loggedAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'image_hash': imageHash,
        'logged_at': loggedAt.toIso8601String(),
      };

  factory Meal.fromMap(Map<String, Object?> m) => Meal(
        id: m['id'] as int?,
        name: m['name'] as String,
        calories: m['calories'] as int,
        protein: (m['protein'] as num).toDouble(),
        carbs: (m['carbs'] as num).toDouble(),
        fat: (m['fat'] as num).toDouble(),
        imageHash: m['image_hash'] as String,
        loggedAt: DateTime.parse(m['logged_at'] as String),
      );
}
