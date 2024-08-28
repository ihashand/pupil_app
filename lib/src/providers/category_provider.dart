import 'package:flutter_riverpod/flutter_riverpod.dart';

// Definicja providera dla zarządzania kategorią
final selectedCategoryProvider = StateProvider<String>((ref) {
  return 'all'; // Domyślnie ustawiona kategoria to 'all'
});
