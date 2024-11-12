import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pet_diary/src/helpers/animations/slide_animation_helper.dart';
import 'package:pet_diary/src/helpers/messages/empty_state_widget.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_medicine_provider.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/screens/medicine_screens/add_medicine_screen.dart';

class MedicineScreen extends ConsumerStatefulWidget {
  final String petId;

  const MedicineScreen(this.petId, {super.key});

  @override
  ConsumerState<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends ConsumerState<MedicineScreen> {
  bool isCurrentSelected = true;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).primaryColorDark, size: 20),
        title: Text(
          'M E D I C I N E',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).primaryColorDark,
              size: 24,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddMedicineScreen(
                  ref: ref,
                  petId: widget.petId,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Divider(color: Theme.of(context).colorScheme.surface),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isCurrentSelected = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: isCurrentSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Current Medicine',
                            style: TextStyle(
                              color: isCurrentSelected
                                  ? Theme.of(context).primaryColorDark
                                  : Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isCurrentSelected = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: !isCurrentSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Medicine History',
                            style: TextStyle(
                              color: !isCurrentSelected
                                  ? Theme.of(context).primaryColorDark
                                  : Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.4),
                              fontWeight: FontWeight.bold,
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
          const SizedBox(height: 7),
          Expanded(
            child: StreamBuilder<List<EventMedicineModel>>(
              stream: ref.watch(eventMedicineServiceProvider).getPills(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: SlideAnimationHelper(
                    duration: const Duration(milliseconds: 2600),
                    curve: Curves.bounceOut,
                    child: EmptyStateWidget(
                      message: isCurrentSelected
                          ? "No current medicines found."
                          : "No medicine history available.",
                      icon: Icons.pets,
                    ),
                  ));
                }

                final petMedicines = snapshot.data;

                final filteredMedicines = petMedicines!.where((medicine) {
                  final endDate = medicine.endDate ?? DateTime.now();
                  if (isCurrentSelected) {
                    return endDate.isAfter(now) ||
                        endDate.isAtSameMomentAs(now);
                  } else {
                    return endDate.isBefore(now);
                  }
                }).toList();

                return ListView.builder(
                  itemCount: filteredMedicines.length,
                  itemBuilder: (context, index) {
                    final medicine = filteredMedicines[index];
                    return MedicineTile(
                      medicine: medicine,
                      onDelete: () => deletePill(context, ref, widget.petId,
                          medicine: medicine),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void deletePill(
    BuildContext context,
    WidgetRef ref,
    String petId, {
    EventMedicineModel? medicine,
  }) async {
    await ref.read(eventMedicineServiceProvider).deleteMedicine(medicine!.id);

    // Usunięcie wszystkich powiązanych eventów z pigułką
    final events =
        await ref.read(eventServiceProvider).getEventsByPillId(medicine.id);
    for (var event in events) {
      await ref.read(eventServiceProvider).deleteEvent(event.id);
    }
  }
}

class MedicineTile extends StatefulWidget {
  final EventMedicineModel medicine;
  final VoidCallback onDelete;

  const MedicineTile({
    super.key,
    required this.medicine,
    required this.onDelete,
  });

  @override
  createState() => _MedicineTileState();
}

class _MedicineTileState extends State<MedicineTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        color: Theme.of(context).colorScheme.primary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            ListTile(
              visualDensity: const VisualDensity(vertical: 4),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Text(
                  widget.medicine.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              title: Row(
                children: [
                  Text(
                    widget.medicine.name,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.medicine.dosage != null &&
                      widget.medicine.dosage!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.medicine.dosage ?? '',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete,
                    color: Theme.of(context).primaryColorDark),
                onPressed: widget.onDelete,
              ),
            ),
            SizeTransition(
              sizeFactor: _animation,
              axisAlignment: 1.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, 'Medication Details'),
                    _buildDetailRow(
                        context, 'Type', widget.medicine.medicineType),
                    _buildDetailRow(context, 'Frequency',
                        widget.medicine.frequency ?? 'N/A'),
                    const SizedBox(height: 10),
                    _buildSectionHeader(context, 'Dates'),
                    _buildDetailRow(
                        context,
                        'Start Date',
                        dateFormat.format(
                            widget.medicine.startDate ?? DateTime.now())),
                    _buildDetailRow(
                        context,
                        'End Date',
                        dateFormat
                            .format(widget.medicine.endDate ?? DateTime.now())),
                    const SizedBox(height: 10),
                    _buildSectionHeader(context, 'Schedule Information'),
                    _buildScheduleDetails(
                        context, widget.medicine.scheduleDetails),
                    const SizedBox(height: 10),
                    _buildSectionHeader(context, 'Times'),
                    _buildTimesList(context, widget.medicine.times),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColorDark,
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Theme.of(context).primaryColorDark,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleDetails(BuildContext context, String? scheduleDetails) {
    final bool isDaysInterval =
        scheduleDetails != null && scheduleDetails.contains('Every');
    final List<String> daysOfWeek = scheduleDetails?.split(', ') ?? ['N/A'];

    if (isDaysInterval) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              color: Theme.of(context).primaryColorDark,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                scheduleDetails,
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: daysOfWeek.map((day) {
          return Chip(
            label: Text(
              day,
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
          );
        }).toList(),
      );
    }
  }

  Widget _buildTimesList(BuildContext context, List<TimeOfDay> times) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: times.map((time) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 18,
                color: Theme.of(context).primaryColorDark,
              ),
              const SizedBox(width: 8),
              Text(
                time.format(context),
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
