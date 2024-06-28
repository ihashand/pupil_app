import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class WalkInProgressScreen extends StatefulWidget {
  final List<Pet> pets;

  const WalkInProgressScreen({super.key, required this.pets});

  @override
  createState() => _WalkInProgressScreenState();
}

class _WalkInProgressScreenState extends State<WalkInProgressScreen> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  late StreamSubscription<StepCount> _stepCountSubscription;
  late StreamSubscription<PedestrianStatus> _pedestrianStatusSubscription;

  String _status = '?', _steps = '?';
  int _initialSteps = 0;
  int _currentSteps = 0;
  bool _isWalking = false;
  bool _isPaused = false;
  late Timer _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _startWalk();
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

  void _startWalk() {
    _stepCountStream.first.then((StepCount event) {
      setState(() {
        _initialSteps = event.steps;
        _isWalking = true;
        _isPaused = false;
        _currentSteps = 0;
        _startTimer();
      });
    }).catchError((error) {
      print('Error getting initial step count: $error');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).primaryColorDark, size: 20),
        title: Text(
          'W a l k  I n  P r o g r e s s',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Steps Taken',
              style: TextStyle(
                fontSize: 30,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            Text(
              _steps,
              style: TextStyle(
                fontSize: 60,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            Divider(
              height: 100,
              thickness: 0,
              color: Colors.white,
            ),
            Text(
              'Pedestrian Status',
              style: TextStyle(
                fontSize: 30,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            Icon(
              _status == 'walking'
                  ? Icons.directions_walk
                  : _status == 'stopped'
                      ? Icons.accessibility_new
                      : Icons.error,
              size: 100,
            ),
            Center(
              child: Text(
                _status,
                style: _status == 'walking' || _status == 'stopped'
                    ? TextStyle(fontSize: 30)
                    : TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),
            Divider(
              height: 100,
              thickness: 0,
              color: Colors.white,
            ),
            Text(
              'Time Elapsed',
              style: TextStyle(
                fontSize: 30,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            Text(
              _formatTime(_seconds),
              style: TextStyle(
                fontSize: 60,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            _buildPetsList(), // Display the selected pets
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _pauseWalk,
                  child: Text(
                    _isPaused ? 'Resume' : 'Pause',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _stopWalk,
                  child: Text(
                    'Stop',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetsList() {
    return Column(
      children: widget.pets.map((pet) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(pet.avatarImage),
          ),
          title: Text(pet.name),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _stepCountSubscription.cancel();
    _pedestrianStatusSubscription.cancel();
    super.dispose();
  }
}
