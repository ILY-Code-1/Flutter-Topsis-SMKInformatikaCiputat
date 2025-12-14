import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/riwayat_model.dart';

class PdfService extends GetxService {
  /// Generate dan print/download PDF hasil ranking TOPSIS
  Future<void> generateAndPrintPdf(RiwayatModel riwayat) async {
    final pdf = _buildPdfDocument(riwayat);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Hasil_TOPSIS_${riwayat.id}.pdf',
    );
  }

  /// Generate PDF dan return bytes (untuk download langsung)
  Future<List<int>> generatePdfBytes(RiwayatModel riwayat) async {
    final pdf = _buildPdfDocument(riwayat);
    return pdf.save();
  }

  /// Share PDF
  Future<void> sharePdf(RiwayatModel riwayat) async {
    final pdf = _buildPdfDocument(riwayat);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Hasil_TOPSIS_${riwayat.id}.pdf',
    );
  }

  pw.Document _buildPdfDocument(RiwayatModel riwayat) {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        maxPages: 100,
        header: (context) => _buildHeader(riwayat, dateFormat),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Halaman ${context.pageNumber} dari ${context.pagesCount} | Key: ${riwayat.id}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 10),
          _buildInfoSection(riwayat),
          pw.SizedBox(height: 20),
          _buildKriteriaTable(riwayat),
          pw.SizedBox(height: 20),
          ..._buildHasilTablePaginated(riwayat),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _buildHeader(RiwayatModel riwayat, DateFormat dateFormat) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text(
            'HASIL PERANKINGAN TOPSIS',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Center(
          child: pw.Text(
            'SMK Informatika Ciputat',
            style: const pw.TextStyle(fontSize: 14),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2),
      ],
    );
  }

  pw.Widget _buildInfoSection(RiwayatModel riwayat) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Key', riwayat.id),
          _buildInfoRow('File', riwayat.namaFile),
          _buildInfoRow('Tanggal', dateFormat.format(riwayat.tanggal)),
          _buildInfoRow('Jumlah Siswa', '${riwayat.jumlahSiswa} siswa'),
          _buildInfoRow('Jumlah Kriteria', '${riwayat.kriteria.length} kriteria'),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text('$label:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  pw.Widget _buildKriteriaTable(RiwayatModel riwayat) {
    if (riwayat.kriteria.isEmpty) {
      return pw.Container();
    }
    
    final kriteriaData = riwayat.kriteria.map((k) {
      return [
        k.nama,
        '${(k.bobot * 100).toStringAsFixed(1)}%',
        k.type.name.toUpperCase(),
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Kriteria Penilaian',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellHeight: 25,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.center,
          },
          headers: ['Kriteria', 'Bobot', 'Tipe'],
          data: kriteriaData,
        ),
      ],
    );
  }

  List<pw.Widget> _buildHasilTablePaginated(RiwayatModel riwayat) {
    if (riwayat.hasil.isEmpty) {
      return [pw.Container()];
    }

    final headerStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10);
    const cellStyle = pw.TextStyle(fontSize: 9);
    
    final columnWidths = {
      0: const pw.FlexColumnWidth(1),
      1: const pw.FlexColumnWidth(4),
      2: const pw.FlexColumnWidth(1.5),
      3: const pw.FlexColumnWidth(2),
    };
    
    pw.Widget buildCell(String text, pw.Alignment alignment, {bool isHeader = false}) {
      return pw.Container(
        alignment: alignment,
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: pw.Text(text, style: isHeader ? headerStyle : cellStyle),
      );
    }

    pw.Widget buildHeaderRow() {
      return pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey400),
        columnWidths: columnWidths,
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              buildCell('Rank', pw.Alignment.center, isHeader: true),
              buildCell('Nama Siswa', pw.Alignment.centerLeft, isHeader: true),
              buildCell('Kelas', pw.Alignment.center, isHeader: true),
              buildCell('Skor TOPSIS', pw.Alignment.center, isHeader: true),
            ],
          ),
        ],
      );
    }

    pw.Widget buildDataRow(int index) {
      final s = riwayat.hasil[index];
      return pw.Table(
        border: pw.TableBorder(
          left: const pw.BorderSide(color: PdfColors.grey400),
          right: const pw.BorderSide(color: PdfColors.grey400),
          bottom: const pw.BorderSide(color: PdfColors.grey400),
          top: index == 0 ? pw.BorderSide.none : pw.BorderSide.none,
          horizontalInside: pw.BorderSide.none,
          verticalInside: const pw.BorderSide(color: PdfColors.grey400),
        ),
        columnWidths: columnWidths,
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index % 2 == 0 ? PdfColors.white : PdfColors.grey100,
            ),
            children: [
              buildCell('${s.ranking ?? "-"}', pw.Alignment.center),
              buildCell(s.nama, pw.Alignment.centerLeft),
              buildCell(s.kelas, pw.Alignment.center),
              buildCell(s.skorTopsis?.toStringAsFixed(6) ?? '-', pw.Alignment.center),
            ],
          ),
        ],
      );
    }

    return [
      pw.Text(
        'Hasil Perankingan',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 5),
      buildHeaderRow(),
      for (int i = 0; i < riwayat.hasil.length; i++) buildDataRow(i),
    ];
  }
}
