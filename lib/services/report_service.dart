import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/health_record.dart';

class ReportService {
  Future<void> generateAndShowReport(List<HealthRecord> records) async {
    final pdf = pw.Document();
    
    // Filter records for the last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final filteredRecords = records.where((r) => r.timestamp.isAfter(thirtyDaysAgo)).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first

    // Use a font that supports Cyrillic
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Звіт про стан здоров\'я (останні 30 днів)',
              style: pw.TextStyle(font: fontBold, fontSize: 18),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Період: ${DateFormat('dd.MM.yyyy').format(thirtyDaysAgo)} - ${DateFormat('dd.MM.yyyy').format(now)}',
            style: pw.TextStyle(font: font),
          ),
          pw.SizedBox(height: 20),
          if (filteredRecords.isEmpty)
            pw.Text('Записів за вказаний період не знайдено.', style: pw.TextStyle(font: font))
          else
            pw.TableHelper.fromTextArray(
              headers: ['Дата', 'Час', 'Період', 'Тиск (SYS/DIA)', 'Пульс', 'Цукор'],
              data: filteredRecords.map((r) {
                return [
                  DateFormat('dd.MM.yyyy').format(r.timestamp),
                  DateFormat('HH:mm').format(r.timestamp),
                  r.period == 'morning' ? 'Ранок' : 'Вечір',
                  '${r.systolic}/${r.diastolic}',
                  r.pulse.toString(),
                  r.sugar?.toStringAsFixed(1) ?? '-',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(font: fontBold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
              cellStyle: pw.TextStyle(font: font),
              cellAlignment: pw.Alignment.center,
            ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'health_report_${DateFormat('yyyyMMdd').format(now)}.pdf',
    );
  }
}
