import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/widgets/report_widget/show_date_range_dialog.dart';

class GenerateReportSection extends ConsumerWidget {
  final String petId;

  const GenerateReportSection({
    required this.petId,
    super.key,
  });

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.picture_as_pdf, size: 80, color: Color(0xff68a2b6)),
          const SizedBox(height: 8), //todo0xffdfd785
          Text(
            "Generate a detailed health report in PDF, chose the date range and generate it for free!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark.withOpacity(0.7),
            ),
          ),
          const Divider(color: Colors.grey, height: 20),
          TextButton(
            onPressed: () async {
              final pet = await ref.read(petServiceProvider).getPetById(petId);
              if (pet != null) {
                // ignore: use_build_context_synchronously
                await showDateRangeDialog(context, ref, pet);
              }
            },
            child: Text(
              "Generate Report",
              style: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
