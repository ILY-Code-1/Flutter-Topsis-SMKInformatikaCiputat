import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/riwayat_model.dart';
import '../../data/services/riwayat_service.dart';
import '../../data/services/firebase_service.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';

class RiwayatController extends GetxController {
  final RiwayatService _riwayatService = Get.find<RiwayatService>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  
  final RxBool isLoading = false.obs;
  final RxList<RiwayatModel> firebaseRiwayatList = <RiwayatModel>[].obs;

  List<RiwayatModel> get riwayatList => firebaseRiwayatList;

  @override
  void onInit() {
    super.onInit();
    loadFirebaseRiwayat();
  }

  Future<void> loadFirebaseRiwayat() async {
    try {
      isLoading.value = true;
      final data = await _firebaseService.getAllRiwayat();
      firebaseRiwayatList.assignAll(data);
      update();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void lihatDetail(String id) {
    _showInputKeyDialog(
      title: 'Masukkan Key untuk Lihat Detail',
      expectedKey: id,
      onSuccess: (riwayat) {
        Get.toNamed(AppRoutes.hasil, arguments: {'riwayatModel': riwayat});
      },
    );
  }

  void hapusRiwayat(String id) {
    _showInputKeyDialog(
      title: 'Masukkan Key untuk Hapus',
      expectedKey: id,
      onSuccess: (riwayat) async {
        await _firebaseService.hapusRiwayat(id);
        _riwayatService.hapusRiwayat(id);
        firebaseRiwayatList.removeWhere((r) => r.id == id);
        update();
        Get.snackbar('Berhasil', 'Riwayat berhasil dihapus',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      },
    );
  }

  void confirmHapusRiwayat(String id) {
    hapusRiwayat(id);
  }

  void _showInputKeyDialog({
    required String title,
    required String expectedKey,
    required Function(RiwayatModel) onSuccess,
  }) {
    final keyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(title),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Masukkan key yang valid untuk melanjutkan',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: keyController,
                decoration: InputDecoration(
                  hintText: 'TOPSIS-XXXXXX',
                  prefixIcon: const Icon(Icons.key),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Key tidak boleh kosong';
                  }
                  if (value != expectedKey) {
                    return 'Key tidak cocok';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Get.back();
                final riwayat = firebaseRiwayatList.firstWhereOrNull((r) => r.id == expectedKey);
                if (riwayat != null) {
                  onSuccess(riwayat);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  // void clearAllRiwayat() {
  //   _riwayatService.clearAllRiwayat();
  //   Get.snackbar(
  //     'Berhasil',
  //     'Semua riwayat berhasil dihapus',
  //     snackPosition: SnackPosition.TOP,
  //   );
  // }

  void goBack() {
    Get.back();
  }

  void goHome() {
    Get.offAllNamed(AppRoutes.home);
  }

  Future<void> getFirebaseData() async {
    await loadFirebaseRiwayat();
  }
}
