// ignore_for_file: use_build_context_synchronously, invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
import 'dart:async';
import 'dart:io';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/providers/others_providers/user_provider.dart';
import 'package:pet_diary/src/screens/walk_screens/walk_summary_screen.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_stool_model.dart';
import 'package:pet_diary/src/models/events_models/event_urine_model.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';
import 'package:pet_diary/src/models/others/global_walk_model.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_stool_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_urine_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/walks_providers/global_walk_provider.dart';
import 'package:pet_diary/src/providers/walks_providers/walk_state_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pet_diary/src/screens/events_screens/event_type_selection_screen.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:pet_diary/src/services/other_services/storage_service.dart';
import 'package:uuid/uuid.dart';

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
  AppleMapController? _mapController;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _photos = [];
  final TextEditingController _notesController = TextEditingController();
  List<Polyline> eventLines = [];
  int _currentPage = 0;
  final int _eventsPerPage = 4;
  final Set<Annotation> _annotations = {};
  bool _isMapFullScreen = false;
  final List<Map<String, dynamic>> _collectedEvents = [];
  String? walkId;
  final List<Map<String, dynamic>> _addedEvents = [];

  @override
  void initState() {
    super.initState();
    _initializeWalkId();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_mapController != null) {
        await _goToCurrentLocation(_mapController!);
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

  void _initializeWalkId() async {
    walkId ??=
        const Uuid().v4(); // Generowanie unikalnego ID globalnego spaceru

    // Tworzenie modelu globalnego spaceru
    final globalWalk = GlobalWalkModel(
      id: walkId!,
      individualWalkIds: [], // Lista indywidualnych spacerów dla psów
      petIds: widget.pets.map((pet) => pet.id).toList(), // Lista ID psów
      dateTime: DateTime.now(), // Aktualna data i czas
      routePoints: [], // Trasa spaceru
      walkTime: 0.0, // Czas spaceru
      steps: 0.0, // Liczba kroków
      stoolsAndUrine: [], // Puste zdarzenia na kupy i siku na mapie
      images: [], // Zdjęcia zrobione podczas spaceru (na razie puste)
      noteId: null, // Brak notatki na starcie
    );

    // Dodanie globalnego spaceru do bazy danych
    await ref.read(globalWalkServiceProvider).addGlobalWalk(globalWalk);
  }

  void _pauseResumeWalk(BuildContext context, WalkNotifier walkNotifier) async {
    String action = walkNotifier.state.isPaused ? 'Resume' : 'Pause';
    bool confirm = await _showConfirmationDialog(context, action);
    if (confirm) {
      walkNotifier.pauseWalk();
    }
  }

  void _endWalk(BuildContext context, WalkNotifier walkNotifier,
      WalkState walkState) async {
    try {
      bool confirm = await _showConfirmationDialog(context, 'End');
      if (confirm) {
        walkNotifier.stopWalk();

        // Debugging data
        debugPrint('Walk ending initiated');
        debugPrint('Collected events: $_collectedEvents');

        // Transform event data to the correct format
        List<Map<String, dynamic>> transformedEvents =
            _collectedEvents.map((event) {
          final LatLng location = event['location'];
          return {
            ...event,
            'location': {
              'latitude': location.latitude,
              'longitude': location.longitude,
            },
            'id': event['id'],
          };
        }).toList();

        debugPrint('Transformed events: $transformedEvents');

        // Save all events related to the walk
        _saveAllEvents();

        // Upload photos to storage if any exist
        List<String> photoUrls = [];
        if (_photos.isNotEmpty) {
          for (XFile photo in _photos) {
            String? downloadUrl =
                await StorageService().uploadPhoto(File(photo.path));
            if (downloadUrl != null) {
              photoUrls.add(downloadUrl);
            }
          }
        }

        // Generate individual walk IDs for each pet and save walk data for each
        Map<String, String> petWalkIds = {};
        for (var pet in widget.pets) {
          String individualWalkId = generateUniqueId();
          petWalkIds[pet.id] = individualWalkId;

          EventWalkModel walkEvent = EventWalkModel(
            id: individualWalkId,
            globalWalkId: walkId!,
            walkTime: walkState.seconds.toDouble(),
            petId: pet.id,
            steps: walkState.currentSteps.toDouble(),
            dateTime: DateTime.now(),
            routePoints: walkState.routePoints
                .map((point) => {
                      'latitude': point.latitude,
                      'longitude': point.longitude,
                    })
                .toList(),
            stoolsAndUrine: transformedEvents,
          );

          // Save individual walk event for the pet
          await ref.read(eventWalkServiceProvider).addWalk(pet.id, walkEvent);
        }

        // Update global walk data
        GlobalWalkModel updatedGlobalWalk = GlobalWalkModel(
          id: walkId!,
          individualWalkIds: petWalkIds.values.toList(),
          petIds: widget.pets.map((pet) => pet.id).toList(),
          dateTime: DateTime.now(),
          routePoints: walkState.routePoints
              .map((point) => {
                    'latitude': point.latitude,
                    'longitude': point.longitude,
                  })
              .toList(),
          walkTime: walkState.seconds.toDouble(),
          steps: walkState.currentSteps.toDouble(),
          stoolsAndUrine: transformedEvents,
          images: photoUrls,
          noteId:
              _notesController.text.isNotEmpty ? _notesController.text : null,
        );

        // Update global walk in the database
        await ref
            .read(globalWalkServiceProvider)
            .updateGlobalWalk(updatedGlobalWalk);

        await _compareFirestoreData(walkId!, updatedGlobalWalk);

        // Pop the current screen and navigate to WalkSummaryScreen
        Navigator.of(context).pop();

        // Ensure you gather the correct event lines, route points, and events
        final List<Polyline> eventLines = [
          Polyline(
            polylineId: PolylineId('route'),
            points: walkState.routePoints,
            width: 5,
            color: Colors.blue,
          ),
        ];

        // Navigate to WalkSummaryScreen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WalkSummaryScreen(
              eventLines: eventLines, // linie trasy spaceru
              addedEvents: transformedEvents, // wydarzenia z ikonkami 💩 lub 💦
              photos: _photos, // zdjęcia ze spaceru
              totalDistance:
                  walkState.totalDistance.toStringAsFixed(2), // dystans
              totalTimeInSeconds: walkState.seconds, // czas trwania
              pets: widget.pets, // lista zwierząt uczestniczących w spacerze
              notes: _notesController.text,
              isFromWalksListScreen: false, // notatki ze spaceru
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in _endWalk: $e');
    }
  }

  Future<void> _compareFirestoreData(
      String walkId, GlobalWalkModel localData) async {
    // Pobranie danych z Firestore
    final GlobalWalkModel? firestoreData =
        await ref.read(globalWalkServiceProvider).getGlobalWalkById(walkId);

    // Sprawdzanie, czy dane zostały pobrane poprawnie
    if (firestoreData != null) {
      // Porównanie kluczowych danych: stoolsAndUrine, routePoints, walkTime
      debugPrint('Porównanie danych lokalnych z Firestore:');
      debugPrint('Lokalne stoolsAndUrine: ${localData.stoolsAndUrine}');
      debugPrint('Firestore stoolsAndUrine: ${firestoreData.stoolsAndUrine}');

      debugPrint('Lokalne routePoints: ${localData.routePoints}');
      debugPrint('Firestore routePoints: ${firestoreData.routePoints}');

      debugPrint('Lokalny czas spaceru: ${localData.walkTime}');
      debugPrint('Firestore czas spaceru: ${firestoreData.walkTime}');
    } else {
      debugPrint('Nie znaleziono danych dla spaceru o ID: $walkId');
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
                  const SizedBox(
                    height: 5,
                  ),
                  _buildProgressBarWithDetailsConteiner(
                      context, walkState, walkNotifier),
                  _buildEventSelectionContainer(),
                  _buildNotesAndPhotosContainer(),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isMapFullScreen ? MediaQuery.of(context).size.width : 500,
      height: _isMapFullScreen ? MediaQuery.of(context).size.height - 220 : 225,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: _isMapFullScreen
            ? BorderRadius.zero
            : const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
      ),
      padding: const EdgeInsets.all(15.0),
      child: Stack(
        children: [
          _buildAppleMapSection(walkState),
          Positioned(
            top: 3,
            right: 3,
            child: SizedBox(
              width: 40,
              height: 40,
              child: FloatingActionButton(
                heroTag: 'fullscreenToggle',
                mini: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  _isMapFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Theme.of(context).primaryColorDark,
                ),
                onPressed: () {
                  setState(() {
                    _isMapFullScreen = !_isMapFullScreen;
                  });
                },
              ),
            ),
          ),
          Positioned(
            bottom: 3,
            right: 3,
            child: SizedBox(
              width: 40,
              height: 40,
              child: FloatingActionButton(
                heroTag: 'currentLocation',
                onPressed: () {
                  if (_mapController != null) {
                    _goToCurrentLocation(_mapController!);
                  }
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.near_me,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
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

  Future<void> _goToCurrentLocation(AppleMapController controller) async {
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

    final latLng = LatLng(position.latitude, position.longitude);
    controller.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }

  Widget _buildAppleMapSection(WalkState walkState) {
    return Stack(
      children: [
        AppleMap(
          initialCameraPosition: CameraPosition(
            target: walkState.routePoints.isNotEmpty
                ? LatLng(
                    walkState.routePoints.last.latitude,
                    walkState.routePoints.last.longitude,
                  )
                : const LatLng(51.5, -0.09),
            zoom: 16.0,
          ),
          onMapCreated: (AppleMapController controller) {
            _mapController = controller;
            _goToCurrentLocation(controller);
          },
          polylines: {
            Polyline(
              polylineId: PolylineId('route'),
              points: walkState.routePoints
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList(),
              width: 15,
              color: const Color.fromARGB(255, 29, 121, 227),
            ),
            ...eventLines,
          },
          annotations: _annotations,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
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
              onPressed: () => _endWalk(context, walkNotifier, walkState),
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
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
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

  Widget _buildEventSelectionContainer() {
    final List<Map<String, String>> eventOptions = [
      {'icon': '💩', 'label': 'Stool'},
      {'icon': '💦', 'label': 'Urine'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
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
                    'S E L E C T  E V E N T',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  TextButton(
                    onPressed: _handleMoreButtonPressed,
                    child: Text(
                      'M O R E',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: eventOptions.map((event) {
                      return GestureDetector(
                        onTap: () {
                          _handleEventSelection(
                              event['label']!, event['icon']!);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.37,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                event['icon']!,
                                style: const TextStyle(fontSize: 35),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  _buildPaginatedEvents(), // Add paginated events here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<BitmapDescriptor> _getScaledBitmapDescriptor(
      String assetPath, int width, int height) async {
    final ByteData imageData = await rootBundle.load(assetPath);
    final List<int> bytes = imageData.buffer.asUint8List();

    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
    if (image != null) {
      img.Image resizedImage =
          img.copyResize(image, width: width, height: height);

      final List<int> resizedBytes = img.encodePng(resizedImage);
      return BitmapDescriptor.fromBytes(Uint8List.fromList(resizedBytes));
    } else {
      throw Exception("Nie udało się załadować obrazu");
    }
  }

  void _addUrineMarker(LatLng position, String eventId) async {
    final BitmapDescriptor customIcon = await _getScaledBitmapDescriptor(
      'assets/images/events_type_cards_no_background/piee.png',
      190,
      190,
    );

    String currentDateTime =
        DateFormat('HH:mm  dd-MM-yyyy').format(DateTime.now());

    final Annotation urineAnnotation = Annotation(
      annotationId: AnnotationId(eventId),
      position: LatLng(position.latitude, position.longitude),
      icon: customIcon,
      infoWindow: InfoWindow(
        title: 'Urine',
        snippet: currentDateTime,
      ),
      onTap: () {
        if (kDebugMode) {
          print('Urine event tapped!');
        }
      },
    );

    setState(() {
      _annotations.add(urineAnnotation);
    });
  }

  void _addStoolMarker(apple_maps.LatLng position, String eventId) async {
    final BitmapDescriptor customIcon = await _getScaledBitmapDescriptor(
      'assets/images/events_type_cards_no_background/poo.png',
      128,
      128,
    );

    String currentDateTime =
        DateFormat('HH:mm  dd-MM-yyyy').format(DateTime.now());

    final Annotation stoolAnnotation = Annotation(
      annotationId: AnnotationId(eventId),
      position: position,
      icon: customIcon,
      infoWindow: InfoWindow(
        title: 'Poo',
        snippet: currentDateTime,
      ),
      onTap: () {
        if (kDebugMode) {
          print('Poo event tapped!');
        }
      },
    );

    setState(() {
      _annotations.add(stoolAnnotation);
    });
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

  void _saveAllEvents() async {
    for (var event in _collectedEvents) {
      String eventId = event['id'];

      if (event['label'] == 'Stool') {
        _saveStoolEvent(event['petId'], event['time'], eventId);
      } else if (event['label'] == 'Urine') {
        _saveUrineEvent(event['petId'], event['time'], eventId);
      }
    }
  }

  void _handleEventSelection(String eventLabel, String eventIcon) async {
    List<Pet> selectedPets = await _selectPetsForEvent();

    if (selectedPets.isNotEmpty) {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);

      for (var pet in selectedPets) {
        String eventId = '${eventLabel}_${DateTime.now()}';

        setState(() {
          _addedEvents.add({
            'id': eventId,
            'icon': eventIcon, // np. 💩 lub 💦
            'label': eventLabel, // np. Stool, Urine
            'time': DateTime.now(),
            'location': latLng,
            'petId': pet.id,
            'petName': pet.name,
            'petAvatar': pet.avatarImage
          });

          _collectedEvents.add({
            'id': eventId,
            'icon': eventIcon, // np. 💩 lub 💦
            'label': eventLabel, // np. Stool, Urine
            'time': DateTime.now(),
            'location': latLng,
            'petId': pet.id,
            'petName': pet.name,
            'petAvatar': pet.avatarImage
          });

          if (eventLabel == 'Stool') {
            _addStoolMarker(
                latLng, eventId); // Dodawanie markerów z emotikonami na mapę
          } else if (eventLabel == 'Urine') {
            _addUrineMarker(
                latLng, eventId); // Dodawanie markerów z emotikonami na mapę
          }
        });
      }
    }
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        event['icon'],
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                event['label'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                DateFormat('HH:mm').format(event['time']),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          CircleAvatar(
                            backgroundImage: AssetImage(event['petAvatar']),
                            radius: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _removeEvent(event);
                    });
                  },
                ),
              ],
            ),
          );
        }),
        if (_addedEvents.length > 5) ...[
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
      ],
    );
  }

  void _saveUrineEvent(String petId, DateTime eventTime, String eventId) {
    EventUrineModel newUrine = EventUrineModel(
      id: eventId,
      eventId:
          eventId, // Używamy tego samego ID dla eventu i zapisu w globalnym spacerze
      petId: petId,
      color: 'Default',
      description: 'Urine event',
      dateTime: eventTime,
      userId: ref.read(userIdProvider)!,
      time: TimeOfDay.now(),
    );

    ref.read(eventUrineServiceProvider).addUrineEvent(newUrine);

    Event newEvent = Event(
      id: newUrine.eventId,
      title: 'Urine',
      eventDate: eventTime,
      dateWhenEventAdded: DateTime.now(),
      userId: FirebaseAuth.instance.currentUser!.uid,
      petId: petId,
      description: 'Urine event during walk',
      emoticon: '💦',
    );

    ref.read(eventServiceProvider).addEvent(newEvent, petId);
  }

  void _saveStoolEvent(String petId, DateTime eventTime, String eventId) {
    EventStoolModel newStoolEvent = EventStoolModel(
      id: eventId,
      eventId: eventId, // Używamy tego samego ID
      petId: petId,
      description: 'Stool event during walk',
      emoji: '💩',
      dateTime: eventTime, userId: ref.read(userIdProvider)!,
    );

    ref.read(eventStoolServiceProvider).addStoolEvent(newStoolEvent);

    Event newEvent = Event(
      id: newStoolEvent.eventId,
      title: 'Stool',
      eventDate: eventTime,
      dateWhenEventAdded: DateTime.now(),
      userId: FirebaseAuth.instance.currentUser!.uid,
      petId: petId,
      description: 'Stool event during walk',
      emoticon: '💩',
    );

    ref.read(eventServiceProvider).addEvent(newEvent, petId);
  }

  void _removeEvent(Map<String, dynamic> event) {
    setState(() {
      _addedEvents.remove(event);

      // Usuwamy marker powiązany z usuniętym wydarzeniem
      _annotations.removeWhere(
          (annotation) => annotation.annotationId.value == event['id']);

      // Obliczamy liczbę stron
      int totalPages = (_addedEvents.length / _eventsPerPage).ceil();

      // Jeśli po usunięciu zdarzenia liczba stron się zmniejszyła, wracamy na poprzednią stronę
      if (_currentPage >= totalPages) {
        _currentPage = totalPages - 1;
      }

      // Upewniamy się, że nie jesteśmy na stronie mniejszej niż 0
      if (_currentPage < 0) {
        _currentPage = 0;
      }
    });
  }
}
