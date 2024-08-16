import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_step5_avatar.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_app_bar.dart';
import 'package:pet_diary/src/components/add_pet_steps/dogs_breed_data.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_segment_progress_bar.dart';

class AddPetStep4Breed extends StatefulWidget {
  final WidgetRef ref;
  final String petName;
  final String petAge;
  final String petGender;

  const AddPetStep4Breed({
    super.key,
    required this.ref,
    required this.petName,
    required this.petAge,
    required this.petGender,
  });

  @override
  createState() => _AddPetStep4BreedState();
}

class _AddPetStep4BreedState extends State<AddPetStep4Breed> {
  bool _showContainer = false;
  double _containerOffset = 10.0;

  final TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All';
  List<String> filteredBreeds = [];
  String selectedBreed = '';

  @override
  void initState() {
    super.initState();

    // Inicjalizacja filtrowanej listy ras
    filteredBreeds = _getAllBreeds();

    // Ustawienie animacji kontenera
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showContainer = true;
      });

      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          _containerOffset = 10.0;
        });
      });
    });
  }

  List<String> _getAllBreeds() {
    // Użyj `Set` aby usunąć duplikaty
    return dogBreedGroups
        .expand((group) => group.sections)
        .expand((section) => section.breeds)
        .map((breed) => breed.name)
        .toSet()
        .toList();
  }

  void _filterBreeds(String query) {
    setState(() {
      filteredBreeds = _getBreedsByCategory(selectedCategory)
          .where((breed) => breed.toLowerCase().contains(query.toLowerCase()))
          .toSet()
          .toList();
    });
  }

  List<String> _getBreedsByCategory(String category) {
    if (category == 'All') {
      return _getAllBreeds();
    }
    return dogBreedGroups
        .where((group) => group.groupName == category)
        .expand((group) => group.sections)
        .expand((section) => section.breeds)
        .map((breed) => breed.name)
        .toSet()
        .toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: addPetAppBar(context, showCloseButton: true),
      body: Column(
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
                  filledSegments: 4,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  fillColor: const Color(0xffdfd785),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Choose your pet breed',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                            searchController.clear(); // Czyszczenie inputu
                            _filterBreeds(''); // Resetowanie filtrów
                          });
                        },
                        items: <String>[
                          'All',
                          ...dogBreedGroups.map((group) => group.groupName)
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value.replaceFirst(
                                  'Group ', ''), // Usuwa "Group "
                            ),
                          );
                        }).toList(),
                        isExpanded: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Search breed',
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
                        cursorColor: Theme.of(context).primaryColorDark,
                        onChanged: _filterBreeds,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: SizedBox(
                        height: 250,
                        child: ListView.builder(
                          itemCount: filteredBreeds.length,
                          itemBuilder: (context, index) {
                            final breed = filteredBreeds[index];
                            final isSelected = breed == selectedBreed;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(1.0),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xff68a2b6).withOpacity(0.5)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                title: Text(
                                  breed,
                                  style: TextStyle(
                                    fontSize: isSelected ? 16 : 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedBreed = breed;
                                    searchController.text = breed;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: SizedBox(
              height: 40,
              width: 300,
              child: FloatingActionButton.extended(
                onPressed: () {
                  if (searchController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select pet breed.')),
                    );
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddPetStep5Avatar(
                      ref: widget.ref,
                      petName: widget.petName,
                      petAge: widget.petAge,
                      petGender: widget.petGender,
                      petBreed: searchController.text,
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
