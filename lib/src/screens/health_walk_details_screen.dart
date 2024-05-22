import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/models/event_walk_model.dart';

class HealthWalkDetailsScreen extends StatelessWidget {
  final EventWalkModel walk;

  const HealthWalkDetailsScreen({super.key, required this.walk});

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
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColorDark.withOpacity(0.7),
        ),
        title: Text(
          'W a l k  d e t a i l s',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark.withOpacity(0.7)),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
      ),
      body: Padding(
        padding: padding,
        child: Container(
          width: double.infinity, // Dopasowanie do szerokości ekranu
          height: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                blurRadius: 10,
                offset: const Offset(0, 02),
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
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColorDark.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
