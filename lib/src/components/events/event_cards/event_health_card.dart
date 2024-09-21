import 'dart:math';
import 'package:flutter/material.dart';

class EventHealthCard extends StatefulWidget {
  final VoidCallback onCreatePressed;

  const EventHealthCard({super.key, required this.onCreatePressed});

  @override
  createState() => _EventHealthCardState();
}

class _EventHealthCardState extends State<EventHealthCard>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late AnimationController _controller;
  late List<Offset> positions;
  late List<Offset> directions;
  final List<String> assetImages = [
    'assets/images/events_type_cards_no_background/heart.png',
    'assets/images/events_type_cards_no_background/food_bowl.png',
    'assets/images/events_type_cards_no_background/pills.png',
    'assets/images/events_type_cards_no_background/wanna.png',
    'assets/images/events_type_cards_no_background/syringe.png',
    'assets/images/events_type_cards_no_background/thermometr.png',
    'assets/images/events_type_cards_no_background/bed.png',
    'assets/images/events_type_cards_no_background/water_bowl.png',
    'assets/images/events_type_cards_no_background/poo.png',
    'assets/images/events_type_cards_no_background/weight.png',
    'assets/images/events_type_cards_no_background/issue.png',
    'assets/images/events_type_cards_no_background/notes.png',
    'assets/images/events_type_cards_no_background/bandage.png',
  ];

  double movementAreaWidth = 0.0;
  double movementAreaHeight = 0.0;

  double containerWidth = 0.0;
  double containerHeight = 150.0;
  double assetSize = 45.0;

  @override
  void initState() {
    super.initState();

    positions = [];
    directions = [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      containerWidth = MediaQuery.of(context).size.width - 30;
      containerHeight = 150.0;

      _initializePositionsAndMovements();

      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 120),
      )..addListener(() {
          setState(() {
            _updatePositions();
          });
        });

      _controller.repeat();
    });
  }

  void _initializePositionsAndMovements() {
    movementAreaWidth = containerWidth * 1.5;
    movementAreaHeight = containerHeight * 1.5;

    positions = List.generate(assetImages.length, (index) {
      Offset position;
      bool hasCollision;
      int attempts = 0;

      do {
        position = Offset(
          _random.nextDouble() * (movementAreaWidth - assetSize),
          _random.nextDouble() * (movementAreaHeight - assetSize),
        );

        hasCollision = positions.any((otherPosition) {
          double dx = position.dx - otherPosition.dx;
          double dy = position.dy - otherPosition.dy;
          double distance = sqrt(dx * dx + dy * dy);
          return distance < assetSize;
        });

        attempts++;
      } while (hasCollision && attempts < 100);

      return position;
    });

    directions = List.generate(assetImages.length, (index) {
      double angle = _random.nextDouble() * 2 * pi;
      double speed = 0.8;
      return Offset(cos(angle) * speed, sin(angle) * speed);
    });
  }

  void _updatePositions() {
    for (int i = 0; i < positions.length; i++) {
      positions[i] += directions[i];

      // Odbijanie od ścian obszaru ruchu
      if ((positions[i].dx <= 0 && directions[i].dx < 0) ||
          (positions[i].dx >= movementAreaWidth - assetSize &&
              directions[i].dx > 0)) {
        directions[i] = Offset(-directions[i].dx, directions[i].dy);
      }
      if ((positions[i].dy <= 0 && directions[i].dy < 0) ||
          (positions[i].dy >= movementAreaHeight - assetSize &&
              directions[i].dy > 0)) {
        directions[i] = Offset(directions[i].dx, -directions[i].dy);
      }
    }

    // Sprawdzanie kolizji między asetami
    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        double deltaX = positions[i].dx - positions[j].dx;
        double deltaY = positions[i].dy - positions[j].dy;
        double distance = sqrt(deltaX * deltaX + deltaY * deltaY);

        double minDistance = assetSize; // Rozmiar asetu w pikselach

        if (distance < minDistance && distance > 0) {
          // Obliczenie normalnego wektora kolizji
          double nx = deltaX / distance;
          double ny = deltaY / distance;

          // Obliczenie prędkości względnej
          double dvx = directions[i].dx - directions[j].dx;
          double dvy = directions[i].dy - directions[j].dy;

          // Obliczenie prędkości wzdłuż normalnej
          double vn = dvx * nx + dvy * ny;

          // Jeśli asety się oddalają, nie robić nic
          if (vn > 0) continue;

          // Prosta reakcja na kolizję: zamiana prędkości wzdłuż normalnej
          double restitution =
              1.0; // Współczynnik restytucji (1.0 dla idealnie sprężystego odbicia)
          double impulse = (-(1 + restitution) * vn) / 2;

          directions[i] = directions[i] + Offset(nx * impulse, ny * impulse);
          directions[j] = directions[j] - Offset(nx * impulse, ny * impulse);

          // Przesunięcie asetów, aby nie nachodziły na siebie
          double overlap = 0.5 * (minDistance - distance);
          positions[i] = positions[i] + Offset(nx * overlap, ny * overlap);
          positions[j] = positions[j] - Offset(nx * overlap, ny * overlap);
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double offsetX = (movementAreaWidth - containerWidth) / 2;
    double offsetY = (movementAreaHeight - containerHeight) / 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: widget.onCreatePressed,
        child: Container(
          width: double.infinity,
          height: containerHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Stack(
              children: [
                for (int i = 0; i < positions.length; i++)
                  Positioned(
                    left: positions[i].dx - offsetX,
                    top: positions[i].dy - offsetY,
                    child: SizedBox(
                      width: assetSize,
                      height: assetSize,
                      child: Image.asset(assetImages[i]),
                    ),
                  ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.97),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Health Events',
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
