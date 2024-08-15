import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_step2_birthday.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_app_bar.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_segment_progress_bar.dart';

class AddPetStep1Name extends StatefulWidget {
  final WidgetRef ref;
  const AddPetStep1Name({super.key, required this.ref});

  @override
  createState() => _AddPetStep1NameState();
}

class _AddPetStep1NameState extends State<AddPetStep1Name> {
  bool _showTip = false;
  bool _hideTip = false;
  bool _showContainer = false;
  double _containerOffset =
      20.0; // Zmieniono początkowy offset, aby podnieść sektor wyżej

  @override
  void initState() {
    super.initState();

    // Animacja wysuwania sektora z AppBar
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showContainer = true;
      });

      // Rozpoczęcie animacji wyświetlania porady po 5 sekundach
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          _showTip = true;
          _containerOffset = 35.0; // Podniesienie głównego sektora
        });

        // Ukrycie porady po 10 sekundach
        Future.delayed(const Duration(seconds: 15), () {
          setState(() {
            _hideTip = true;
            _containerOffset = 20.0; // Powrót głównego sektora
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController petNameController = TextEditingController();

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
                      filledSegments: 1,
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
                      'Tip: A shorter name is often easier for your pet to recognize and for you to say!',
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
                            'Let\'s Choose the Name',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            'Your pet\'s name is important—it\'s how you’ll identify and interact with them. '
                            'Choose a name that’s unique and easy to call. Remember, that you can change name later in pet settings.',
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
                            child: InputDecorator(
                              decoration: InputDecoration(
                                fillColor: Theme.of(context).primaryColorDark,
                                labelText: 'Pet Name',
                                border: const OutlineInputBorder(),
                                labelStyle: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              child: TextFormField(
                                controller: petNameController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
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
                  if (petNameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter pet name.')),
                    );
                    return;
                  }
                  if (petNameController.text.length > 50) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Column(
                        children: [
                          Text(
                              'Your name is too long: ${petNameController.text.length}'),
                          const Text('Maximum length is 50 characters.')
                        ],
                      )),
                    );
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AddPetStep2Birthday(
                            ref: widget.ref,
                            petName: petNameController.text,
                          )));
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
