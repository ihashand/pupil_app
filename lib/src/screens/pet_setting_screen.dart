import 'package:flutter/material.dart';

class PetSettingsScreen extends StatefulWidget {
  const PetSettingsScreen({super.key});

  @override
  createState() => _PetSettingsScreenState();
}

class _PetSettingsScreenState extends State<PetSettingsScreen> {
  final TextEditingController kcalController = TextEditingController();
  final List<TextEditingController> mealControllers = [];
  int mealCount = 3;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < mealCount; i++) {
      mealControllers.add(TextEditingController(text: 'Meal ${i + 1}'));
    }
  }

  @override
  void dispose() {
    kcalController.dispose();
    for (var controller in mealControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: kcalController,
              decoration: InputDecoration(
                labelText: 'Daily Kcal Requirement',
                labelStyle:
                    TextStyle(color: Theme.of(context).primaryColorDark),
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColorDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColorDark),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text(
              'Meal Types',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            ...List.generate(mealCount, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: mealControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Meal ${index + 1} Name',
                    labelStyle:
                        TextStyle(color: Theme.of(context).primaryColorDark),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColorDark),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColorDark),
                    ),
                  ),
                ),
              );
            }),
            if (mealCount < 8)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    mealCount++;
                    mealControllers
                        .add(TextEditingController(text: 'Meal $mealCount'));
                  });
                },
                child: Text('Add Meal Type'),
              ),
            if (mealCount == 8)
              Text(
                'Maximum number of meal types reached.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
