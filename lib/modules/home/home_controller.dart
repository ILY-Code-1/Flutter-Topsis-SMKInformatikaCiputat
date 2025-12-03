import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/models/siswa_model.dart';
import '../../data/models/kriteria_model.dart';
import '../../data/services/excel_service.dart';
import '../../data/services/topsis_service.dart';
import '../../data/services/riwayat_service.dart';
import '../../app/routes/app_routes.dart';

class HomeController extends GetxController {
  final ExcelService _excelService = Get.find<ExcelService>();
  final TopsisService _topsisService = Get.find<TopsisService>();
  final RiwayatService _riwayatService = Get.find<RiwayatService>();

  final RxBool isLoading = false.obs;
  final RxBool isHovering = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedFileName = ''.obs;

  final RxList<SiswaModel> siswaList = <SiswaModel>[].obs;
  final RxList<KriteriaModel> kriteriaList = <KriteriaModel>[].obs;
  final RxList<SiswaModel> hasilRanking = <SiswaModel>[].obs;

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

    _riwayatService.tambahRiwayat(
      namaFile: fileName,
      hasil: hasilRanking.toList(),
      kriteria: kriteriaList.toList(),
    );

    Get.toNamed(AppRoutes.hasil);
  }

  void goToRiwayat() {
    Get.toNamed(AppRoutes.riwayat);
  }
}
