import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/models/siswa_model.dart';
import '../../data/models/kriteria_model.dart';
import '../../data/models/riwayat_model.dart';
import '../../data/services/riwayat_service.dart';
import '../../data/services/pdf_service.dart';
import '../../app/routes/app_routes.dart';

class HasilController extends GetxController {
  final RiwayatService _riwayatService = Get.find<RiwayatService>();
  final PdfService _pdfService = Get.find<PdfService>();

  final RxList<SiswaModel> hasilRanking = <SiswaModel>[].obs;
  final RxList<KriteriaModel> kriteriaList = <KriteriaModel>[].obs;
  final RxString namaFile = ''.obs;
  final RxString generatedKey = ''.obs;
  final RxBool isFromRiwayat = false.obs;
  final Rx<DateTime> tanggal = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    final args = Get.arguments;

    if (args != null && args is Map<String, dynamic>) {
      if (args['riwayatId'] != null) {
        // Dari halaman riwayat (local)
        isFromRiwayat.value = true;
        final riwayat = _riwayatService.getRiwayatById(args['riwayatId']);
        if (riwayat != null) {
          hasilRanking.value = riwayat.hasil;
          kriteriaList.value = riwayat.kriteria;
          namaFile.value = riwayat.namaFile;
          generatedKey.value = riwayat.id;
          tanggal.value = riwayat.tanggal;
        }
      } else if (args['riwayatModel'] != null) {
        // Dari Firebase (RiwayatModel langsung)
        isFromRiwayat.value = true;
        final riwayat = args['riwayatModel'] as RiwayatModel;
        hasilRanking.value = riwayat.hasil;
        kriteriaList.value = riwayat.kriteria;
        namaFile.value = riwayat.namaFile;
        generatedKey.value = riwayat.id;
        tanggal.value = riwayat.tanggal;
      } else {
        // Dari proses upload baru
        hasilRanking.value = List<SiswaModel>.from(args['hasil'] ?? []);
        kriteriaList.value = List<KriteriaModel>.from(args['kriteria'] ?? []);
        namaFile.value = args['namaFile'] ?? '';
        generatedKey.value = args['key'] ?? '';
        tanggal.value = DateTime.now();
      }
    } else {
      final riwayatList = _riwayatService.riwayatList;
      if (riwayatList.isNotEmpty) {
        final latest = riwayatList.first;
        hasilRanking.value = latest.hasil;
        kriteriaList.value = latest.kriteria;
        namaFile.value = latest.namaFile;
        generatedKey.value = latest.id;
        tanggal.value = latest.tanggal;
      }
    }
  }

  void goBack() {
    if (isFromRiwayat.value) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void goToRiwayat() {
    Get.toNamed(AppRoutes.riwayat);
  }

  void uploadNewFile() {
    Get.offAllNamed(AppRoutes.home);
  }

  String getRankingBadgeColor(int ranking) {
    if (ranking == 1) return 'gold';
    if (ranking == 2) return 'silver';
    if (ranking == 3) return 'bronze';
    return 'default';
  }

  /// Copy key ke clipboard
  void copyKeyToClipboard() {
    if (generatedKey.value.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: generatedKey.value));
      Get.snackbar(
        'Berhasil',
        'Key berhasil disalin: ${generatedKey.value}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Download PDF hasil ranking
  Future<void> downloadPdf() async {
    try {
      print(generatedKey.value);
      print("===============================");
      print(tanggal.value);
      print("===============================");
      print(namaFile.value);
      print("===============================");
      print(hasilRanking.length);
      print("===============================");
      print(kriteriaList.toList().toString());
      print("===============================");
      print(hasilRanking.toList().toString());

      final riwayat = RiwayatModel(
        id: generatedKey.value.isNotEmpty ? generatedKey.value : 'TOPSIS-LOCAL',
        tanggal: tanggal.value,
        namaFile: namaFile.value,
        jumlahSiswa: hasilRanking.length,
        kriteria: kriteriaList.toList(),
        hasil: hasilRanking.toList(),
      );

      await _pdfService.generateAndPrintPdf(riwayat);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuat PDF: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
