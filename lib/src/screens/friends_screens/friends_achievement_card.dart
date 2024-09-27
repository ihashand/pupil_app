import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';

class FriendsAchievementCard extends StatefulWidget {
  const FriendsAchievementCard({
    super.key,
    required this.context,
    required this.achievement,
    required this.petsWithAchievement,
    required this.isAchieved,
  });

  final BuildContext context;
  final Achievement achievement;
  final List<Pet> petsWithAchievement;
  final bool isAchieved;

  @override
  createState() => _FriendsAchievementCardState();
}

class _FriendsAchievementCardState extends State<FriendsAchievementCard> {
  String? _selectedPetName;
  int? _selectedPetIndex;
  Timer? _hideNameTimer;
  ConfettiController? _confettiController;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void dispose() {
    _hideNameTimer?.cancel();
    _confettiController?.dispose();
    super.dispose();
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

  void _showAchievementDetail() {
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _confettiController?.play();

    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        radius: 15,
                        child: Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 22,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Screenshot(
                    controller: _screenshotController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: CircleAvatar(
                            backgroundImage:
                                AssetImage(widget.achievement.avatarUrl),
                            radius: 100,
                          ),
                        ),
                        Text(
                          widget.achievement.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          widget.achievement.description,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(160, 40),
                      foregroundColor: Theme.of(context).primaryColorDark,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () async {
                      final Uint8List? imageBytes =
                          await _screenshotController.capture();
                      if (imageBytes != null) {
                        final tempDir = await getTemporaryDirectory();
                        final file =
                            await File('${tempDir.path}/achievement.png')
                                .create();
                        await file.writeAsBytes(imageBytes);

                        Share.shareFiles([file.path],
                            text:
                                'I unlocked the achievement ${widget.achievement.name}!\n\n${widget.achievement.description}');
                      }
                    },
                    child: Text(
                      'Share',
                      style:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isAchieved)
              ConfettiWidget(
                confettiController: _confettiController!,
                blastDirectionality: BlastDirectionality.directional,
                shouldLoop: false,
                blastDirection: -pi / 2,
                maxBlastForce: 30,
                minBlastForce: 15,
                gravity: 0.03,
                colors: const [
                  Color(0xffdfd785),
                  Color(0xff68a2b6),
                ],
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isAchieved ? _showAchievementDetail : null,
      child: Card(
        color: widget.isAchieved
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center, // Wyśrodkujemy kłódkę
                children: [
                  CircleAvatar(
                    backgroundImage: widget.isAchieved
                        ? AssetImage(widget.achievement.avatarUrl)
                        : null,
                    radius: 65,
                    backgroundColor: widget.isAchieved
                        ? Colors.transparent
                        : Colors.grey[500],
                    child: !widget.isAchieved
                        ? const Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 40,
                          )
                        : null,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Column(
                  children: [
                    Text(
                      widget.isAchieved
                          ? '${widget.achievement.stepsRequired}'
                          : '???',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: widget.isAchieved
                            ? Theme.of(context).primaryColorDark
                            : Colors.grey[800],
                      ),
                    ),
                    Text(
                      "S T E P S",
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isAchieved
                            ? Theme.of(context).primaryColorDark
                            : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isAchieved) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        widget.petsWithAchievement.asMap().entries.map((entry) {
                      int index = entry.key;
                      Pet pet = entry.value;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _togglePetNameDisplay(index, pet.name);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: CircleAvatar(
                                backgroundImage: AssetImage(pet.avatarImage),
                                radius: 20,
                              ),
                            ),
                          ),
                          if (_selectedPetName != null &&
                              _selectedPetIndex == index)
                            Positioned(
                              top: -30,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
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
                      );
                    }).toList(),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
