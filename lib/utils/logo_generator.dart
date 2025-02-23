import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LogoGenerator {
  static Future<void> generateLogos() async {
    if (kIsWeb) {
      print('Skipping logo generation on web platform');
      return;
    }

    try {
      // Create web icons directory
      final webIconsDir = Directory('web/icons');
      if (!await webIconsDir.exists()) {
        await webIconsDir.create(recursive: true);
      }

      // Generate simple circular icons
      await _generateSimpleIcon(192);
      await _generateSimpleIcon(512);
      
      // Copy 192 icon as favicon
      await File('web/icons/Icon-192.png').copy('web/favicon.png');
      
      print('Icons generated successfully');
    } catch (e) {
      print('Error generating icons: $e');
    }
  }

  static Future<void> _generateSimpleIcon(double size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;

    // Draw blue circle background
    final bgPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw plate
    final platePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final platePath = Path()
      ..moveTo(size * 0.2, size * 0.6)
      ..quadraticBezierTo(
        size * 0.5,
        size * 0.8,
        size * 0.8,
        size * 0.6,
      )
      ..lineTo(size * 0.7, size * 0.5)
      ..quadraticBezierTo(
        size * 0.5,
        size * 0.7,
        size * 0.3,
        size * 0.5,
      )
      ..close();

    // Draw house
    final housePath = Path()
      ..moveTo(size * 0.5, size * 0.2)
      ..lineTo(size * 0.7, size * 0.4)
      ..lineTo(size * 0.7, size * 0.5)
      ..lineTo(size * 0.3, size * 0.5)
      ..lineTo(size * 0.3, size * 0.4)
      ..close();

    canvas.drawPath(platePath, platePaint);
    canvas.drawPath(housePath, platePaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    await File('web/icons/Icon-${size.toInt()}.png').writeAsBytes(pngBytes);
  }
} 