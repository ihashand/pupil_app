// calculate average, but without 0
// if in data there is 0, then do not count it.
double calculateAverage(List<double> data) {
  if (data.isEmpty) {
    return 0.0;
  }

  double sum = 0.0;
  int nonZeroCount = 0;

  for (double number in data) {
    if (number != 0) {
      sum += number;
      nonZeroCount++;
    }
  }

  if (nonZeroCount == 0) {
    return 0.0;
  }

  return sum / nonZeroCount;
}
