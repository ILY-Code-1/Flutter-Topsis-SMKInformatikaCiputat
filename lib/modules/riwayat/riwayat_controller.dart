import 'package:get/get.dart';
import '../../data/models/riwayat_model.dart';
import '../../data/services/riwayat_service.dart';
import '../../app/routes/app_routes.dart';

class RiwayatController extends GetxController {
  final RiwayatService _riwayatService = Get.find<RiwayatService>();

  List<RiwayatModel> get riwayatList => _riwayatService.riwayatList;

  void lihatDetail(String id) {
    Get.toNamed(AppRoutes.hasil, arguments: {'riwayatId': id});
  }

  void hapusRiwayat(String id) {
    _riwayatService.hapusRiwayat(id);
  }

  void confirmHapusRiwayat(String id) {
    _riwayatService.hapusRiwayat(id);
    Get.snackbar(
      'Berhasil',
      'Riwayat berhasil dihapus',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void clearAllRiwayat() {
    _riwayatService.clearAllRiwayat();
    Get.snackbar(
      'Berhasil',
      'Semua riwayat berhasil dihapus',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goBack() {
    Get.back();
  }

  void goHome() {
    Get.offAllNamed(AppRoutes.home);
  }
}
