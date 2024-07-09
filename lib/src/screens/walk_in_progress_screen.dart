import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/walk_state_provider.dart';

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
  String selectedView = 'S';
  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _notesController = TextEditingController();
  final List<File> _images = [];

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
    _notesController.dispose();
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
                    final result = await ImageGallerySaver.saveFile(image.path);
                    if (result["isSuccess"]) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Image saved to gallery!')),
                      );
                    } else {
                      // ignore: use_build_context_synchronously
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

  @override
  Widget build(BuildContext context) {
    final walkState = ref.watch(walkProvider);
    final walkNotifier = ref.read(walkProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'W A L K  I N  P R O G R E S S',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: Theme.of(context).primaryColorDark,
              size: 24,
            ),
            onPressed: () {
              //todo Add menu logic
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64.0),
          child: SwitchWidget(
            selectedView: selectedView,
            onSelectedViewChanged: (String newView) {
              setState(() {
                selectedView = newView;
              });
            },
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Divider(
                    color: Theme.of(context).colorScheme.secondary, height: 1),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: walkState.routePoints.isNotEmpty
                            ? walkState.routePoints.last
                            : LatLng(51.5, -0.09),
                        initialZoom: 16.0,
                        minZoom: 5,
                        maxZoom: 25,
                        onPositionChanged: (MapCamera camera, bool hasGesture) {
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
                                color: const Color(0xffdfd785)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: selectedView == 'S'
                ? _buildSimpleView(context, walkState, walkNotifier)
                : ListView(
                    children: [
                      _buildActivityData(context, walkState, walkNotifier),
                      _buildNotesSection(context),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleView(
      BuildContext context, WalkState walkState, WalkNotifier walkNotifier) {
    double progress =
        (walkState.currentSteps % walkState.goalSteps) / walkState.goalSteps;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 20),
                    child: Text(
                      walkNotifier.formatTime(walkState.seconds),
                      style: TextStyle(
                        fontSize: 25,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          walkState.status == 'walking'
                              ? Icons.directions_walk
                              : Icons.accessibility_new,
                          color: Theme.of(context).primaryColorDark,
                          size: 30,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          walkState.status == 'walking' ? 'Walking' : 'Stopped',
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
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 175,
                    height: 175,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        walkState.currentSteps.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      if (walkState.currentSteps == 0)
                        Text(
                          'Step Count not available',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 40, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: walkNotifier.pauseWalk,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fixedSize: const Size(125, 35),
                      ),
                      child: Text(
                        walkState.isPaused ? 'Resume' : 'Pause',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: walkNotifier.stopWalk,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fixedSize: const Size(125, 35),
                      ),
                      child: Text(
                        'End Walk',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).primaryColorDark,
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

  Widget _buildActivityData(
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

  Widget _buildNotesSection(BuildContext context) {
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
          Text(
            "Notes",
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Divider(color: Colors.grey, height: 20),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Add your notes here...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera),
                label: const Text("Add Photo"),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo),
                label: const Text("From Gallery"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildImageGallery(),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Wrap(
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
    );
  }
}

class SwitchWidget extends StatelessWidget {
  final String selectedView;
  final ValueChanged<String> onSelectedViewChanged;

  const SwitchWidget({
    required this.selectedView,
    required this.onSelectedViewChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 5.0, right: 5, bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['S', 'D'].map((label) {
          String displayLabel = label == 'D' ? 'Detailed' : 'Simple';
          Color bgColor = Colors.transparent;
          if (selectedView == label) {
            bgColor = const Color(0xff68a2b6).withOpacity(
                0.5); // Primary color background for selected button
          }
          return TextButton(
            onPressed: () {
              onSelectedViewChanged(label);
            },
            style: TextButton.styleFrom(
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              displayLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedView == label
                    ? Theme.of(context)
                        .primaryColorDark // Dark color for selected button text
                    : Theme.of(context).primaryColorDark.withOpacity(0.5),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
