import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_step4_breed.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_app_bar.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_segment_progress_bar.dart';

class AddPetStep3Gender extends StatefulWidget {
  final WidgetRef ref;
  final String petName;
  final String petAge;

  const AddPetStep3Gender({
    super.key,
    required this.ref,
    required this.petName,
    required this.petAge,
  });

  @override
  createState() => _AddPetStep3GenderState();
}

class _AddPetStep3GenderState extends State<AddPetStep3Gender> {
  bool _showContainer = false;

  @override
  void initState() {
    super.initState();

    // Opóźnienie w celu wywołania animacji po załadowaniu ekranu
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _showContainer = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController petGenderController = TextEditingController();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: addPetAppBar(context, showCloseButton: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.primary,
                child: Column(
                  children: [
                    Divider(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    AddPetSegmentProgressBar(
                      totalSegments: 5,
                      filledSegments: 3,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      fillColor: const Color(0xffdfd785),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  top: _showContainer ? 150 : 200,
                  left: 20,
                  right: 20,
                ),
                child: AnimatedOpacity(
                  opacity: _showContainer ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Please select gender',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            'You can change it later in pet settings.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0, bottom: 15),
                          child: SizedBox(
                            height: 60,
                            width: 300,
                            child: DropdownButtonFormField<String>(
                              items: ['Male', 'Female'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark)),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                petGenderController.text = newValue!;
                              },
                              decoration: InputDecoration(
                                labelText: 'Choose gender',
                                labelStyle: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                                filled: false,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: SizedBox(
              height: 40,
              width: 300,
              child: FloatingActionButton.extended(
                onPressed: () {
                  if (petGenderController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select pet gender.')),
                    );
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddPetStep4Breed(
                      ref: widget.ref,
                      petName: widget.petName,
                      petAge: widget.petAge,
                      petGender: petGenderController.text,
                    ),
                  ));
                },
                label: Text('Next',
                    style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 16)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
