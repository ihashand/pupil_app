import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/product_model.dart';
import 'package:pet_diary/src/providers/product_provider.dart';

void showNewProductBottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
    builder: (context) {
      final formKey = GlobalKey<FormState>();
      final nameController = TextEditingController();
      final brandController = TextEditingController();
      final barcodeController = TextEditingController();
      final kcalController = TextEditingController();
      final fatController = TextEditingController();
      final carbsController = TextEditingController();
      final proteinController = TextEditingController();

      bool isGlobal = true;

      void submitProduct() async {
        if (formKey.currentState?.validate() ?? false) {
          final newProduct = ProductModel(
            id: UniqueKey().toString(),
            name: nameController.text,
            brand: brandController.text.isEmpty ? null : brandController.text,
            barcode:
                barcodeController.text.isEmpty ? null : barcodeController.text,
            kcal: double.tryParse(kcalController.text) ?? 0,
            fat: double.tryParse(fatController.text) ?? 0,
            carbs: double.tryParse(carbsController.text) ?? 0,
            protein: double.tryParse(proteinController.text) ?? 0,
          );

          final productService = ref.read(productServiceProvider);

          await productService.addProduct(newProduct, isGlobal: isGlobal);

          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
      }

      void showInputDialog(
          BuildContext context, String label, TextEditingController controller,
          [Function(double)? onSave]) {
        final dialogController = TextEditingController(text: controller.text);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Enter new value for $label'),
              content: TextField(
                controller: dialogController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '$label Value',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final newValue = double.tryParse(dialogController.text);
                    if (newValue != null) {
                      controller.text = newValue.toString();
                      if (onSave != null) onSave(newValue);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  ),
                ),
              ],
            );
          },
        );
      }

      Widget buildNutrientIndicator(
          BuildContext context,
          String label,
          TextEditingController controller,
          String unit,
          Color color,
          StateSetter setState) {
        final value = double.tryParse(controller.text) ?? 0.0;
        return GestureDetector(
          onTap: () {
            showInputDialog(context, label, controller, (newValue) {
              setState(() {
                controller.text = newValue.toString();
              });
            });
          },
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 75,
                    height: 75,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 3,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: formKey,
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
                        const Text(
                          'New Product',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: submitProduct,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.secondary,
                    height: 32,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Product Name',
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                            ),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a product name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: brandController,
                          decoration: InputDecoration(
                            labelText: 'Brand (optional)',
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                            ),
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
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: barcodeController,
                                decoration: InputDecoration(
                                  labelText: 'Barcode (optional)',
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
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
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.qr_code_scanner),
                              color: Theme.of(context).primaryColorDark,
                              onPressed: () {
                                // Dodaj funkcjonalność skanowania
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildNutrientIndicator(context, 'Energy (kcal)',
                                kcalController, 'kcal', Colors.blue, setState),
                            buildNutrientIndicator(context, 'Fat (g)',
                                fatController, 'g', Colors.purple, setState),
                            buildNutrientIndicator(context, 'Carbs (g)',
                                carbsController, 'g', Colors.green, setState),
                            buildNutrientIndicator(
                                context,
                                'Protein (g)',
                                proteinController,
                                'g',
                                Colors.orange,
                                setState),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SwitchListTile(
                          title: const Text('Add to Global Database'),
                          value: isGlobal,
                          onChanged: (bool value) {
                            setState(() {
                              isGlobal = value;
                            });
                          },
                          subtitle: Text(
                            isGlobal
                                ? 'This product will be visible to all users'
                                : 'This product will be visible only to you',
                            style: TextStyle(
                              color: isGlobal
                                  ? Theme.of(context).primaryColorDark
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                          activeColor: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
