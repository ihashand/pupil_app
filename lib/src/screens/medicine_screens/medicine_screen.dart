import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pet_diary/src/components/events/event_medicine/add_medicine/show_add_medicine_name.dart';
import 'package:pet_diary/src/helpers/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_medicine_provider.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/screens/medicine_screens/medicine_add_edit_screen.dart';

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
    var newPillId = generateUniqueId();
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
            onPressed: () => showAddMedicineName(context, ref, widget.petId),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(),
        ),
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
                  return const Center(child: Text('No medicine found.'));
                }

                final petMedicines = snapshot.data;

                if (petMedicines!.isEmpty) {
                  return const Center(child: Text('No medicine found.'));
                }

                final filteredMedicines = petMedicines.where((medicine) {
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
                      onEdit: () => addOrEditMedicine(
                        context,
                        ref,
                        widget.petId,
                        newPillId,
                        medicine: medicine,
                      ),
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

  void addOrEditMedicine(
    BuildContext context,
    WidgetRef ref,
    String petId,
    String newMedicineId, {
    EventMedicineModel? medicine,
  }) async {
    final bool isEditing = medicine != null;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineAddEditScreen(
          petId,
          newMedicineId,
          medicine: medicine,
        ),
      ),
    );
    if (result != null) {
      if (isEditing) {
        await ref.read(eventMedicineServiceProvider).updateMedicine(result);
      } else {
        await ref.read(eventMedicineServiceProvider).addMedicine(result);
      }
    }
  }

  void deletePill(
    BuildContext context,
    WidgetRef ref,
    String petId, {
    EventMedicineModel? medicine,
  }) async {
    await ref.read(eventMedicineServiceProvider).deleteMedicine(medicine!.id);
  }
}

class MedicineTile extends StatefulWidget {
  final EventMedicineModel medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicineTile({
    super.key,
    required this.medicine,
    required this.onEdit,
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
                      widget.medicine.dosage != '0 mg' &&
                      widget.medicine.dosage != '0 mcg' &&
                      widget.medicine.dosage != '0 g' &&
                      widget.medicine.dosage != '0 ml' &&
                      widget.medicine.dosage != '0 %' &&
                      widget.medicine.dosage != '')
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${widget.medicine.dosage}',
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
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                              child: _buildDetailColumn(context, 'Frequency',
                                  widget.medicine.frequency ?? 'N/A'),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                              child: _buildDetailColumn(
                                  context,
                                  'Start',
                                  dateFormat.format(widget.medicine.startDate ??
                                      DateTime.now())),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                              child: _buildDetailColumn(context, 'Type',
                                  widget.medicine.medicineType),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                              child: _buildDetailColumn(
                                  context,
                                  'End',
                                  dateFormat.format(widget.medicine.endDate ??
                                      DateTime.now())),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildScheduleDetails(
                        context, widget.medicine.scheduleDetails)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleDetails(BuildContext context, String? scheduleDetails) {
    final List<String> daysOfWeek = scheduleDetails?.split(', ') ?? ['N/A'];

    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          const SizedBox(height: 5),
          Wrap(
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
          ),
        ],
      ),
    );
  }
}
