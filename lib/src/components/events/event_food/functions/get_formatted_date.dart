import 'package:intl/intl.dart';

String getFormattedDate(DateTime selectedDate, DateTime today) {
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));

  if (selectedDate.isAtSameMomentAs(today)) {
    return 'Today';
  } else if (selectedDate.isAtSameMomentAs(yesterday)) {
    return 'Yesterday';
  } else if (selectedDate.isAtSameMomentAs(tomorrow)) {
    return 'Tomorrow';
  } else {
    return DateFormat('dd MMM yyyy').format(selectedDate);
  }
}
