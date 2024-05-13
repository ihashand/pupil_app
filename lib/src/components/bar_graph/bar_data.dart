import 'package:pet_diary/src/components/bar_graph/individual_bar.dart';

class WeeklyBarData {
  final double oneData;
  final double twoData;
  final double threeData;
  final double fourData;
  final double fiveData;
  final double sixData;
  final double sevenData;
  final double eightData;
  final double nineData;
  final double tenData;
  final double elevenData;
  final double twelveData;
  final double thirteenData;
  final double fourteenData;
  final double fifteenData;
  final double sixteenData;
  final double seventeenData;
  final double eighteenData;
  final double nineteenData;
  final double twentyData;
  final double twentyOneData;
  final double twentyTwoData;
  final double twentyThreeData;
  final double twentyFourData;

  WeeklyBarData({
    required this.oneData,
    required this.twoData,
    required this.threeData,
    required this.fourData,
    required this.fiveData,
    required this.sixData,
    required this.sevenData,
    required this.eightData,
    required this.nineData,
    required this.tenData,
    required this.elevenData,
    required this.twelveData,
    required this.thirteenData,
    required this.fourteenData,
    required this.fifteenData,
    required this.sixteenData,
    required this.seventeenData,
    required this.eighteenData,
    required this.nineteenData,
    required this.twentyData,
    required this.twentyOneData,
    required this.twentyTwoData,
    required this.twentyThreeData,
    required this.twentyFourData,
  });

  List<IndividualBar> barData = [];

  // initialize data
  void initializeWeeklyBarData(selectedTimePeriod, dataBarGraph) {
    switch (selectedTimePeriod) {
      case 'D': // daily
        barData = List.generate(24, (index) {
          double data = dataBarGraph[index % 24];
          return IndividualBar(x: index, y: data);
        });
        break;
      case 'W': // weekly
        barData = List.generate(7, (index) {
          double data = dataBarGraph[index % 7];
          return IndividualBar(x: index, y: data);
        });
        break;
      case 'M': // monthly
        barData = List.generate(7, (index) {
          double data = dataBarGraph[index];
          return IndividualBar(x: index, y: data);
        });
        break;
      case 'Y': // yearly
        barData = List.generate(11, (index) {
          double data = 0.0;
          if (index <= 11) {
            data = dataBarGraph[index];
          }
          return IndividualBar(x: index, y: data);
        });
        break;
      default:
        barData = List.generate(7, (index) {
          double data = dataBarGraph[index];
          return IndividualBar(x: index, y: data);
        });
        break;
    }
  }
}
