import 'package:get/get.dart';
import 'app_routes.dart';
import '../../modules/home/home_binding.dart';
import '../../modules/home/home_view.dart';
import '../../modules/hasil/hasil_binding.dart';
import '../../modules/hasil/hasil_view.dart';
import '../../modules/riwayat/riwayat_binding.dart';
import '../../modules/riwayat/riwayat_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.hasil,
      page: () => const HasilView(),
      binding: HasilBinding(),
    ),
    GetPage(
      name: AppRoutes.riwayat,
      page: () => const RiwayatView(),
      binding: RiwayatBinding(),
    ),
  ];
}
