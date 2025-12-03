import 'siswa_model.dart';
import 'kriteria_model.dart';

class RiwayatModel {
  final String id;
  final DateTime tanggal;
  final String namaFile;
  final List<SiswaModel> hasil;
  final List<KriteriaModel> kriteria;
  final int jumlahSiswa;

  RiwayatModel({
    required this.id,
    required this.tanggal,
    required this.namaFile,
    required this.hasil,
    required this.kriteria,
    required this.jumlahSiswa,
  });

  factory RiwayatModel.fromMap(Map<String, dynamic> map) {
    return RiwayatModel(
      id: map['id'] ?? '',
      tanggal: DateTime.parse(map['tanggal']),
      namaFile: map['namaFile'] ?? '',
      hasil: (map['hasil'] as List?)
              ?.map((e) => SiswaModel.fromMap(e))
              .toList() ??
          [],
      kriteria: (map['kriteria'] as List?)
              ?.map((e) => KriteriaModel.fromMap(e))
              .toList() ??
          [],
      jumlahSiswa: map['jumlahSiswa'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String(),
      'namaFile': namaFile,
      'hasil': hasil.map((e) => e.toMap()).toList(),
      'kriteria': kriteria.map((e) => e.toMap()).toList(),
      'jumlahSiswa': jumlahSiswa,
    };
  }

  @override
  String toString() {
    return 'RiwayatModel(id: $id, tanggal: $tanggal, namaFile: $namaFile, jumlahSiswa: $jumlahSiswa)';
  }
}
