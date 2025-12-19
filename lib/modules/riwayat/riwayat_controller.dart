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
      title: 'Lihat Detail Perhitungan',
      subtitle: 'Masukkan key untuk melihat detail hasil perhitungan TOPSIS',
      expectedKey: id,
      icon: Icons.visibility_rounded,
      accentColor: AppColors.primary,
      confirmText: 'Lihat Detail',
      onSuccess: (riwayat) {
        Get.offNamed(AppRoutes.hasil, arguments: {'riwayatModel': riwayat});
      },
    );
  }

  void hapusRiwayat(String id) {
    _showInputKeyDialog(
      title: 'Hapus Perhitungan',
      subtitle: 'Masukkan key untuk menghapus data perhitungan ini. Tindakan ini tidak dapat dibatalkan!',
      expectedKey: id,
      icon: Icons.delete_forever_rounded,
      accentColor: Colors.red,
      confirmText: 'Hapus Data',
      isDestructive: true,
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
    required String subtitle,
    required String expectedKey,
    required IconData icon,
    required Color accentColor,
    required String confirmText,
    required Function(RiwayatModel) onSuccess,
    bool isDestructive = false,
  }) {
    final keyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDestructive ? Colors.red.shade700 : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: keyController,
                        decoration: InputDecoration(
                          hintText: 'TOPSIS-XXXXXX',
                          prefixIcon: Icon(Icons.key, color: accentColor),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: accentColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
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
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
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
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                confirmText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
