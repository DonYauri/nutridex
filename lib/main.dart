import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/meal_provider.dart';
import 'screens/home_screen.dart';
import 'services/db_service.dart';
import 'services/gemini_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => MealProvider(DbService(), GeminiService())..load(),
      child: const NutriDexApp(),
    ),
  );
}

class NutriDexApp extends StatelessWidget {
  const NutriDexApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NutriDex',
        theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
        home: const HomeScreen(),
      );
}
