import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/models/product_model.dart';

void showProductDetails(BuildContext context, ProductModel product) {
  showModalBottomSheet(
    backgroundColor: Theme.of(context).colorScheme.primary,
    context: context,
    isScrollControlled: true,
    builder: (context) {
      TextEditingController gramsController =
          TextEditingController(text: '100');
      TextEditingController dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );
      String mealType = 'Breakfast';
      double grams = 100.0;

      return StatefulBuilder(
        builder: (context, setState) {
          void updateValues() {
            double factor = double.tryParse(gramsController.text) ?? 100 / 100;
            setState(() {
              grams = factor;
            });
          }

          double calculateFill(double kcal) {
            double fillPercentage = kcal / 700;
            return fillPercentage.clamp(0.0, 1.0);
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          // Akcja po naciśnięciu zapisz
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Theme.of(context).colorScheme.secondary,
                  height: 32,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16, top: 10, bottom: 10),
                  child: TextField(
                    controller: gramsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Grams',
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      updateValues();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16, top: 10, bottom: 10),
                  child: TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: 'Select Date',
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary:
                                    Theme.of(context).colorScheme.secondary,
                                onPrimary: Theme.of(context).primaryColorDark,
                                onSurface: Theme.of(context).primaryColorDark,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context)
                                      .primaryColorDark, // Kolor przycisków OK i Cancel
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedDate != null) {
                        setState(() {
                          dateController.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16, top: 10, bottom: 10),
                  child: DropdownButtonFormField<String>(
                    value: mealType,
                    decoration: InputDecoration(
                      labelText: 'Meal Type',
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                    items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                        .map((meal) => DropdownMenuItem(
                              value: meal,
                              child: Text(meal),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        mealType = value!;
                      });
                    },
                  ),
                ),
                Divider(
                  color: Theme.of(context).colorScheme.primary,
                  height: 32,
                ),
                // Sekcja danych
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 35.0, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Kcal w kółku z kreską
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 90, // Powiększenie kółka
                                height: 90, // Powiększenie kółka
                                child: CircularProgressIndicator(
                                  value:
                                      calculateFill(product.kcal * grams / 100),
                                  strokeWidth: 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    calculateFill(product.kcal * grams / 100) >=
                                            1.0
                                        ? Colors.purple
                                        : Colors.blue,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                child: Container(
                                  width: 2,
                                  height: 12,
                                  color: Colors.black,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    (product.kcal * grams / 100)
                                        .toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'kcal',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Węglowodany
                      Column(
                        children: [
                          Text(
                            '${((product.carbs ?? 0) / grams * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(product.carbs ?? 0) * grams / 100} g',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Węglowodany',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // Tłuszcz
                      Column(
                        children: [
                          Text(
                            '${((product.fat ?? 0) / grams * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(product.fat ?? 0) * grams / 100} g',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tłuszcz',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // Białko
                      Column(
                        children: [
                          Text(
                            '${((product.protein ?? 0) / grams * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(product.protein ?? 0) * grams / 100} g',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Białko',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
