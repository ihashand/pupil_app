import 'package:hive/hive.dart';
import 'package:pet_diary/src/models/medicine_model.dart';

class LocalMedicineService {
  final Box<Medicine> _medicineBox;

  LocalMedicineService(this._medicineBox);

  Future<void> addMedicine(Medicine medicine) async {
    await _medicineBox.put(medicine.id, medicine);
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await _medicineBox.put(medicine.id, medicine);
  }

  Future<void> deleteMedicine(String medicineId) async {
    await _medicineBox.delete(medicineId);
  }

  List<Medicine> getAllMedicines() {
    return _medicineBox.values.toList();
  }

  Stream<List<Medicine>> watchAllMedicines() {
    return _medicineBox.watch().map((event) => getAllMedicines());
  }
}
