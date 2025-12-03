import 'package:get/get.dart';
import '../models/riwayat_model.dart';
import '../models/siswa_model.dart';
import '../models/kriteria_model.dart';

class RiwayatService extends GetxService {
  final RxList<RiwayatModel> _riwayatList = <RiwayatModel>[].obs;

  List<RiwayatModel> get riwayatList => _riwayatList;

  void tambahRiwayat({
    required String namaFile,
    required List<SiswaModel> hasil,
    required List<KriteriaModel> kriteria,
  }) {
    final riwayat = RiwayatModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tanggal: DateTime.now(),
      namaFile: namaFile,
      hasil: hasil,
      kriteria: kriteria,
      jumlahSiswa: hasil.length,
    );

    _riwayatList.insert(0, riwayat);
  }

  RiwayatModel? getRiwayatById(String id) {
    try {
      return _riwayatList.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  void hapusRiwayat(String id) {
    _riwayatList.removeWhere((r) => r.id == id);
  }

  void clearAllRiwayat() {
    _riwayatList.clear();
  }
}
