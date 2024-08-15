import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_step3_gender.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_app_bar.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_segment_progress_bar.dart';

class AddPetStep2Birthday extends StatefulWidget {
  final WidgetRef ref;
  final String petName;
  const AddPetStep2Birthday(
      {super.key, required this.ref, required this.petName});

  @override
  createState() => _AddPetStep2BirthdayState();
}

class _AddPetStep2BirthdayState extends State<AddPetStep2Birthday> {
  bool _showTip = false;
  bool _hideTip = false;
  bool _showContainer = false;
  double _containerOffset = 20.0;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();

    // Animacja wysuwania sektora z AppBar
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showContainer = true;
      });

      // Rozpoczęcie animacji wyświetlania porady po 5 sekundach
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          _showTip = true;
          _containerOffset = 35.0;
        });

        // Ukrycie porady po 10 sekundach
        Future.delayed(const Duration(seconds: 10), () {
          setState(() {
            _hideTip = true;
            _containerOffset = 20.0;
          });
        });
      });
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'en_US').format(date);
  }

  @override
  Widget build(BuildContext context) {
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
                      filledSegments: 2,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      fillColor: const Color(0xffdfd785),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: _showTip && !_hideTip ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0)
                      .copyWith(
                          top: 35.0), // Pozycjonowanie Tip 20px nad sektorem
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Text(
                      'Tip: Accurate birthdate helps us to estimate your pet\'s age and provide tailored care tips!',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 2500),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                    top: _showContainer ? _containerOffset : 0.0,
                    left: 20,
                    right: 20),
                child: AnimatedOpacity(
                  opacity: _showContainer ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1200),
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
                            'Let\'s Set Your Pet\'s Birthdate',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            'The birthdate helps us provide age-appropriate recommendations. '
                            'You can update it later in pet settings.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 30,
                          ),
                          child: SizedBox(
                            height: 50,
                            width: 300,
                            child: ElevatedButton(
                              onPressed: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: true),
                                      child: Theme(
                                        data: ThemeData.light().copyWith(
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.black,
                                            ),
                                          ),
                                          colorScheme: ColorScheme.light(
                                            primary: const Color(0xffdfd785)
                                                .withOpacity(0.7),
                                            onPrimary: Colors.black,
                                          ),
                                        ),
                                        child: child!,
                                      ),
                                    );
                                  },
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    selectedDate = pickedDate;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).primaryColorDark,
                                backgroundColor: const Color(0xff68a2b6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Text(
                                _formatDate(selectedDate),
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
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddPetStep3Gender(
                      ref: widget.ref,
                      petName: widget.petName,
                      petAge: DateFormat('dd/MM/yyyy').format(selectedDate),
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
