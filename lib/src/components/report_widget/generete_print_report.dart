import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/events_models/event_walk_model.dart';
import '../../models/others/pet_model.dart';
import '../../providers/events_providers/event_walk_provider.dart';

Future<void> generateAndPrintReport(
    WidgetRef ref, Pet pet, DateTimeRange dateRange) async {
  final pdf = pw.Document();

  List<EventWalkModel> petWalks = ref.read(eventWalksProvider).when(
        data: (data) => data
            .where((walk) => walk.petId == pet.id)
            .map((walk) => walk)
            .toList(),
        loading: () => [],
        error: (error, stack) => [],
      );

  List<EventWalkModel> filteredWalks = petWalks.where((walk) {
    return walk.dateTime.isAfter(dateRange.start) &&
        walk.dateTime.isBefore(dateRange.end);
  }).toList();

  double totalSteps = filteredWalks.fold(0, (sum, walk) => sum + walk.steps);
  double totalActiveMinutes =
      filteredWalks.fold(0, (sum, walk) => sum + walk.walkTime);
  double totalDistance = (totalSteps * 0.0008); // Assuming 1 step = 0.0008 km
  double totalCaloriesBurned = totalSteps * 0.04;

  double averageSteps = totalSteps / filteredWalks.length;
  double averageDistance = totalDistance / filteredWalks.length;
  double averageActiveMinutes = totalActiveMinutes / filteredWalks.length;

  final avatar = await imageFromAssetBundle(pet.avatarImage);

  pdf.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(0),
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(
            await rootBundle.load("assets/fonts/OpenSans-Regular.ttf")),
        bold: pw.Font.ttf(
            await rootBundle.load("assets/fonts/OpenSans-Bold.ttf")),
      ),
      header: (context) => pw.Container(
        color: PdfColor.fromHex('#f0f9ff'),
        padding:
            const pw.EdgeInsets.only(left: 40, right: 20, top: 20, bottom: 10),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("P U P I L L A P P",
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black)),
                pw.SizedBox(height: 13),
                pw.Text(pet.name,
                    style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black)),
                pw.Text(calculateAge(pet.dateTime),
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.black)),
                pw.SizedBox(height: 7),
              ],
            ),
            pw.SizedBox(height: 40),
            pw.Row(children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Gender: ${pet.gender}",
                        style: const pw.TextStyle(
                            fontSize: 11, color: PdfColors.black)),
                    pw.Text("Breed: ${pet.breed}",
                        style: const pw.TextStyle(
                            fontSize: 11, color: PdfColors.black)),
                    pw.Text("Birth date: ${pet.age}",
                        style: const pw.TextStyle(
                            fontSize: 11, color: PdfColors.black)),
                  ]),
              pw.SizedBox(width: 20),
              pw.Container(
                width: 80,
                height: 80,
                child: pw.Image(avatar),
              ),
            ])
          ],
        ),
      ),
      build: (pw.Context context) {
        return [
          pw.Padding(
              padding: const pw.EdgeInsets.all(30),
              child: pw.Column(
                children: [
                  pw.SizedBox(height: 30),
                  pw.Text("Health Report",
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 30),
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                            "Range: ${DateFormat('dd-MM-yyyy').format(dateRange.start)} - ${DateFormat('dd-MM-yyyy').format(dateRange.end)}",
                            style: const pw.TextStyle(fontSize: 18)),
                      ]),
                  pw.SizedBox(height: 20),
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Activities",
                            style: pw.TextStyle(
                                fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      ]),
                  pw.SizedBox(height: 10),
                  pw.TableHelper.fromTextArray(
                    context: context,
                    cellAlignment: pw.Alignment.centerLeft,
                    headerDecoration:
                        pw.BoxDecoration(color: PdfColor.fromHex('#f0f9ff')),
                    headerHeight: 25,
                    cellHeight: 40,
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    cellStyle: const pw.TextStyle(color: PdfColors.black),
                    headers: <String>['', 'Metric', 'Average', 'Total'],
                    headerAlignment: pw.Alignment.centerLeft,
                    data: <List<String>>[
                      [
                        '🐾',
                        'Daily Steps',
                        averageSteps.toStringAsFixed(0),
                        totalSteps.toStringAsFixed(0)
                      ],
                      [
                        '🕒',
                        'Daily Active Minutes',
                        averageActiveMinutes.toStringAsFixed(0),
                        totalActiveMinutes.toStringAsFixed(0)
                      ],
                      [
                        '📏',
                        'Daily Distance (km)',
                        averageDistance.toStringAsFixed(0),
                        totalDistance.toStringAsFixed(0)
                      ],
                      [
                        '🔥',
                        'Calories Burned',
                        (averageSteps * 0.04).toStringAsFixed(0),
                        totalCaloriesBurned.toStringAsFixed(0)
                      ],
                    ],
                    border: null,
                  ),
                ],
              )),
        ];
      },
      footer: (pw.Context context) {
        return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            padding: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                children: [
                  pw.Divider(color: PdfColors.black),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('©2024 Pupilapp'),
                      pw.Text(
                          'Page ${context.pageNumber} of ${context.pagesCount}'),
                    ],
                  ),
                ],
              ),
            ));
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

Future<pw.ImageProvider> imageFromAssetBundle(String path) async {
  final ByteData data = await rootBundle.load(path);
  return pw.MemoryImage(
    data.buffer.asUint8List(),
  );
}

String calculateAge(DateTime birthDate) {
  final now = DateTime.now();
  final years = now.year - birthDate.year;
  final months = now.month - birthDate.month;
  final weeks = now.difference(birthDate).inDays ~/ 7;

  if (years > 0) {
    return "$years years";
  } else if (months > 0) {
    return "$months months";
  } else {
    return "$weeks weeks";
  }
}
