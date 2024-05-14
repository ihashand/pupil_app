import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/models/walk_model.dart';

class AllDataWalkDetailsScreen extends StatelessWidget {
  final Walk walk;

  const AllDataWalkDetailsScreen({super.key, required this.walk});

  @override
  Widget build(BuildContext context) {
    // Przeliczenie walkTime z minut na godziny i minuty
    final int walkTimeInt = walk.walkTime.toInt();
    final int hours = walkTimeInt ~/ 60;
    final int minutes = walkTimeInt % 60;
    final String walkTimeFormatted =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} h';

    // Formatowanie daty
    final String formattedDate =
        DateFormat('dd-MM-yyyy').format(walk.dateTime.toLocal());

    // Padding dla kafelka
    const EdgeInsetsGeometry padding = EdgeInsets.all(16.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: padding,
        child: Container(
          width: double.infinity, // Dopasowanie do szerokości ekranu
          height: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(context, 'Walk Time', walkTimeFormatted),
                const SizedBox(height: 8),
                _buildDetailRow(context, 'Distance', '${walk.distance} steps'),
                const SizedBox(height: 8),
                _buildDetailRow(context, 'Date', formattedDate),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
            color: Theme.of(context).primaryColorDark.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
      ),
    );
  }
}
