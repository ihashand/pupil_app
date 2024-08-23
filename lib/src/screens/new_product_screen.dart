// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/product_model.dart';
import 'package:pet_diary/src/providers/product_provider.dart';

class NewProductScreen extends ConsumerStatefulWidget {
  const NewProductScreen({super.key});

  @override
  createState() => _NewProductScreenState();
}

class _NewProductScreenState extends ConsumerState<NewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _kcalController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();
  final _proteinController = TextEditingController();

  bool _isGlobal = true;

  void _submitProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newProduct = ProductModel(
        id: UniqueKey().toString(),
        name: _nameController.text,
        brand: _brandController.text.isEmpty ? null : _brandController.text,
        barcode:
            _barcodeController.text.isEmpty ? null : _barcodeController.text,
        kcal: double.tryParse(_kcalController.text) ?? 0,
        fat: double.tryParse(_fatController.text) ?? 0,
        carbs: double.tryParse(_carbsController.text) ?? 0,
        protein: double.tryParse(_proteinController.text) ?? 0,
      );

      final productService = ref.read(productServiceProvider);

      await productService.addProduct(newProduct, isGlobal: _isGlobal);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'New Product',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        actions: [
          IconButton(
            // ignore: prefer_const_constructors
            icon: Icon(Icons.save, size: 20),
            onPressed: _submitProduct,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _kcalController,
                decoration: const InputDecoration(labelText: 'Energy (kcal)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the kcal value';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _brandController,
                decoration:
                    const InputDecoration(labelText: 'Brand (optional)'),
              ),
              TextFormField(
                controller: _barcodeController,
                decoration:
                    const InputDecoration(labelText: 'Barcode (optional)'),
              ),
              TextFormField(
                controller: _fatController,
                decoration:
                    const InputDecoration(labelText: 'Fat (g) (optional)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _carbsController,
                decoration: const InputDecoration(
                    labelText: 'Carbohydrates (g) (optional)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _proteinController,
                decoration:
                    const InputDecoration(labelText: 'Protein (g) (optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Add to Global Database'),
                value: _isGlobal,
                onChanged: (bool value) {
                  setState(() {
                    _isGlobal = value;
                  });
                },
                subtitle: Text(_isGlobal
                    ? 'This product will be visible to all users'
                    : 'This product will be visible only to you'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
