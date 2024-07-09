import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:pedometer/pedometer.dart';

class WalkState {
  final bool isWalking;
  final bool isPaused;
  final int initialSteps;
  final int currentSteps;
  final int seconds;
  final String status;
  final List<LatLng> routePoints;
  final int goalSteps;
  final double totalCaloriesBurned;
  final double totalDistance;
  final double averagePace;
  final double fastestPace;

  WalkState({
    this.isWalking = false,
    this.isPaused = false,
    this.initialSteps = 0,
    this.currentSteps = 0,
    this.seconds = 0,
    this.status = 'stopped',
    this.routePoints = const [],
    this.goalSteps = 6000,
    this.totalCaloriesBurned = 0.0,
    this.totalDistance = 0.0,
    this.averagePace = 0.0,
    this.fastestPace = double.infinity,
  });

  WalkState copyWith({
    bool? isWalking,
    bool? isPaused,
    int? initialSteps,
    int? currentSteps,
    int? seconds,
    String? status,
    List<LatLng>? routePoints,
    int? goalSteps,
    double? totalCaloriesBurned,
    double? totalDistance,
    double? averagePace,
    double? fastestPace,
  }) {
    return WalkState(
      isWalking: isWalking ?? this.isWalking,
      isPaused: isPaused ?? this.isPaused,
      initialSteps: initialSteps ?? this.initialSteps,
      currentSteps: currentSteps ?? this.currentSteps,
      seconds: seconds ?? this.seconds,
      status: status ?? this.status,
      routePoints: routePoints ?? this.routePoints,
      goalSteps: goalSteps ?? this.goalSteps,
      totalCaloriesBurned: totalCaloriesBurned ?? this.totalCaloriesBurned,
      totalDistance: totalDistance ?? this.totalDistance,
      averagePace: averagePace ?? this.averagePace,
      fastestPace: fastestPace ?? this.fastestPace,
    );
  }
}

class WalkNotifier extends StateNotifier<WalkState> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  late StreamSubscription<StepCount> _stepCountSubscription;
  late StreamSubscription<PedestrianStatus> _pedestrianStatusSubscription;
  late Timer _timer;
  final Location _location = Location();

  WalkNotifier() : super(WalkState()) {
    _initialize();
  }

  void _initialize() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusSubscription = _pedestrianStatusStream
        .listen(_onPedestrianStatusChanged)
      ..onError(_onPedestrianStatusError);

    try {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountSubscription = _stepCountStream.listen(_onStepCount)
        ..onError(_onStepCountError);
    } catch (e) {
      // Obsługa błędu gdy licznik kroków nie jest dostępny
      state = state.copyWith(status: 'Step Count not available');
      print('Error: Step Count not available');
    }

    _checkLocationPermission();
    _startTimer();
    _startWalk();
  }

  void _onStepCount(StepCount event) {
    if (state.isWalking && !state.isPaused) {
      state = state.copyWith(
        currentSteps: event.steps - state.initialSteps,
        totalCaloriesBurned: (event.steps - state.initialSteps) * 0.04,
        totalDistance: (event.steps - state.initialSteps) * 0.0008,
        averagePace: (event.steps - state.initialSteps) * 0.0008 > 0
            ? state.seconds / 60 / ((event.steps - state.initialSteps) * 0.0008)
            : 0,
        fastestPace:
            state.averagePace < state.fastestPace && state.averagePace > 0
                ? state.averagePace
                : state.fastestPace,
      );
    }
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    state = state.copyWith(status: event.status);
    if (event.status == 'stopped') {
      _checkForStop();
    }
  }

  void _onPedestrianStatusError(error) {
    state = state.copyWith(status: 'Pedestrian Status not available');
  }

  void _onStepCountError(error) {
    state = state.copyWith(status: 'Step Count not available');
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
        if (!state.isPaused) {
          state = state.copyWith(routePoints: [
            ...state.routePoints,
            LatLng(currentLocation.latitude!, currentLocation.longitude!)
          ]);
        }
      });
    }
  }

  void _checkForStop() async {
    await Future.delayed(const Duration(seconds: 30));
    if (state.status == 'stopped' && !state.isPaused) {
      LocationData lastStopLocation = await _location.getLocation();
      state = state.copyWith(routePoints: [
        ...state.routePoints,
        LatLng(lastStopLocation.latitude!, lastStopLocation.longitude!)
      ]);
    }
  }

  void _startWalk() {
    _stepCountStream.first.then((StepCount event) {
      state = state.copyWith(
          initialSteps: event.steps,
          isWalking: true,
          isPaused: false,
          currentSteps: 0);
    }).catchError((error) {
      state = state.copyWith(status: 'Step Count not available');
    });
  }

  void stopWalk() {
    _timer.cancel();
    _stepCountSubscription.cancel();
    _pedestrianStatusSubscription.cancel();
    state = state.copyWith(isWalking: false, isPaused: false, seconds: 0);
  }

  void pauseWalk() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPaused) {
        state = state.copyWith(seconds: state.seconds + 1);
      }
    });
  }

  String formatTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  bool get isWalkActive => state.isWalking && !state.isPaused;
}

final walkProvider = StateNotifierProvider<WalkNotifier, WalkState>((ref) {
  return WalkNotifier();
});
