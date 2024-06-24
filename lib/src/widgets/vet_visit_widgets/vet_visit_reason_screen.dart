import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/widgets/vet_visit_widgets/vet_visit_date_screen.dart';

class VetVisitReasonScreen extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final String petId;

  const VetVisitReasonScreen(
      {super.key, required this.ref, required this.petId});

  @override
  createState() => _VetVisitReasonScreenState();
}

class _VetVisitReasonScreenState extends ConsumerState<VetVisitReasonScreen> {
  String selectedReason = '';
  final TextEditingController otherReasonController = TextEditingController();
  final TextEditingController vaccineController = TextEditingController();
  final TextEditingController healthIssueController = TextEditingController();
  List<String> selectedSymptoms = [];
  List<String> selectedVaccines = [];
  final List<String> symptoms = [
    'Lack of appetite',
    'Reluctance to play',
    'Apathy',
    'Irritability and aggression',
    'Fever',
    'Diarrhea',
    'Vomiting',
    'Bloating',
    'Itching',
    'Significant weight loss',
    'Movement problems',
    'Drooling',
    'Seizures',
    'Pale gums',
  ];
  final List<String> vaccines = [
    'Distemper',
    'Parvovirus',
    'Hepatitis',
    'Rabies',
    'Other'
  ];

  @override
  void dispose() {
    otherReasonController.dispose();
    vaccineController.dispose();
    healthIssueController.dispose();
    super.dispose();
  }

  Widget buildSymptomCheckbox(String symptom) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
      child: Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: Colors.grey,
        ),
        child: CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(symptom, style: const TextStyle(fontSize: 12)),
          value: selectedSymptoms.contains(symptom),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                if (selectedSymptoms.length < 10) {
                  selectedSymptoms.add(symptom);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You can add up to 10 symptoms.'),
                    ),
                  );
                }
              } else {
                selectedSymptoms.remove(symptom);
              }
            });
          },
          activeColor: const Color(0xff68a2b6),
          checkColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildVaccineRadio(String vaccine) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 2.0), // Jeszcze mniejszy odstęp
      child: Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: Colors.grey,
        ),
        child: RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          title: Text(vaccine, style: const TextStyle(fontSize: 12)),
          value: vaccine,
          groupValue:
              selectedVaccines.isNotEmpty ? selectedVaccines.first : null,
          onChanged: (value) {
            setState(() {
              selectedVaccines = [value!];
              if (value == 'Other') {
                vaccineController.clear();
              }
            });
          },
          activeColor: const Color(0xff68a2b6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'R E A S O N',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              size: 20,
            ),
            onPressed: () {
              if (selectedReason.isEmpty ||
                  (selectedReason == 'Other' &&
                      otherReasonController.text.isEmpty)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please select a reason or specify one.')),
                );
                return;
              }
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => VetVisitDateScreen(
                  ref: widget.ref,
                  petId: widget.petId,
                  visitReason: selectedReason == 'Other'
                      ? otherReasonController.text
                      : selectedReason,
                  selectedSymptoms: selectedSymptoms,
                  selectedVaccines: selectedVaccines,
                ),
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 40, bottom: 40, left: 15, right: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text(
                    'Reason for the vet visit',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    items: [
                      'Regular Checkup',
                      'Health Problem',
                      'Vaccination',
                      'Other',
                    ]
                        .map((reason) => DropdownMenuItem(
                              value: reason,
                              child: Text(reason,
                                  style: const TextStyle(fontSize: 12)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Reason',
                      labelStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color(0xff68a2b6), // Kolor dividera
                    thickness: 1,
                    height: 10,
                  ),
                  if (selectedReason == 'Other')
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: otherReasonController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          labelText: 'Specify the reason',
                          labelStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (selectedReason == 'Health Problem')
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Select Symptoms',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 3.2,
                          children: symptoms.map((symptom) {
                            return buildSymptomCheckbox(symptom);
                          }).toList(),
                        ),
                        TextField(
                          controller: healthIssueController,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Specify the symptom',
                            labelStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              if (value.isNotEmpty &&
                                  selectedSymptoms.length < 10) {
                                symptoms.add(value);
                                selectedSymptoms.add(value);
                                healthIssueController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  if (selectedReason == 'Vaccination')
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Select Vaccine',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 4,
                          children: vaccines.map((vaccine) {
                            return buildVaccineRadio(vaccine);
                          }).toList(),
                        ),
                        if (selectedVaccines.contains('Other'))
                          TextField(
                            controller: vaccineController,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              labelText: 'Specify the vaccine',
                              labelStyle: const TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                ),
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
      ),
    );
  }
}
