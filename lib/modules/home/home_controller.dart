import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/siswa_model.dart';
import '../../data/models/kriteria_model.dart';
import '../../data/models/riwayat_model.dart';
import '../../data/services/excel_service.dart';
import '../../data/services/topsis_service.dart';
import '../../data/services/riwayat_service.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/pdf_service.dart';
import '../../core/utils/key_generator.dart';
import '../../app/routes/app_routes.dart';

class HomeController extends GetxController {
  final ExcelService _excelService = Get.find<ExcelService>();
  final TopsisService _topsisService = Get.find<TopsisService>();
  final RiwayatService _riwayatService = Get.find<RiwayatService>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final PdfService _pdfService = Get.find<PdfService>();

  final RxBool isLoading = false.obs;
  final RxBool isHovering = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedFileName = ''.obs;

  final RxList<SiswaModel> siswaList = <SiswaModel>[].obs;
  final RxList<KriteriaModel> kriteriaList = <KriteriaModel>[].obs;
  final RxList<SiswaModel> hasilRanking = <SiswaModel>[].obs;

  static const String templateUrl =
      'https://docs.google.com/spreadsheets/d/1QTIMbzbIjIcbkFdEf2NRKYbo9qQ2cie5/export?format=xlsx';

  void setHovering(bool value) {
    isHovering.value = value;
  }

