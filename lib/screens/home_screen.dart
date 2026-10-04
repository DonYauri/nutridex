import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/meal_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final provider = context.read<MealProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final file = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    await provider.logPhoto(file);
    if (provider.message != null) {
      messenger.showSnackBar(SnackBar(content: Text(provider.message!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MealProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('NutriDex')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              title: const Text('Calories today'),
              trailing: Text('${p.caloriesToday} kcal',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          if (p.busy) const LinearProgressIndicator(),
          Expanded(
            child: p.meals.isEmpty
                ? const Center(child: Text('Snap a meal to get started'))
                : ListView.builder(
                    itemCount: p.meals.length,
                    itemBuilder: (_, i) {
                      final m = p.meals[i];
                      return Dismissible(
                        key: ValueKey(m.id),
                        onDismissed: (_) => p.remove(m),
                        background: Container(color: Colors.red.shade300),
                        child: ListTile(
                          title: Text(m.name),
                          subtitle: Text(
                              'P ${m.protein.toStringAsFixed(0)}g · '
                              'C ${m.carbs.toStringAsFixed(0)}g · '
                              'F ${m.fat.toStringAsFixed(0)}g'),
                          trailing: Text('${m.calories} kcal'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'gallery',
            onPressed: p.busy ? null : () => _pick(context, ImageSource.gallery),
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: p.busy ? null : () => _pick(context, ImageSource.camera),
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
