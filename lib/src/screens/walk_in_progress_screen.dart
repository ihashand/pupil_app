import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart' as path;

class WalkInProgressScreen extends StatefulWidget {
  final List<Pet> pets;

  const WalkInProgressScreen({super.key, required this.pets});

  @override
  createState() => _WalkInProgressScreenState();
}

class _WalkInProgressScreenState extends State<WalkInProgressScreen>
    with SingleTickerProviderStateMixin {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  late StreamSubscription<StepCount> _stepCountSubscription;
  late StreamSubscription<PedestrianStatus> _pedestrianStatusSubscription;

  String _status = 'stopped', _steps = '0';
  int _initialSteps = 0;
  int _currentSteps = 0;
  bool _isWalking = false;
  bool _isPaused = false;
  late Timer _timer;
  int _seconds = 0;
  final int _goalSteps = 6000;
  final List<LatLng> _routePoints = [];
  LocationData? _lastStopLocation;
  final Location _location = Location();
  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  String selectedView = 'S';
  double _currentZoom = 16.0;
  LatLng _currentCenter = const LatLng(51.5, -0.09);
  double _totalCaloriesBurned = 0.0;
  double _totalDistance = 0.0;
  double _averagePace = 0.0;
  double _fastestPace = double.infinity;
  List<File> _images = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    initPlatformState();
    _checkLocationPermission();
    _startTimer();
    _startWalk();
    _initLocation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _timer.cancel();
    _stepCountSubscription.cancel();
    _pedestrianStatusSubscription.cancel();
    super.dispose();
  }

  void onStepCount(StepCount event) {
    if (_isWalking && !_isPaused) {
      setState(() {
        _currentSteps = event.steps - _initialSteps;
        _steps = _currentSteps.toString();
        _totalCaloriesBurned = _currentSteps * 0.04;
        _totalDistance = _currentSteps * 0.0008;
        _averagePace = _totalDistance > 0 ? _seconds / 60 / _totalDistance : 0;
        if (_averagePace < _fastestPace && _averagePace > 0) {
          _fastestPace = _averagePace;
        }
      });
    }
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    if (mounted) {
      setState(() {
        _status = event.status;
        if (_status == 'stopped') {
          _checkForStop();
        }
      });
    }
  }

  void onPedestrianStatusError(error) {
    if (mounted) {
      setState(() {
        _status = 'Pedestrian Status not available';
      });
    }
  }

  void onStepCountError(error) {
    if (mounted) {
      setState(() {
        _steps = 'Step Count not available';
      });
    }
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusSubscription = _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
      ..onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountSubscription = _stepCountStream.listen(onStepCount)
      ..onError(onStepCountError);
  }

  void _checkLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    if (permissionGranted == PermissionStatus.granted) {
      _location.onLocationChanged.listen((LocationData currentLocation) {
        if (!_isPaused) {
          setState(() {
            _routePoints.add(
                LatLng(currentLocation.latitude!, currentLocation.longitude!));
            _updatePolyline();
            _mapController.move(
                LatLng(currentLocation.latitude!, currentLocation.longitude!),
                _currentZoom);
          });
        }
      });
    }
  }

  void _initLocation() async {
    _checkLocationPermission();
  }

  void _updatePolyline() {
    setState(() {
      _routePoints
          .add(LatLng(_routePoints.last.latitude, _routePoints.last.longitude));
    });
  }

  void _checkForStop() async {
    await Future.delayed(const Duration(seconds: 30));
    if (_status == 'stopped' && !_isPaused) {
      _lastStopLocation = await _location.getLocation();
      setState(() {
        _routePoints.add(
          LatLng(_lastStopLocation!.latitude!, _lastStopLocation!.longitude!),
        );
      });
    }
  }

  void _startWalk() {
    _stepCountStream.first.then((StepCount event) {
      setState(() {
        _initialSteps = event.steps;
        _isWalking = true;
        _isPaused = false;
        _currentSteps = 0;
      });
    }).catchError((error) {
      if (kDebugMode) {
        print('Error getting initial step count: $error');
      }
      setState(() {
        _steps = '0';
      });
    });
  }

  void _stopWalk() {
    _timer.cancel();
    _stepCountSubscription.cancel();
    _pedestrianStatusSubscription.cancel();
    setState(() {
      _isWalking = false;
      _isPaused = false;
      _seconds = 0;
    });
    Navigator.pop(context);
  }

  void _pauseWalk() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only add up to 5 images.')),
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

  Widget _buildActivityData(BuildContext context) {
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
          _buildActivityDataRow(context, "Steps", _steps),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Time", _formatTime(_seconds)),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Calories Burned",
              "${_totalCaloriesBurned.toStringAsFixed(0)} kcal"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(
              context, "Distance", "${_totalDistance.toStringAsFixed(2)} km"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Average Pace",
              "${_averagePace.toStringAsFixed(2)} min/km"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Fastest Pace",
              "${_fastestPace.toStringAsFixed(2)} min/km"),
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
            decoration: InputDecoration(
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
                icon: Icon(Icons.camera),
                label: Text("Add Photo"),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.photo),
                label: Text("From Gallery"),
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
                  child: Icon(
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
                  child: Icon(
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Image saved to gallery!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save image.')),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Icon(
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
                        initialCenter: _currentCenter,
                        initialZoom: _currentZoom,
                        minZoom: 5,
                        maxZoom: 25,
                        onPositionChanged: (MapCamera camera, bool hasGesture) {
                          setState(() {
                            _currentZoom = camera.zoom;
                            _currentCenter = camera.center;
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
                                points: _routePoints,
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
                ? _buildSimpleView(context)
                : ListView(
                    children: [
                      _buildActivityData(context),
                      _buildNotesSection(context),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleView(BuildContext context) {
    double progress = (_currentSteps % _goalSteps) / _goalSteps;

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
                      _formatTime(_seconds),
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
                          _status == 'walking'
                              ? Icons.directions_walk
                              : Icons.accessibility_new,
                          color: Theme.of(context).primaryColorDark,
                          size: 30,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _status == 'walking' ? 'Walking' : 'Stopped',
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
                        _steps,
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      if (_steps == 'Step Count not available')
                        Text(
                          _steps,
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
                      onPressed: _pauseWalk,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fixedSize: const Size(125, 35),
                      ),
                      child: Text(
                        _isPaused ? 'Resume' : 'Pause',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _stopWalk,
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
