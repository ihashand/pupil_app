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
  // ignore: library_private_types_in_public_api
  _AddPetStep4BreedState createState() => _AddPetStep4BreedState();
}

class _AddPetStep4BreedState extends State<AddPetStep4Breed> {
  final TextEditingController petBreedController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  OverlayEntry? overlayEntry;
  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    petBreedController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _showOverlay() {
    OverlayState? overlayState = Overlay.of(context);
    overlayEntry = _createOverlayEntry();
    overlayState.insert(overlayEntry!);
  }

  void _removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: LayerLink(),
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: suggestions
                  .map(
                    (suggestion) => ListTile(
                      title: Text(suggestion),
                      onTap: () {
                        petBreedController.text = suggestion;
                        _removeOverlay();
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _updateSuggestions(String query) {
    List<String> allBreeds = dogBreedGroups
        .expand((group) => group.sections)
        .expand((section) => section.breeds)
        .map((breed) => breed.name)
        .toList();

    setState(() {
      suggestions = allBreeds
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });

    if (overlayEntry != null) {
      overlayEntry?.markNeedsBuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: addPetAppBar(context, showCloseButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            AddPetSegmentProgressBar(
              totalSegments: 5,
              filledSegments: 4,
              backgroundColor: Theme.of(context).colorScheme.primary,
              fillColor: const Color(0xffdfd785).withOpacity(0.7),
            ),
            const SizedBox(
              height: 150,
            ),
            const Text(
              'Choose your pet breed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'You can change it later.',
            ),
            const SizedBox(height: 40),
            CompositedTransformTarget(
              link: LayerLink(),
              child: TextField(
                controller: petBreedController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Search breed',
                  border: OutlineInputBorder(),
                ),
                onChanged: (query) {
                  _updateSuggestions(query);
                },
              ),
            ),
            const SizedBox(
              height: 340,
            ),
            SizedBox(
              height: 40,
              width: 300,
              child: FloatingActionButton.extended(
                onPressed: () {
                  if (petBreedController.text.isEmpty) {
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
                      petBreed: petBreedController.text,
                    ),
                  ));
                },
                label: Text('Next',
                    style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 16)),
                backgroundColor: const Color(0xff68a2b6).withOpacity(0.7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
