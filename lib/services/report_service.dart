import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/health_record.dart';
import '../l10n/app_localizations.dart';

/// Returns the last 30 days of [records] sorted in descending order
/// (newest first), relative to [now].
List<HealthRecord> filterAndSortForReport(
  List<HealthRecord> records,
  DateTime now,
) {
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  return records.where((r) => r.timestamp.isAfter(thirtyDaysAgo)).toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
}

/// Formats a [HealthRecord] as a list of strings for a PDF table row.
///
/// Column order: [date, time, period, pressure, pulse, sugar]
/// - date: `dd.MM.yyyy`
/// - time: `HH:mm`
/// - period: `r.period` (raw value — caller localises if needed)
/// - pressure: `SYS/DIA`
/// - pulse: integer string
/// - sugar: `toStringAsFixed(1)` or `'-'` when null
List<String> formatRecordRow(HealthRecord r) {
  return [
    DateFormat('dd.MM.yyyy').format(r.timestamp),
    DateFormat('HH:mm').format(r.timestamp),
    r.period,
    '${r.systolic}/${r.diastolic}',
    r.pulse.toString(),
    r.sugar?.toStringAsFixed(1) ?? '-',
  ];
}

class ReportService {
  Future<void> generateAndShowReport(List<HealthRecord> records, BuildContext context) async {
    final l = AppLocalizations.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final pdf = pw.Document();

      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final filteredRecords = filterAndSortForReport(records, now);

      final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final fontBoldData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      final font = pw.Font.ttf(fontData);
      final fontBold = pw.Font.ttf(fontBoldData);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                l.reportTitle,
                style: pw.TextStyle(font: fontBold, fontSize: 18),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              l.reportPeriod(
                DateFormat('dd.MM.yyyy').format(thirtyDaysAgo),
                DateFormat('dd.MM.yyyy').format(now),
              ),
              style: pw.TextStyle(font: font),
            ),
            pw.SizedBox(height: 20),
            if (filteredRecords.isEmpty)
              pw.Text(l.reportNoRecords, style: pw.TextStyle(font: font))
            else
              pw.TableHelper.fromTextArray(
                headers: [
                  l.reportColDate,
                  l.reportColTime,
                  l.reportColPeriod,
                  l.reportColPressure,
                  l.reportColPulse,
                  l.reportColSugar,
                ],
                data: filteredRecords.map((r) {
                  final row = formatRecordRow(r);
                  // Replace raw period with localized string
                  return [
                    row[0],
                    row[1],
                    r.period == 'morning' ? l.periodMorning : l.periodEvening,
                    row[3],
                    row[4],
                    row[5],
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

      if (context.mounted) Navigator.pop(context);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'health_report_${DateFormat('yyyyMMdd').format(now)}.pdf',
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).reportErrorCreating(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
