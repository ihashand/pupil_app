import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/providers/walks_providers/walk_state_provider.dart';
import 'package:geolocator/geolocator.dart';

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
                  const SizedBox(height: 15),
                  _buildProgressBarWithDetailsConteiner(
                      context, walkState, walkNotifier),
                  const SizedBox(height: 10),
                  _buildNotesContainer(),
                  const SizedBox(height: 10),
                  _buildPhotosContainer(),
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
                      Icon(
                        Icons.pets,
                        size: 24,
                        color: Theme.of(context)
                            .primaryColorDark
                            .withOpacity(0.65),
                      ),
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
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
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
            // Wywołanie metody, aby ustawić mapę na aktualną lokalizację przy uruchomieniu
            _goToCurrentLocation(controller);
          },
          polylines: {
            apple_maps.Polyline(
              polylineId: apple_maps.PolylineId('route'),
              points: walkState.routePoints
                  .map((point) =>
                      apple_maps.LatLng(point.latitude, point.longitude))
                  .toList(),
              width: 12,
              color: const Color.fromARGB(255, 29, 121, 227),
            ),
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
        Positioned(
          bottom: 7,
          right: 7,
          child: SizedBox(
            height: 30,
            width: 30,
            child: FloatingActionButton(
              onPressed: () {
                if (_mapController != null) {
                  _goToCurrentLocation(_mapController!);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.near_me,
                color: Theme.of(context).primaryColorDark,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
      BuildContext context, WalkNotifier walkNotifier, WalkState walkState) {
    return BottomAppBar(
      height: 50,
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
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'End Walk',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).primaryColorDark,
                ),
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
                walkState.isPaused ? 'Resume' : 'Pause',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const TextField(
          decoration: InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          height: 100,
          color: Colors.grey[300],
          child: const Center(
            child: Text('Photo Section'),
          ),
        ),
      ),
    );
  }
}
