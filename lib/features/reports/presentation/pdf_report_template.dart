import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../readings/domain/blood_pressure_reading.dart';
import '../../readings/domain/blood_pressure_logic.dart';

class PdfReportTemplate {
  static Future<Uint8List> generate({
    required List<BloodPressureReading> readings,
    required Uint8List? chartImage,
    required double avgSys,
    required double avgDia,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 20),
          _buildSummary(readings.length, avgSys, avgDia),
          pw.SizedBox(height: 20),
          if (chartImage != null) _buildChartSection(chartImage),
          pw.SizedBox(height: 20),
          _buildTable(readings, dateFormat),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Blood Pressure Monitoring Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Generated on: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
              style: const pw.TextStyle(color: PdfColors.grey),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummary(int count, double avgSys, double avgDia) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Readings', count.toString()),
          _buildSummaryItem('Average Systolic', '${avgSys.toInt()} mmHg'),
          _buildSummaryItem('Average Diastolic', '${avgDia.toInt()} mmHg'),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildChartSection(Uint8List imageBytes) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Trend Highlights', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Container(
          height: 200,
          child: pw.Center(
            child: pw.Image(pw.MemoryImage(imageBytes), fit: pw.BoxFit.contain),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTable(List<BloodPressureReading> readings, DateFormat df) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellAlignment: pw.Alignment.centerLeft,
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      headers: ['Date/Time', 'Systolic', 'Diastolic', 'Status'],
      data: readings.map((r) {
        final cat = BloodPressureLogic.classify(r.systolic, r.diastolic);
        return [
          df.format(r.measuredAt.toLocal()),
          '${r.systolic} mmHg',
          '${r.diastolic} mmHg',
          cat.label,
        ];
      }).toList(),
    );
  }
}
