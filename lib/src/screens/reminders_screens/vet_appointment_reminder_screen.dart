import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pet_diary/src/models/reminder_models/vet_appotiment_reminder_model.dart';
import 'package:pet_diary/src/providers/reminder_providers/vet_appointment_reminder_provider.dart';
import 'package:pet_diary/src/providers/others_providers/user_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/services/notification_services/notification_services.dart';

/// Screen for managing vet appointments.
class VetAppointmentScreen extends ConsumerStatefulWidget {
  const VetAppointmentScreen({super.key});

  @override
  ConsumerState<VetAppointmentScreen> createState() =>
      _VetAppointmentScreenState();
}

class _VetAppointmentScreenState extends ConsumerState<VetAppointmentScreen> {
  bool isCurrentAppointments = true;
  final TextEditingController _reasonController = TextEditingController();
  final List<String> _selectedPets = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final userId = ref.read(userIdProvider)!;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'V E T  A P P O I N T M E N T S',
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorDark),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).primaryColorDark,
              size: 30,
            ),
            onPressed: _showAddAppointmentModal,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToggleButtons(),
          Expanded(
            child: StreamBuilder<List<VetAppointmentModel>>(
              stream: ref
                  .read(vetAppointmentServiceProvider)
                  .getVetAppointments(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                final appointments = snapshot.data ?? [];
                final filteredAppointments =
                    _filterAppointments(appointments, now);

                if (filteredAppointments.isEmpty) {
                  return Center(
                    child: Text(
                      isCurrentAppointments
                          ? 'No upcoming appointments.'
                          : 'No appointment history.',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = filteredAppointments[index];
                    return _buildAppointmentCard(appointment);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds toggle buttons for Current/History.
  Widget _buildToggleButtons() {
    return Container(
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
                _buildToggleButton('Current', true),
                _buildToggleButton('History', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single toggle button for Current/History selection.
  Widget _buildToggleButton(String label, bool isSelected) {
    final isActive = isSelected == isCurrentAppointments;
    return GestureDetector(
      onTap: () {
        setState(() {
          isCurrentAppointments = isSelected;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Theme.of(context).primaryColorDark
                : Theme.of(context).primaryColorDark.withOpacity(0.4),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<VetAppointmentModel> _filterAppointments(
      List<VetAppointmentModel> appointments, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);

    return isCurrentAppointments
        ? appointments
            .where((appointment) =>
                appointment.date.isAtSameMomentAs(today) ||
                appointment.date.isAfter(today))
            .toList()
        : appointments
            .where((appointment) => appointment.date.isBefore(today))
            .toList();
  }

  /// Builds a fully expanded appointment card.
  Widget _buildAppointmentCard(VetAppointmentModel appointment) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vet Appointment',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${appointment.time.format(context)}  ${DateFormat('dd-MM-yyyy').format(appointment.date)} ',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                appointment.reason,
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark, fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: appointment.assignedPetIds.map((petId) {
                      final pet = ref.read(petsProvider).maybeWhen(
                            data: (pets) => pets.firstWhere(
                              (pet) => pet.id == petId,
                            ),
                            orElse: () => null,
                          );
                      return pet != null
                          ? Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: CircleAvatar(
                                backgroundImage: AssetImage(pet.avatarImage),
                                radius: 25,
                              ),
                            )
                          : Container();
                    }).toList(),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () async {
                      await ref
                          .read(vetAppointmentServiceProvider)
                          .deleteAppointment(appointment.id);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays a modal for adding a new vet appointment.
  void _showAddAppointmentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Vet Appointment',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _saveAppointment(setModalState),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).primaryColorDark,
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(height: 12),
                      _buildPetSelection(setModalState),
                      const SizedBox(height: 12),
                      _buildReasonInput(setModalState),
                      const SizedBox(height: 12),
                      _buildDatePicker(setModalState),
                      const SizedBox(height: 12),
                      _buildTimePicker(setModalState),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Builds the pet selection widget for the modal.
  Widget _buildPetSelection(StateSetter setModalState) {
    final asyncPets = ref.watch(petsProvider);
    return asyncPets.when(
      data: (pets) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: pets.map((pet) {
              final isSelected = _selectedPets.contains(pet.id);
              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: GestureDetector(
                  onTap: () {
                    setModalState(() {
                      isSelected
                          ? _selectedPets.remove(pet.id)
                          : _selectedPets.add(pet.id);
                    });
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage(pet.avatarImage),
                    radius: 30,
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text(e.toString()),
    );
  }

  /// Builds the reason input widget for the modal.
  Widget _buildReasonInput(StateSetter setModalState) {
    return TextField(
      controller: _reasonController,
      decoration: InputDecoration(
        labelText: 'Reason',
        labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onChanged: (value) {
        setModalState(() {}); // Update modal state
      },
    );
  }

  /// Builds the date picker widget for the modal.
  Widget _buildDatePicker(StateSetter setModalState) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showStyledDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
        );
        if (pickedDate != null) {
          setModalState(() {
            _selectedDate = pickedDate;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          _selectedDate != null
              ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
              : 'Select Date',
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
      ),
    );
  }

  /// Builds the time picker widget for the modal.
  Widget _buildTimePicker(StateSetter setModalState) {
    return GestureDetector(
      onTap: () async {
        final pickedTime = await showStyledTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setModalState(() {
            _selectedTime = pickedTime;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Time',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          _selectedTime != null
              ? _selectedTime!.format(context)
              : 'Select Time',
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
      ),
    );
  }

  /// Saves the appointment and closes the modal.
  Future<void> _saveAppointment(StateSetter setModalState) async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _reasonController.text.isEmpty ||
        _selectedPets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    final userId = ref.read(userIdProvider)!;

    final appointment = VetAppointmentModel(
      id: UniqueKey().toString(),
      userId: userId,
      date: _selectedDate!,
      time: _selectedTime!,
      reason: _reasonController.text,
      assignedPetIds: _selectedPets,
    );

    await ref.read(vetAppointmentServiceProvider).addAppointment(appointment);

    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (appointmentDateTime.isAfter(DateTime.now())) {
      await NotificationService().createSingleNotification(
        id: appointment.hashCode,
        title: 'Vet Appointment',
        body: appointment.reason,
        dateTime: appointmentDateTime,
        payload: 'vet_appointment',
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
