import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';

Future<void> generateVetVisitReport(
    WidgetRef ref, String petId, DateTime visitDate) async {
  final pdf = pw.Document();

  // Pobieranie wydarzenia (wizyty) z bazy danych
  final event = await ref.read(eventServiceProvider).getEventById(petId);

  if (event == null) {
    return; // Jeśli event jest null, zakończ generowanie raportu
  }

  final description = event.description as Map<String, dynamic>;

  final visitReason = description['visitReason'] ?? '';
  final symptoms = (description['symptoms'] ?? []).join(', ');
  final vaccines = (description['vaccines'] ?? []).join(', ');
  final followUpRequired = description['followUpRequired'] ?? false;
  final followUpDate = description['followUpDate'] != null
      ? DateFormat('dd-MM-yyyy')
          .format(DateTime.parse(description['followUpDate']))
      : '';
  final notes = description['notes'] ?? '';

  // Zakładając, że avatar jest przechowywany w zasobach aplikacji
  final avatar = await imageFromAssetBundle('assets/images/pet_avatar.png');

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
                pw.Text(event.petId,
                    style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black)),
                pw.Text(calculateAge(event.eventDate),
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
                    pw.Text(
                        "Date: ${DateFormat('dd-MM-yyyy').format(visitDate)}",
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
                  pw.Text("Vet Visit Report",
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 30),
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                            "Date: ${DateFormat('dd-MM-yyyy').format(visitDate)}",
                            style: const pw.TextStyle(fontSize: 18)),
                      ]),
                  pw.SizedBox(height: 20),
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Summary",
                            style: pw.TextStyle(
                                fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      ]),
                  pw.SizedBox(height: 10),
                  pw.Text("Reason: $visitReason",
                      style: const pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 10),
                  if (symptoms.isNotEmpty)
                    pw.Text("Symptoms: $symptoms",
                        style: const pw.TextStyle(fontSize: 16)),
                  if (vaccines.isNotEmpty)
                    pw.Text("Vaccines: $vaccines",
                        style: const pw.TextStyle(fontSize: 16)),
                  if (followUpRequired && followUpDate.isNotEmpty)
                    pw.Text("Follow-up Visit: $followUpDate",
                        style: const pw.TextStyle(fontSize: 16)),
                  if (notes.isNotEmpty)
                    pw.Text("Notes: $notes",
                        style: const pw.TextStyle(fontSize: 16)),
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
