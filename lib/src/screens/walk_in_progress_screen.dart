import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pedometer/pedometer.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
      padding: const EdgeInsets.all(8.0),
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
            bgColor = Theme.of(context).colorScheme.primary.withOpacity(
                0.2); // Primary color background for selected button
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
  Location _location = Location();
  MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = true;
  late AnimationController _animationController;
  late Animation<double> _popupAnimation;
  String selectedView = 'S';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _isAppBarVisible = _scrollController.position.userScrollDirection ==
            ScrollDirection.forward;
      });
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _popupAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
      });
    }
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status;
      if (_status == 'stopped') {
        _checkForStop();
      }
    });
  }

  void onPedestrianStatusError(error) {
    setState(() {
      _status = 'Pedestrian Status not available';
    });
  }

  void onStepCountError(error) {
    setState(() {
      _steps = 'Step Count not available';
    });
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
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    if (_permissionGranted == PermissionStatus.granted) {
      _location.onLocationChanged.listen((LocationData currentLocation) {
        setState(() {
          _routePoints.add(
              LatLng(currentLocation.latitude!, currentLocation.longitude!));
          _updatePolyline();
          _mapController.move(
              LatLng(currentLocation.latitude!, currentLocation.longitude!),
              15.0);
        });
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
    if (_status == 'stopped') {
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
      print('Error getting initial step count: $error');
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
                    padding: const EdgeInsets.only(left: 20.0, bottom: 20),
                    child: Text(
                      _formatTime(_seconds),
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
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
                    width: 100,
                    height: 100,
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
                          fontSize: 30,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 15,
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
                    left: 20.0, right: 20, top: 20, bottom: 10),
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
                        backgroundColor: Colors.red,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedView(BuildContext context) {
    double progress = (_currentSteps % _goalSteps) / _goalSteps;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, bottom: 20),
                      child: Text(
                        _formatTime(_seconds),
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
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
                      width: 100,
                      height: 100,
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
                            fontSize: 30,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 15,
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
                      left: 20.0, right: 20, top: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _pauseWalk,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                          backgroundColor: Colors.red,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildSummarySection(context),
          const SizedBox(height: 10),
          _buildAverageSection(context),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    double totalCaloriesBurned = _currentSteps * 0.04;
    double totalDistance =
        _currentSteps * 0.0008; // Przybliżone przeliczenie na kilometry

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
            children: [
              Text(
                "Steps",
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Spacer(),
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: (_currentSteps % _goalSteps) / _goalSteps,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                _steps,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Time", _formatTime(_seconds)),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Calories Burned",
              "${totalCaloriesBurned.toStringAsFixed(0)} kcal"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(
              context, "Distance", "${totalDistance.toStringAsFixed(2)} km"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Average Pace",
              "${(totalDistance > 0 ? _seconds / 60 / totalDistance : 0).toStringAsFixed(2)} min/km"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(
              context, "Physiological Breaks", "3 S / 1 K"), // Example data
        ],
      ),
    );
  }

  Widget _buildAverageSection(BuildContext context) {
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
          _buildActivityDataRow(context, "Average Pace", "5.2 min/km"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Fastest Pace", "4.5 min/km"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Average Breaks", "4 S / 2 K"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(
              context, "Average Physiological Needs", "3 S / 1 K"),
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
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: AnimatedOpacity(
          opacity: _isAppBarVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 600),
          child: Text(
            'W A L K  I N  P R O G R E S S',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Theme.of(context).primaryColorDark,
            ),
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
              // Add menu logic
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
                    color: Theme.of(context).colorScheme.secondary, height: 20),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      mapController: _mapController,
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints,
                              strokeWidth: 4,
                              color: Theme.of(context).colorScheme.primary,
                            ),
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
                : _buildDetailedView(context),
          ),
        ],
      ),
    );
  }
}
