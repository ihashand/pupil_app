import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/medicine_model.dart';
import 'package:pet_diary/src/data/services/local_medicine_service.dart';
import 'package:pet_diary/src/providers/medicine_provider.dart';
import 'package:pet_diary/src/synchronization/sync_medicine_service.dart';

class MedicineNotifier extends StateNotifier<List<Medicine>> {
  final LocalMedicineService _medicineService;

  MedicineNotifier(this._medicineService) : super([]) {
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    final medicines = _medicineService.getAllMedicines();
    state = medicines;
  }

  Future<void> addMedicine(Medicine medicine) async {
    await SyncMedicineService.addMedicine(medicine);
    state = [...state, medicine];
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await SyncMedicineService.updateMedicine(medicine);
    state = state.map((m) => m.id == medicine.id ? medicine : m).toList();
  }

  Future<void> deleteMedicine(String id) async {
    await SyncMedicineService.deleteMedicine(id);
    state = state.where((m) => m.id != id).toList();
  }
}

final medicineNotifierProvider =
    StateNotifierProvider<MedicineNotifier, List<Medicine>>((ref) {
  final medicineService = ref.read(localMedicineServiceProvider);
  return MedicineNotifier(medicineService);
});
