// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/providers/others_providers/walk_state_provider.dart';
import 'package:pet_diary/src/screens/walk_screens/walk_summary_screen.dart';
import 'package:pet_diary/src/components/health_activity_widgets/section_title.dart';
import 'package:gal/gal.dart';

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
  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();
  final List<File> _images = [];
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only add up to 5 images.')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final compressedImage = await _compressImage(File(pickedFile.path));
      final uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(compressedImage.path)}';
      final directory = await getApplicationDocumentsDirectory();
      final newPath = path.join(directory.path, uniqueFileName);
      final newFile = await File(compressedImage.path).copy(newPath);
      setState(() {
        _images.add(newFile);
      });
    }
  }

  Future<XFile> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.absolute.path}/temp.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    return result!;
  }

  void _showImageDialog(BuildContext context, File image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              Image.file(image),
              Positioned(
                right: 10,
                top: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _images.remove(image);
                    });
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: GestureDetector(
                  onTap: () async {
                    try {
                      await Gal.putImage(image.path);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Image saved to gallery!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save image.')),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.file_download,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
      final petIds = widget.pets.map((pet) => pet.id).toList();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WalkSummaryScreen(
            images: _images,
            walkState: walkNotifier.state,
            petIds: petIds,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final walkState = ref.watch(walkProvider);
    final walkNotifier = ref.read(walkProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'W A L K',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showDetails ? Icons.expand_less : Icons.expand_more,
              color: Theme.of(context).primaryColorDark,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              children: [
                Divider(
                    color: Theme.of(context).colorScheme.secondary, height: 1),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      height: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: walkState.routePoints.isNotEmpty
                                ? walkState.routePoints.last
                                : const LatLng(51.5, -0.09),
                            initialZoom: 16.0,
                            minZoom: 5,
                            maxZoom: 25,
                            onPositionChanged:
                                (MapCamera camera, bool hasGesture) {
                              setState(() {
                                _mapController.move(camera.center, camera.zoom);
                              });
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: walkState.routePoints,
                                  strokeWidth: 15,
                                  color: const Color(0xff68a2b6),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ListView(
              children: [
                _buildSimpleView(context, walkState, walkNotifier),
                if (_showDetails) const SectionTitle(title: "Details"),
                if (_showDetails)
                  _buildDetailedView(context, walkState, walkNotifier),
                if (_showDetails) const SectionTitle(title: "Photos"),
                if (_showDetails) _buildImageGallerySection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleView(
      BuildContext context, WalkState walkState, WalkNotifier walkNotifier) {
    double progressSteps =
        (walkState.currentSteps % walkState.goalSteps) / walkState.goalSteps;
    double progressTime = walkState.seconds / 3600;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SectionTitle(title: "Progress"),
                ],
              ),
              // Progress circural indicator
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 5),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: CircularProgressIndicator(
                              value: progressSteps,
                              strokeWidth: 20,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xffdfd785)),
                            ),
                          ),
                          SizedBox(
                            height: 160,
                            width: 160,
                            child: CircularProgressIndicator(
                              value: progressTime,
                              strokeWidth: 22,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xff68a2b6)),
                            ),
                          ),
                          Icon(
                            Icons.pets,
                            size: 70,
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.65),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Left data
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0, top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            'STEPS',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            children: [
                              Text(
                                '🦶🏼 ',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              Text(
                                '${walkState.currentSteps}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                'DISTANCE',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '🚶🏽‍♂️‍➡️ ',
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                                Text(
                                  '${walkState.totalDistance} km',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Right data
                  Padding(
                    padding: const EdgeInsets.only(right: 35, top: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                'TIME',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                children: [
                                  Text(
                                    '⌛ ',
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                  Text(
                                    walkNotifier.formatTime(walkState.seconds),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                'STATUS',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  walkState.status == 'walking' ? '🟢' : '⛔',
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                                Text(
                                  walkState.status == 'walking'
                                      ? ' Walking'
                                      : ' Stopped',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Buttons
              Padding(
                padding: const EdgeInsets.only(
                    left: 12, right: 12, bottom: 5, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () =>
                            _pauseResumeWalk(context, walkNotifier),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
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
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () => _endWalk(context, walkNotifier),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.8),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedView(
      BuildContext context, WalkState walkState, WalkNotifier walkNotifier) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivityDataRow(
              context, "Steps", walkState.currentSteps.toString()),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(
              context, "Time", walkNotifier.formatTime(walkState.seconds)),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Calories Burned",
              "${walkState.totalCaloriesBurned.toStringAsFixed(0)} kcal"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Distance",
              "${walkState.totalDistance.toStringAsFixed(2)} km"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Average Pace",
              "${walkState.averagePace.toStringAsFixed(2)} min/km"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Fastest Pace",
              "${walkState.fastestPace.toStringAsFixed(2)} min/km"),
        ],
      ),
    );
  }

  Widget _buildActivityDataRow(
      BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallerySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.all(10.0),
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
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icon(Icons.camera,
                    color: Theme.of(context).primaryColorDark),
                label: Text(
                  "Camera",
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.photo,
                    color: Theme.of(context).primaryColorDark),
                label: Text(
                  "Gallery",
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
            ],
          ),
          _buildImageGallery(),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _images.map((image) {
          return GestureDetector(
            onTap: () {
              _showImageDialog(context, image);
            },
            child: Stack(
              children: [
                Image.file(
                  image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _images.remove(image);
                      });
                    },
                    child: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
