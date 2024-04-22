import 'dart:math';

String generateUniqueId() {
  var timestamp = DateTime.now().millisecondsSinceEpoch;
  var random = Random().nextInt(999999);
  return '$timestamp$random';
}

String generateUniqueIdWithinRange() {
  var random = Random().nextInt(pow(2, 31).toInt() -
      1); // Maksymalna wartość dla 32-bitowej liczby całkowitej
  return '$random';
}
