// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/others/product_model.dart';

void showIngredientDetails(BuildContext context, ProductModel product,
    WidgetRef ref, Function(ProductModel, String, double) onSave) {
  TextEditingController amountController = TextEditingController();
  String selectedUnit = 'g';
  double grams = 100.0;

  void updateValues(StateSetter setState) {
    setState(() {
      double factor = double.tryParse(amountController.text) ?? 100.0;
      if (selectedUnit == 'kg') {
        factor *= 1000;
      }
      grams = factor;
    });
  }

  void handleInput(String value, StateSetter setState) {
    value = value.replaceAll(',', '.');
    setState(() {
      amountController.text = value;
      amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountController.text.length),
      );
      updateValues(setState);
    });
  }

  showModalBottomSheet(
    backgroundColor: Theme.of(context).colorScheme.primary,
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          double kcal = (product.kcal * grams) / 100;
          double protein = ((product.protein ?? 0) * grams) / 100;
          double fat = ((product.fat ?? 0) * grams) / 100;
          double carbs = ((product.carbs ?? 0) * grams) / 100;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 25.0, right: 10),
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 15),
                      child: IconButton(
                        iconSize: 27,
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          double? amount =
                              double.tryParse(amountController.text);
                          if (amount != null) {
                            onSave(product, selectedUnit, amount);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Theme.of(context).colorScheme.secondary,
                  height: 32,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          cursorColor: Theme.of(context).primaryColorDark,
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Weight',
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColorDark),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark),
                            ),
                          ),
                          onChanged: (value) => handleInput(value, setState),
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedUnit,
                        items: ['g', 'kg', 'ml']
                            .map((unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUnit = value!;
                            updateValues(setState);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16, 16, 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            kcal.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              'Kcal',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${(protein % 1 == 0 ? protein.toStringAsFixed(0) : protein.toStringAsFixed(2))}g',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              'Protein',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${(fat % 1 == 0 ? fat.toStringAsFixed(0) : fat.toStringAsFixed(2))}g',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              'Fat',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${(carbs % 1 == 0 ? carbs.toStringAsFixed(0) : carbs.toStringAsFixed(2))}g',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              'Carbs',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColorDark,
                              ),
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
