import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../models/siswa_model.dart';
import '../models/kriteria_model.dart';

class ExcelService {
  List<SiswaModel> parseExcelData(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final List<SiswaModel> siswaList = [];

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null || sheet.rows.isEmpty) continue;

      final headers = <String>[];
      final headerRow = sheet.rows.first;
      for (var cell in headerRow) {
        headers.add(cell?.value?.toString() ?? '');
      }

      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        final Map<String, dynamic> rowData = {};

        for (int j = 0; j < headers.length && j < row.length; j++) {
          final cell = row[j];
          if (cell != null && cell.value != null) {
            final cellValue = cell.value;
            if (cellValue is IntCellValue) {
              rowData[headers[j]] = cellValue.value.toDouble();
            } else if (cellValue is DoubleCellValue) {
              rowData[headers[j]] = cellValue.value;
            } else if (cellValue is TextCellValue) {
              final parsed = double.tryParse(cellValue.value.toString());
              rowData[headers[j]] = parsed ?? cellValue.value.toString();
            } else {
              rowData[headers[j]] = cellValue.toString();
            }
          }
        }

        if (rowData.isNotEmpty) {
          siswaList.add(SiswaModel.fromMap(rowData));
        }
      }
      break;
    }

    return siswaList;
  }

  List<KriteriaModel> extractKriteria(List<SiswaModel> siswaList) {
    if (siswaList.isEmpty) return [];

    final kriteriaNama = siswaList.first.nilai.keys.toList();

    // Bobot yang sudah ditentukan
    const Map<String, double> bobotKriteria = {
      'rata_rata_nilai_produktif': 0.35,
      'nilai_sikap': 0.30,
      'jumlah_absen': 0.20,
      'rata_rata_nilai_raport': 0.15,
    };

    return kriteriaNama.map((nama) {
      // jumlah_absen adalah cost (semakin kecil semakin baik)
      // sisanya benefit (semakin besar semakin baik)
      final lowerNama = nama.toLowerCase();
      final isCost = lowerNama == 'jumlah_absen';
      
      // Ambil bobot dari map, default ke rata jika tidak ditemukan
      final bobot = bobotKriteria[lowerNama] ?? (1.0 / kriteriaNama.length);
      
      return KriteriaModel(
        nama: nama,
        bobot: bobot,
        type: isCost ? KriteriaType.cost : KriteriaType.benefit,
      );
    }).toList();
  }

  List<String> getHeaders(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final headers = <String>[];

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null || sheet.rows.isEmpty) continue;

      final headerRow = sheet.rows.first;
      for (var cell in headerRow) {
        final value = cell?.value?.toString() ?? '';
        if (value.isNotEmpty) {
          headers.add(value);
        }
      }
      break;
    }

    return headers;
  }
}
