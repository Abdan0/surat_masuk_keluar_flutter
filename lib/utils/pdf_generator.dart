import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:surat_masuk_keluar_flutter/data/models/agenda.dart';

class PdfGenerator {
  // Generate PDF for Agenda Surat Masuk
  static Future<File> generateAgendaSuratMasukPdf(
    List<Agenda> agendaList, 
    {String? startDate, String? endDate}
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'BUKU AGENDA SURAT MASUK',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            
            pw.Center(
              child: pw.Text(
                startDate != null && endDate != null
                    ? 'Periode: $startDate - $endDate'
                    : 'Semua Periode',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              headers: ['No.', 'Nomor Agenda', 'Nomor Surat', 'Pengirim', 'Tanggal'],
              data: List<List<String>>.generate(
                agendaList.length,
                (index) => [
                  (index + 1).toString(),
                  agendaList[index].nomorAgenda,
                  agendaList[index].surat?.nomorSurat ?? '-',
                  agendaList[index].surat?.asalSurat ?? agendaList[index].pengirim ?? '-',
                  DateFormat('dd/MM/yyyy').format(agendaList[index].tanggalAgenda),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.bottomRight,
              child: pw.Text(
                'Dicetak pada: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/agenda_surat_masuk.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Generate PDF for Agenda Surat Keluar
  static Future<File> generateAgendaSuratKeluarPdf(
    List<Agenda> agendaList, 
    {String? startDate, String? endDate}
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'BUKU AGENDA SURAT KELUAR',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            
            pw.Center(
              child: pw.Text(
                startDate != null && endDate != null
                    ? 'Periode: $startDate - $endDate'
                    : 'Semua Periode',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              headers: ['No.', 'Nomor Agenda', 'Nomor Surat', 'Tujuan', 'Tanggal'],
              data: List<List<String>>.generate(
                agendaList.length,
                (index) => [
                  (index + 1).toString(),
                  agendaList[index].nomorAgenda,
                  agendaList[index].surat?.nomorSurat ?? '-',
                  agendaList[index].surat?.tujuanSurat ?? agendaList[index].penerima ?? '-',
                  DateFormat('dd/MM/yyyy').format(agendaList[index].tanggalAgenda),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.bottomRight,
              child: pw.Text(
                'Dicetak pada: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/agenda_surat_keluar.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Open PDF file
  static Future<void> openPdf(File file) async {
    try {
      await OpenFile.open(file.path);
    } catch (e) {
      throw Exception('Error opening PDF: $e');
    }
  }
}