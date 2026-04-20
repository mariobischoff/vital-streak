import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../readings/domain/blood_pressure_reading.dart';
import '../presentation/pdf_report_template.dart';

class ExportService {
  static Future<void> generateAndShare({
    required List<BloodPressureReading> readings,
    required Uint8List? chartImage,
    required double avgSys,
    required double avgDia,
  }) async {
    try {
      // 1. Gerar os bytes do PDF
      final pdfBytes = await PdfReportTemplate.generate(
        readings: readings,
        chartImage: chartImage,
        avgSys: avgSys,
        avgDia: avgDia,
      );

      // 2. Salvar em um arquivo temporário
      final directory = await getTemporaryDirectory();
      final dateStr = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/bp_report_$dateStr.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // 3. Compartilhar
      final params = ShareParams(
        subject: 'My Blood Pressure Report',
        text: 'Attached is my blood pressure monitoring report.',
        files: [XFile(filePath)],
      );

      await SharePlus.instance.share(params);
    } catch (e) {
      rethrow;
    }
  }
}
