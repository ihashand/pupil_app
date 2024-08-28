double calculateFill(double consumed, double dailyGoal) {
  return dailyGoal == 0 ? 0 : consumed / dailyGoal;
}
