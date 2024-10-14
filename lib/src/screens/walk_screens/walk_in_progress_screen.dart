// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/providers/walks_providers/walk_state_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pet_diary/src/screens/events_screens/event_type_selection_screen.dart';

List<apple_maps.LatLng> stoolEventPoints = [];
List<apple_maps.LatLng> urineEventPoints = [];

class WalkInProgressScreen extends ConsumerStatefulWidget {
  final List<Pet> pets;

  const WalkInProgressScreen({super.key, required this.pets});

  @override
  ConsumerState<WalkInProgressScreen> createState() =>
      _WalkInProgressScreenState();
}

class _WalkInProgressScreenState extends ConsumerState<WalkInProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  String? selectedPetName;
  String? _selectedPetName;
  int? _selectedPetIndex;
  Timer? _hideNameTimer;
  apple_maps.AppleMapController? _mapController;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _photos = [];
  final TextEditingController _notesController = TextEditingController();
  List<apple_maps.Polyline> eventLines = [];
  int _currentPage = 0;
  final int _eventsPerPage = 4;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mapController != null) {
        _goToCurrentLocation(_mapController!);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _hideNameTimer?.cancel();
    super.dispose();
  }

  void _pauseResumeWalk(BuildContext context, WalkNotifier walkNotifier) async {
    String action = walkNotifier.state.isPaused ? 'Resume' : 'Pause';
    bool confirm = await _showConfirmationDialog(context, action);
    if (confirm) {
      walkNotifier.pauseWalk();
    }
  }

  void _endWalk(BuildContext context, WalkNotifier walkNotifier) async {
    bool confirm = await _showConfirmationDialog(context, 'End');
    if (confirm) {
      walkNotifier.stopWalk();
      eventLines.clear();
      stoolEventPoints.clear();
      urineEventPoints.clear();
      Navigator.of(context).pop();
    }
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String action) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(action),
          content: Text('Are you sure you want to $action the walk?'),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                action,
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final walkState = ref.watch(walkProvider);
    final walkNotifier = ref.read(walkProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'A C T I V E  W A L K',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.surface,
          ),
          _buildMapContainer(walkState),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  _buildProgressBarWithDetailsConteiner(
                      context, walkState, walkNotifier),
                  const SizedBox(height: 20),
                  _buildEventSelectionContainer(),
                  const SizedBox(height: 20),
                  _buildNotesAndPhotosContainer(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, walkNotifier, walkState),
    );
  }

  Widget _buildMapContainer(WalkState walkState) {
    return Container(
      width: 500,
      height: 225,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      padding: const EdgeInsets.all(15.0),
      child: _buildAppleMapSection(walkState),
    );
  }

  void _togglePetNameDisplay(int index, String petName) {
    if (_selectedPetIndex == index) {
      setState(() {
        _selectedPetName = null;
        _selectedPetIndex = null;
      });
      _hideNameTimer?.cancel();
    } else {
      setState(() {
        _selectedPetName = petName;
        _selectedPetIndex = index;
      });
      _hideNameTimer?.cancel();
      _hideNameTimer = Timer(const Duration(seconds: 3), () {
        setState(() {
          _selectedPetName = null;
          _selectedPetIndex = null;
        });
      });
    }
  }

  Widget _buildProgressBarWithDetailsConteiner(
      BuildContext context, WalkState walkState, WalkNotifier walkNotifier) {
    double progressSteps =
        (walkState.currentSteps % walkState.goalSteps) / walkState.goalSteps;
    double progressTime = walkState.seconds / 3600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          value: progressSteps,
                          strokeWidth: 9,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xffdfd785)),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: progressTime,
                          strokeWidth: 6,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xff68a2b6)),
                        ),
                      ),
                      Icon(Icons.pets,
                          size: 24, color: Theme.of(context).primaryColorDark),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Duration:   ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        Text(
                          walkNotifier.formatTime(walkState.seconds),
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Distance:   ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        Text(
                          '${walkState.totalDistance.toStringAsFixed(2)} km',
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8),
              child: Divider(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                'P U P S  O N  W A L K:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 8.0,
              runSpacing: 8.0,
              children: widget.pets
                  .take(6)
                  .map(
                    (pet) => GestureDetector(
                      onTap: () {
                        _togglePetNameDisplay(
                            widget.pets.indexOf(pet), pet.name);
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(pet.avatarImage),
                            radius: 25,
                          ),
                          if (_selectedPetName != null &&
                              _selectedPetIndex == widget.pets.indexOf(pet))
                            Positioned(
                              top: -30,
                              left: -10,
                              right: -10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _selectedPetName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToCurrentLocation(
      apple_maps.AppleMapController controller) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final latLng = apple_maps.LatLng(position.latitude, position.longitude);
    controller.animateCamera(
      apple_maps.CameraUpdate.newLatLng(latLng),
    );
  }

  Widget _buildAppleMapSection(WalkState walkState) {
    return Stack(
      children: [
        apple_maps.AppleMap(
          initialCameraPosition: apple_maps.CameraPosition(
            target: walkState.routePoints.isNotEmpty
                ? apple_maps.LatLng(
                    walkState.routePoints.last.latitude,
                    walkState.routePoints.last.longitude,
                  )
                : const apple_maps.LatLng(51.5, -0.09),
            zoom: 16.0,
          ),
          onMapCreated: (apple_maps.AppleMapController controller) {
            _mapController = controller;
          },
          polylines: {
            apple_maps.Polyline(
              polylineId: apple_maps.PolylineId('route'),
              points: walkState.routePoints
                  .map((point) =>
                      apple_maps.LatLng(point.latitude, point.longitude))
                  .toList(),
              width: 15,
              color: const Color.fromARGB(255, 29, 121, 227),
            ),
            ...eventLines,
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
        Positioned(
          bottom: 7,
          right: 7,
          child: FloatingActionButton(
            onPressed: () {
              if (_mapController != null) {
                _goToCurrentLocation(_mapController!);
              }
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.my_location,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
      BuildContext context, WalkNotifier walkNotifier, WalkState walkState) {
    return BottomAppBar(
      height: 60,
      color: Theme.of(context).colorScheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 150,
            height: 40,
            child: ElevatedButton(
              onPressed: () => _endWalk(context, walkNotifier),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'F I N I S H',
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: 150,
            height: 40,
            child: ElevatedButton(
              onPressed: () => _pauseResumeWalk(context, walkNotifier),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                walkState.isPaused ? 'R E S U M E' : 'P A U S E',
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Widget _buildNotesAndPhotosContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildAddPhotoButton(),
                  const SizedBox(width: 10),
                  ..._buildPhotoPreviews(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: 'Take notes...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 1,
                    right: 1,
                    child: SizedBox(
                      width: 70,
                      height: 28,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _closeKeyboard,
                        child: Text(
                          'D O N E',
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: () {
        if (_photos.length >= 3) {
          _showMaxPhotosDialog();
        } else {
          _showImageSourceActionSheet();
        }
      },
      child: Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColorDark),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              color: Theme.of(context).primaryColorDark,
            ),
            Text(
              'Add photos',
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
          ],
        ),
      ),
    );
  }

  void _showMaxPhotosDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            'Maximum of 3 photos allowed.',
            style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('From gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null && _photos.length < 3) {
      setState(() {
        _photos.add(image);
      });
    }
  }

  List<Widget> _buildPhotoPreviews() {
    return _photos.map((photo) {
      return GestureDetector(
        onTap: () {
          _showPhotoPreview(photo);
        },
        child: Container(
          width: 100,
          height: 80,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(File(photo.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showPhotoPreview(XFile photo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: SizedBox(
            width: 350,
            height: 350,
            child: Image.file(
              File(photo.path),
              fit: BoxFit.contain,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 120,
                  height: 40,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 40,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _photos.remove(photo);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _handleMoreButtonPressed() {
    _selectPetsForEvent().then((selectedPets) {
      if (selectedPets.isNotEmpty) {
        List<String> petIds = selectedPets.map((pet) => pet.id).toList();
        _showAllEventTypesForPets(petIds);
      }
    });
  }

  void _showAllEventTypesForPets(List<String> petIds) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EventTypeSelectionScreen(petId: '', petIds: petIds),
      ),
    );
  }

  final List<Map<String, dynamic>> _addedEvents = [];

  Widget _buildEventSelectionContainer() {
    final List<Map<String, String>> eventOptions = [
      {'icon': '💩', 'label': 'Stool'},
      {'icon': '💦', 'label': 'Urine'},
      {'icon': '🐕', 'label': 'Barking'},
      {'icon': '😡', 'label': 'Growling'},
      {'icon': '👃', 'label': 'Sniffing'},
      {'icon': '🦮', 'label': 'Loose leash'},
      {'icon': '🐕‍🦺', 'label': 'Pulling on leash'},
      {'icon': '🚶‍♂️', 'label': 'Off-leash'},
      {'icon': '🐶', 'label': 'Meeting new pet'},
      {'icon': '🏃', 'label': 'Attempted escape'},
      {'icon': '🍂', 'label': 'Attempted to eat trash'},
      {'icon': '🐾', 'label': 'Digging in dirt'},
      {'icon': '💧', 'label': 'Drinking from puddle'},
      {'icon': '🛏️', 'label': 'Resting'},
      {'icon': '🐕‍🔥', 'label': 'Chasing'},
      {'icon': '👟', 'label': 'Running'},
      {'icon': '🐦', 'label': 'Watching birds'},
      {'icon': '🍖', 'label': 'Eating snack'},
      {'icon': '🎾', 'label': 'Playing fetch'},
      {'icon': '🌧️', 'label': 'Getting wet'},
      {'icon': '🌳', 'label': 'Climbing tree'},
      {'icon': '🌻', 'label': 'Smelling flowers'},
      {'icon': '🪵', 'label': 'Carrying stick'},
      {'icon': '🌞', 'label': 'Sunbathing'},
      {'icon': '👤', 'label': 'Meeting person'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 15, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Event',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  TextButton(
                    onPressed: _handleMoreButtonPressed,
                    child: Text(
                      'M O R E',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: eventOptions.map((event) {
                    return GestureDetector(
                      onTap: () async {
                        final Position position =
                            await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high,
                        );
                        final latLng = apple_maps.LatLng(
                            position.latitude, position.longitude);

                        bool markOnMap = false;
                        Color eventColor = Colors.green;

                        if (event['label'] == 'Stool') {
                          markOnMap = true;
                          eventColor = Colors.brown;
                        } else if (event['label'] == 'Urine') {
                          markOnMap = true;
                          eventColor = Colors.yellow;
                        }

                        // Stwórz nowe wydarzenie
                        var newEvent = {
                          'icon': event['icon'],
                          'label': event['label'],
                          'time': DateTime.now(),
                          'latLng': latLng,
                          'markOnMap': markOnMap,
                          'color': eventColor,
                        };

                        // Dodaj wydarzenie do listy i odśwież UI
                        setState(() {
                          _addedEvents.add(newEvent);

                          if (markOnMap) {
                            // Dodaj na mapę tylko, jeśli zaznaczone
                            eventLines.add(apple_maps.Polyline(
                              polylineId: apple_maps.PolylineId(
                                  '${event['label']}_${DateTime.now()}'),
                              points: [
                                latLng,
                                apple_maps.LatLng(position.latitude + 0.00005,
                                    position.longitude + 0.00005),
                              ],
                              width: 25,
                              color: eventColor,
                            ));
                          }
                        });
                      },
                      onLongPress: () async {
                        Color newColor = await _showColorSelectionDialog();

                        final Position position =
                            await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high,
                        );
                        final latLng = apple_maps.LatLng(
                            position.latitude, position.longitude);

                        // Stwórz nowe wydarzenie z wybranym kolorem
                        var newEvent = {
                          'icon': event['icon'],
                          'label': event['label'],
                          'time': DateTime.now(),
                          'latLng': latLng,
                          'markOnMap':
                              true, // Domyślnie zaznacz na mapie po zmianie koloru
                          'color': newColor,
                        };

                        // Dodaj wydarzenie do listy i odśwież UI
                        setState(() {
                          _addedEvents.add(newEvent);

                          // Dodaj na mapę z nowym kolorem
                          eventLines.add(apple_maps.Polyline(
                            polylineId: apple_maps.PolylineId(
                                '${event['label']}_${DateTime.now()}'),
                            points: [
                              latLng,
                              apple_maps.LatLng(position.latitude + 0.00005,
                                  position.longitude + 0.00005),
                            ],
                            width: 25,
                            color: newColor,
                          ));
                        });
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              event['icon']!,
                              style: const TextStyle(fontSize: 30),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              event['label']!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_addedEvents.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildPaginatedEvents(),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showMarkOnMapDialog(String eventLabel) async {
    bool markOnMap = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mark $eventLabel on Map?'),
          content: const Text('Would you like to mark this event on the map?'),
          actions: [
            TextButton(
              child: Text('No',
                  style: TextStyle(color: Theme.of(context).primaryColorDark)),
              onPressed: () {
                markOnMap = false;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes',
                  style: TextStyle(color: Theme.of(context).primaryColorDark)),
              onPressed: () {
                markOnMap = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return markOnMap;
  }

  Future<Color> _showColorSelectionDialog() async {
    Color selectedColor = Colors.transparent;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'S E L E C T  T O  M A R K  O N  M A P',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                selectedColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
                child: Text('C A N C E L',
                    style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                onPressed: () {
                  selectedColor = Colors.transparent;
                  Navigator.of(context).pop();
                }),
            TextButton(
              child: Text('D O N E',
                  style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return selectedColor;
  }

  Future<List<Pet>> _selectPetsForEvent() async {
    List<Pet> selectedPets = [];
    if (widget.pets.length == 1) {
      return [widget.pets.first];
    }
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 15.0, top: 15, bottom: 5),
                        child: Text(
                          'S E L E C T  P E T S',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 15.0, top: 15, bottom: 5),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'D O N E',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: widget.pets.map((pet) {
                        bool isSelected = selectedPets.contains(pet);
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                selectedPets.remove(pet);
                              } else {
                                selectedPets.add(pet);
                              }
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                            backgroundImage: AssetImage(pet.avatarImage),
                            radius: 30,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 35),
                ],
              ),
            );
          },
        );
      },
    );
    return selectedPets;
  }

  Widget _buildPaginatedEvents() {
    int totalPages = (_addedEvents.length / _eventsPerPage).ceil();
    List<Map<String, dynamic>> paginatedEvents = _addedEvents
        .skip(_currentPage * _eventsPerPage)
        .take(_eventsPerPage)
        .toList();

    return Column(
      children: [
        ...paginatedEvents.map((event) {
          return ListTile(
            leading: Text(
              event['icon'],
              style: const TextStyle(fontSize: 30),
            ),
            title: Text('${event['label']}'),
            subtitle: Text(
              DateFormat('HH:mm').format(event['time']),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _addedEvents.remove(event);
                });
              },
            ),
          );
        }),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                  : null,
            ),
            Text('Page ${_currentPage + 1} of $totalPages'),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _currentPage < totalPages - 1
                  ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
