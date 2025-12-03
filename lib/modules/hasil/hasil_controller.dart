import 'package:get/get.dart';
import '../../data/models/siswa_model.dart';
import '../../data/models/kriteria_model.dart';
import '../../data/services/riwayat_service.dart';
import '../../app/routes/app_routes.dart';

class HasilController extends GetxController {
  final RiwayatService _riwayatService = Get.find<RiwayatService>();

  final RxList<SiswaModel> hasilRanking = <SiswaModel>[].obs;
  final RxList<KriteriaModel> kriteriaList = <KriteriaModel>[].obs;
  final RxString namaFile = ''.obs;
  final RxBool isFromRiwayat = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    final args = Get.arguments;
    
    if (args != null && args is Map<String, dynamic>) {
      if (args['riwayatId'] != null) {
        isFromRiwayat.value = true;
        final riwayat = _riwayatService.getRiwayatById(args['riwayatId']);
        if (riwayat != null) {
          hasilRanking.value = riwayat.hasil;
          kriteriaList.value = riwayat.kriteria;
          namaFile.value = riwayat.namaFile;
        }
      } else {
        hasilRanking.value = List<SiswaModel>.from(args['hasil'] ?? []);
        kriteriaList.value = List<KriteriaModel>.from(args['kriteria'] ?? []);
        namaFile.value = args['namaFile'] ?? '';
      }
    } else {
      final riwayatList = _riwayatService.riwayatList;
      if (riwayatList.isNotEmpty) {
        final latest = riwayatList.first;
        hasilRanking.value = latest.hasil;
        kriteriaList.value = latest.kriteria;
        namaFile.value = latest.namaFile;
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
}