  Future<void> pickFile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          selectedFileName.value = file.name;
          await processFile(file.bytes!, file.name);
        }
      }
    } catch (e) {
      errorMessage.value = 'Gagal memilih file: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processDroppedFile(Uint8List bytes, String fileName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      selectedFileName.value = fileName;
      await processFile(bytes, fileName);
    } catch (e) {
      errorMessage.value = 'Gagal memproses file: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processFile(Uint8List bytes, String fileName) async {
    siswaList.value = _excelService.parseExcelData(bytes);

    if (siswaList.isEmpty) {
      errorMessage.value = 'File tidak mengandung data siswa yang valid';
      return;
    }

    kriteriaList.value = _excelService.extractKriteria(siswaList);

    if (kriteriaList.isEmpty) {
      errorMessage.value = 'Tidak dapat menemukan kriteria dari data';
      return;
    }

    hasilRanking.value = _topsisService.hitungTopsis(
      siswaList.toList(),
      kriteriaList.toList(),
    );

    // Simpan ke Firebase dan dapatkan key
    String? generatedKey;
    try {
      generatedKey = await _firebaseService.simpanHasil(
        namaFile: fileName,
        hasil: hasilRanking.toList(),
        kriteria: kriteriaList.toList(),
      );
    } catch (e) {
      // Jika Firebase gagal, tetap lanjut tanpa key
      debugPrint('Firebase error: $e');
    }

    // Simpan juga ke local (RiwayatService) - untuk backward compatibility
    _riwayatService.tambahRiwayat(
      namaFile: fileName,
      hasil: hasilRanking.toList(),
      kriteria: kriteriaList.toList(),
    );

    // Navigate ke hasil dengan key
    Get.toNamed(AppRoutes.hasil, arguments: {
      'hasil': hasilRanking.toList(),
      'kriteria': kriteriaList.toList(),
      'namaFile': fileName,
      'key': generatedKey,
    });
  }

  void goToRiwayat() {
    Get.toNamed(AppRoutes.riwayat);
  }

  /// Buka link download template Excel
  Future<void> downloadTemplate() async {
    final uri = Uri.parse(templateUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      errorMessage.value = 'Tidak dapat membuka link template';
    }
  }

  // ==================== TESTING FUNCTIONS ====================

  /// Test 1: KeyGenerator
  void testKeyGenerator() {
    final key1 = KeyGenerator.generate();
    final key2 = KeyGenerator.generate();

    Get.dialog(
      AlertDialog(
        title: const Text('Test KeyGenerator'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Key 1: $key1'),
            Text('Key 2: $key2'),
            const Divider(),
            Text(
              'Valid "TOPSIS-ABC123": ${KeyGenerator.isValidKey("TOPSIS-ABC123")}',
            ),
            Text(
              'Valid "TOPSIS-abc123": ${KeyGenerator.isValidKey("TOPSIS-abc123")}',
            ),
            Text('Valid "ABC123": ${KeyGenerator.isValidKey("ABC123")}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  /// Test 2: FirebaseService
  Future<void> testFirebaseService() async {
    try {
      Get.dialog(
        const AlertDialog(
          title: Text('Testing Firebase...'),
          content: SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
        barrierDismissible: false,
      );

      // Data dummy sesuai kolom Excel dengan bobot yang ditentukan
      final kriteria = [
        KriteriaModel(
          nama: 'rata_rata_nilai_produktif',
          bobot: 0.35,
          type: KriteriaType.benefit,
        ),
        KriteriaModel(
          nama: 'nilai_sikap',
          bobot: 0.30,
          type: KriteriaType.benefit,
        ),
        KriteriaModel(
          nama: 'jumlah_absen',
          bobot: 0.20,
          type: KriteriaType.cost,
        ),
        KriteriaModel(
          nama: 'rata_rata_nilai_raport',
          bobot: 0.15,
          type: KriteriaType.benefit,
        ),
      ];

      final hasil = [
        SiswaModel(
            id: '1',
            nama: 'Budi Santoso',
            kelas: 'XII-RPL-1',
            nilai: {
              'rata_rata_nilai_raport': 85.5,
              'rata_rata_nilai_produktif': 88.0,
              'nilai_sikap': 90.0,
              'jumlah_absen': 2.0,
            },
          )
          ..skorTopsis = 0.8921
          ..ranking = 1,
        SiswaModel(
            id: '2',
            nama: 'Ani Wijaya',
            kelas: 'XII-RPL-2',
            nilai: {
              'rata_rata_nilai_raport': 82.0,
              'rata_rata_nilai_produktif': 90.0,
              'nilai_sikap': 85.0,
              'jumlah_absen': 5.0,
            },
          )
          ..skorTopsis = 0.7854
          ..ranking = 2,
      ];

      // Simpan ke Firebase
      final key = await _firebaseService.simpanHasil(
        namaFile: 'test_data.xlsx',
        hasil: hasil,
        kriteria: kriteria,
      );

      // Ambil kembali
      final fetched = await _firebaseService.getHasilByKey(key);

      Get.back(); // Close loading dialog

      Get.dialog(
        AlertDialog(
          title: const Text('Test Firebase - Berhasil!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key tersimpan: $key'),
              const Divider(),
              Text('Nama file: ${fetched?.namaFile}'),
              Text('Jumlah siswa: ${fetched?.jumlahSiswa}'),
              Text('Jumlah kriteria: ${fetched?.kriteria.length}'),
              const SizedBox(height: 10),
              const Text(
                'Cek Firebase Console untuk verifikasi data.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _firebaseService.hapusRiwayat(key);
                Get.back();
                Get.snackbar('Berhasil', 'Data test dihapus dari Firebase');
              },
              child: const Text('Hapus Data Test'),
            ),
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
      );
    } catch (e) {
      Get.back();
      Get.dialog(
        AlertDialog(
          title: const Text('Test Firebase - Gagal'),
          content: Text('Error: $e'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  /// Test 3: PdfService
  Future<void> testPdfService() async {
    try {
      // Data dummy
      final riwayat = RiwayatModel(
        id: 'TOPSIS-TEST01',
        tanggal: DateTime.now(),
        namaFile: 'test_data.xlsx',
        jumlahSiswa: 2,
        kriteria: [
          KriteriaModel(
            nama: 'rata_rata_nilai_produktif',
            bobot: 0.35,
            type: KriteriaType.benefit,
          ),
          KriteriaModel(
            nama: 'nilai_sikap',
            bobot: 0.30,
            type: KriteriaType.benefit,
          ),
          KriteriaModel(
            nama: 'jumlah_absen',
            bobot: 0.20,
            type: KriteriaType.cost,
          ),
          KriteriaModel(
            nama: 'rata_rata_nilai_raport',
            bobot: 0.15,
            type: KriteriaType.benefit,
          ),
        ],
        hasil: [
          SiswaModel(
              id: '1',
              nama: 'Budi Santoso',
              kelas: 'XII-RPL-1',
              nilai: {
                'rata_rata_nilai_raport': 85.5,
                'rata_rata_nilai_produktif': 88.0,
                'nilai_sikap': 90.0,
                'jumlah_absen': 2.0,
              },
            )
            ..skorTopsis = 0.8921
            ..ranking = 1,
          SiswaModel(
              id: '2',
              nama: 'Ani Wijaya',
              kelas: 'XII-RPL-2',
              nilai: {
                'rata_rata_nilai_raport': 82.0,
                'rata_rata_nilai_produktif': 90.0,
                'nilai_sikap': 85.0,
                'jumlah_absen': 5.0,
              },
            )
            ..skorTopsis = 0.7854
            ..ranking = 2,
        ],
      );

      await _pdfService.generateAndPrintPdf(riwayat);
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('Test PDF - Gagal'),
          content: Text('Error: $e'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
      );
    }
  }
}
