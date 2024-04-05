String calculateAge(String birthDate) {
  List<String> dateParts = birthDate.split('/');
  int day = int.parse(dateParts[0]);
  int month = int.parse(dateParts[1]);
  int year = int.parse(dateParts[2]);

  DateTime now = DateTime.now();
  DateTime birthday = DateTime(year, month, day);

  int years = now.year - birthday.year;
  int months = now.month - birthday.month;
  int days = now.day - birthday.day;

  if (months < 0 || (months == 0 && days < 0)) {
    years--;
    months += 12;
  }

  if (days < 0) {
    final lastMonth = DateTime(now.year, now.month, 0);
    days += lastMonth.day;
    months--;
  }

  if (years > 0) {
    return '$years Years old';
  } else if (months > 0) {
    return '$months Month${months > 1 ? 's' : ''} old';
  } else if (days >= 0) {
    return '$days Day${days != 1 ? 's' : ''} old';
  } else {
    return 'First day on earth!';
  }
}
