import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/reminder_models/vet_appotiment_reminder_model.dart';
import 'package:pet_diary/src/providers/reminder_providers/vet_appointment_reminder_provider.dart';
import 'package:pet_diary/src/providers/others_providers/user_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/services/notification_services/notification_services.dart';

/// Ekran do zarządzania wizytami u weterynarza.
class VetAppointmentScreen extends ConsumerStatefulWidget {
  const VetAppointmentScreen({super.key});

  @override
  ConsumerState<VetAppointmentScreen> createState() =>
      _VetAppointmentScreenState();
}

class _VetAppointmentScreenState extends ConsumerState<VetAppointmentScreen> {
  bool isCurrentAppointments = true; // Przełącznik widoku: obecne/historia
  final TextEditingController _reasonController = TextEditingController();
  final List<String> _selectedPets = []; // Wybrane zwierzaki
  DateTime? _selectedDate; // Wybrana data wizyty
  TimeOfDay? _selectedTime; // Wybrany czas wizyty
  List<Map<String, dynamic>> _additionalNotifications = [
    {'value': 1, 'unit': 'day'}, // Domyślne wczesne powiadomienie
  ];
  bool enableAdditionalNotifications =
      false; // Czy włączono wczesne powiadomienia

  @override
  Widget build(BuildContext context) {
    final userId = ref.read(userIdProvider)!; // ID użytkownika
    final now = DateTime.now(); // Aktualny czas

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
            onPressed:
                _showAddAppointmentModal, // Wyświetlenie modalu dodawania wizyty
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToggleButtons(), // Przełączniki widoków
          Expanded(
            child: StreamBuilder<List<VetAppointmentModel>>(
              stream: ref
                  .read(vetAppointmentServiceProvider)
                  .getVetAppointments(userId), // Pobieranie danych z Firestore
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
                final filteredAppointments = _filterAppointments(
                    appointments, now); // Filtrowanie danych

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
                    return _buildAppointmentCard(
                        appointment); // Tworzenie karty wizyty
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Przełączniki między widokami obecnych wizyt i historii.
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

  /// Tworzenie pojedynczego przycisku przełącznika widoku.
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

  /// Filtrowanie wizyt na obecne lub historyczne.
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

  /// Tworzenie karty wizyty.
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

  /// Wyświetlanie modalu dodawania wizyty.
  void _showAddAppointmentModal() {
    _reasonController.clear();
    _selectedDate = null;
    _selectedTime = null;
    enableAdditionalNotifications = false;
    _additionalNotifications = [
      {'value': 1, 'unit': 'day'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add Vet Appointment',
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
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Theme.of(context).colorScheme.secondary),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildPetSelection(setModalState),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildReasonInput(setModalState),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildDatePicker(setModalState),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildTimePicker(setModalState),
                      ),
                      Divider(color: Theme.of(context).colorScheme.secondary),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildAdditionalNotifications(setModalState),
                      ),
                      const SizedBox(
                        height: 25,
                      )
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

  Widget _buildAdditionalNotifications(StateSetter setModalState) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: enableAdditionalNotifications ? 8.0 : 15.0,
            right: enableAdditionalNotifications ? 8.0 : 15.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Early Notifications',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: enableAdditionalNotifications,
                activeColor: Theme.of(context).primaryColorDark,
                onChanged: (value) {
                  setModalState(() {
                    enableAdditionalNotifications = value;
                    if (!value) _additionalNotifications.clear();
                  });
                },
              ),
            ],
          ),
        ),
        if (enableAdditionalNotifications)
          Column(
            children: [
              for (int i = 0; i < _additionalNotifications.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 185,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Value',
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColorDark,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColorDark,
                                width: 1,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                          ),
                          cursorColor: Theme.of(context).primaryColorDark,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setModalState(() {
                              _additionalNotifications[i]['value'] =
                                  int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                      Row(
                        children: [
                          DropdownButton<String>(
                            value: _additionalNotifications[i]['unit'],
                            items: ['minute', 'hour', 'day']
                                .map(
                                  (unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ),
                                )
                                .toList(),
                            onChanged: (unit) {
                              setModalState(() {
                                _additionalNotifications[i]['unit'] = unit!;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.black),
                            onPressed: () {
                              setModalState(() {
                                _additionalNotifications.removeAt(i);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              if (_additionalNotifications.length < 3)
                TextButton(
                  onPressed: () {
                    setModalState(() {
                      if (_additionalNotifications.length < 3) {
                        _additionalNotifications.add({
                          'value': 1,
                          'unit': 'minute',
                        });
                      }
                    });
                  },
                  child: Text(
                    '+ Add Notification',
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _saveAppointment(StateSetter setModalState) async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _reasonController.text.isEmpty ||
        _selectedPets.isEmpty) {
      await _showValidationError(context);
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

    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final List<int> earlyNotificationIds = [];

    // Główne powiadomienie
    if (appointmentDateTime.isAfter(DateTime.now())) {
      await NotificationService().createSingleNotification(
        id: appointment.hashCode,
        title: 'Vet Appointment',
        body: _generateNotificationBody(appointment),
        dateTime: appointmentDateTime,
        payload: 'vet_appointment',
      );
    }

    // Wczesne powiadomienia
    for (var notification in _additionalNotifications) {
      final int value = notification['value'];
      final String unit = notification['unit'];

      DateTime earlyNotificationTime;
      if (unit == 'minute') {
        earlyNotificationTime = appointmentDateTime.subtract(
          Duration(minutes: value),
        );
      } else if (unit == 'hour') {
        earlyNotificationTime = appointmentDateTime.subtract(
          Duration(hours: value),
        );
      } else {
        earlyNotificationTime = appointmentDateTime.subtract(
          Duration(days: value),
        );
      }

      if (earlyNotificationTime.isAfter(DateTime.now())) {
        final earlyNotificationId = appointment.hashCode + value; // Unique ID
        earlyNotificationIds.add(earlyNotificationId);
        await NotificationService().createSingleNotification(
          id: earlyNotificationId,
          title: 'Early Vet Appointment Reminder',
          body: _generateNotificationBody(appointment),
          dateTime: earlyNotificationTime,
          payload: 'vet_appointment_early',
        );
      }
    }

    // Zaktualizuj model wizyty z wczesnymi powiadomieniami
    final updatedAppointment = appointment.copyWith(
      earlyNotificationIds: earlyNotificationIds,
    );

    await ref
        .read(vetAppointmentServiceProvider)
        .addAppointment(updatedAppointment);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _generateNotificationBody(VetAppointmentModel appointment) {
    final selectedPets = _selectedPets.map((id) {
      return ref.read(petsProvider).maybeWhen(
          data: (pets) => pets.firstWhere((pet) => pet.id == id).name,
          orElse: () => '');
    }).join(', ');

    return 'Vet appointment for: $selectedPets - ${appointment.reason}';
  }

  Future<void> _showValidationError(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Empty fields',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          content: const Text(
            'Please fill in all required fields!',
            textAlign: TextAlign.left,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
          ],
        );
      },
    );
  }

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

  Widget _buildReasonInput(StateSetter setModalState) {
    return TextField(
      controller: _reasonController,
      decoration: InputDecoration(
        labelText: 'Reason',
        labelStyle: TextStyle(
          color: Theme.of(context).primaryColorDark, // Kolor etykiety
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context)
                .primaryColorDark, // Kolor obramowania po fokusie
            width: 1, // Grubość obramowania
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context)
                .primaryColorDark, // Kolor obramowania aktywnego
            width: 1,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // Zaokrąglenie ramki
          borderSide: BorderSide(
            color: Theme.of(context)
                .primaryColorDark, // Kolor domyślnego obramowania
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10, // Odstęp góra/dół
          horizontal: 15, // Odstęp lewo/prawo
        ),
      ),
      style: TextStyle(
        color: Theme.of(context).primaryColorDark, // Kolor tekstu w polu
      ),
      cursorColor: Theme.of(context).primaryColorDark, // Kolor kursora
      onChanged: (value) {
        setModalState(() {});
      },
    );
  }

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
}
