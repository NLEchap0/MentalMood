import 'dart:io';
import 'dart:typed_data';

import 'package:application/data/repositories/emotion_repository.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

abstract class ReportFileWriter {
  Future<File> write(Uint8List bytes, String name);
}

class TempDirFileWriter implements ReportFileWriter {
  @override
  Future<File> write(Uint8List bytes, String name) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }
}

class MonthlyReportGenerator {
  MonthlyReportGenerator({
    required this._emotions,
    required this._fileWriter,
    required DateTime Function() now,
  });

  final EmotionRepository _emotions;
  final ReportFileWriter _fileWriter;

  Future<Uint8List> generate({
    required int userId,
    required int year,
    required int month,
  }) async {
    final all = await _emotions.getEmotionsForUser(userId);
    final entries = all
        .where((e) => e.createdAt.year == year && e.createdAt.month == month)
        .toList();

    final count = entries.length;
    final values = entries.map((e) => e.value).toList();
    final avg = count == 0 ? 0.0 : values.reduce((a, b) => a + b) / count;
    final min = count == 0 ? 0 : values.reduce((a, b) => a < b ? a : b);
    final max = count == 0 ? 0 : values.reduce((a, b) => a > b ? a : b);
    final low = entries.where((e) => e.value <= 3).length;
    final mid = entries.where((e) => e.value >= 4 && e.value <= 7).length;
    final high = entries.where((e) => e.value >= 8).length;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('MentalMood — Report mensile',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('$month/$year', style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 16),
            pw.Text('Entry registrate: $count'),
            pw.Text('Media umore: ${avg.toStringAsFixed(1)} (1-10)'),
            pw.Text('Minimo: $min — Massimo: $max'),
            pw.Text('Bassi (1-3): $low — Medi (4-7): $mid — Alti (8-10): $high'),
            pw.SizedBox(height: 24),
            pw.Text(
              'Questo report è generato automaticamente dai tuoi dati. '
              'Non sostituisce il parere di un professionista sanitario.',
              style: const pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
            ),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  Future<File> saveToTemp(Uint8List bytes, String name) =>
      _fileWriter.write(bytes, name);
}
