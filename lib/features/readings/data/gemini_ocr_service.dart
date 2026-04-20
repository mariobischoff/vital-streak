import 'dart:io';
import 'package:image/image.dart' as img;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../domain/blood_pressure_logic.dart';

class GeminiOcrService {
  static final _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  late final GenerativeModel _model;

  GeminiOcrService() {
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  /// Sends a photo to Gemini Vision and extracts SYS/DIA values.
  Future<({int systolic, int diastolic})?> processPhotoFile(
    String photoPath,
  ) async {
    try {
      final File photoFile = File(photoPath);
      final Uint8List rawBytes = await photoFile.readAsBytes();

      // Optimization: Downscale image to save API tokens and bandwidth
      final img.Image? originalImage = img.decodeImage(rawBytes);
      if (originalImage == null) throw Exception('Failed to decode image');

      // Resize to max 800px width/height keeping aspect ratio
      final img.Image resizedImage = img.copyResize(originalImage, width: 800);

      // Compress to JPEG with 70% quality
      final Uint8List photoBytes = img.encodeJpg(resizedImage, quality: 70);
      final mimeType = 'image/jpeg';

      debugPrint(
        'Sending optimized photo to Gemini (${photoBytes.length} bytes, Mime: $mimeType)...',
      );

      final prompt = TextPart(
        'This photo shows the display of a digital blood pressure monitor. '
        'Read the values displayed on the 7-segment LCD display. '
        'Answer ONLY in the format: SYS=XXX DIA=XXX '
        'where XXX are the numbers that appear on the display. '
        'If you cannot read it, answer: ERROR',
      );

      final imagePart = DataPart(mimeType, photoBytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      final text = response.text ?? '';
      debugPrint('Gemini response: "$text"');

      // Parse response: "SYS=128 DIA=87"
      final sysMatch = RegExp(r'SYS\s*=\s*(\d{2,3})').firstMatch(text);
      final diaMatch = RegExp(r'DIA\s*=\s*(\d{2,3})').firstMatch(text);

      if (sysMatch != null && diaMatch != null) {
        final sys = int.parse(sysMatch.group(1)!);
        final dia = int.parse(diaMatch.group(1)!);

        debugPrint('Parsed: SYS=$sys, DIA=$dia');

        if (BloodPressureLogic.validate(sys, dia)) {
          return (systolic: sys, diastolic: dia);
        }
        if (BloodPressureLogic.validate(dia, sys)) {
          return (systolic: dia, diastolic: sys);
        }
      }

      // Fallback: try to find any 2-3 digit numbers
      final numbers = RegExp(
        r'\d{2,3}',
      ).allMatches(text).map((m) => int.parse(m.group(0)!)).toList();

      debugPrint('Fallback numbers: $numbers');

      for (int i = 0; i < numbers.length - 1; i++) {
        for (int j = i + 1; j < numbers.length; j++) {
          if (BloodPressureLogic.validate(numbers[i], numbers[j])) {
            return (systolic: numbers[i], diastolic: numbers[j]);
          }
        }
      }

      // If we reach here, we couldn't parse valid values.
      debugPrint('Could not find valid SYS/DIA readings in the image.');
      return null;
    } on GenerativeAIException catch (e) {
      debugPrint('Gemini GenerativeAIException: $e');
      throw 'The API blocked or failed to generate the response.';
    } catch (e, stack) {
      debugPrint('Gemini processing error: $e\n$stack');
      throw 'Failed to interpret the image. Try a clearer photo.';
    }
  }
}
