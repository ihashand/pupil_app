import 'dart:math';

String generateUniqueId() {
  var timestamp = DateTime.now().millisecondsSinceEpoch;
  var random = Random().nextInt(999999);
  return '$timestamp$random';
}
