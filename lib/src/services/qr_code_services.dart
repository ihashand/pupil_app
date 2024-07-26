import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class QrCodeService {
  Future<String> generateQrCode(String email) async {
    final qrValidationResult = QrValidator.validate(
      data: email,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
        // ignore: deprecated_member_use
        color: const Color(0xFF000000),
        gapless: true,
      );
      final image = await painter.toImage(200);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();
      return base64Encode(buffer);
    } else {
      throw Exception('QR Code generation failed');
    }
  }
}
