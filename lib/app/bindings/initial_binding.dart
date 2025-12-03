import 'package:get/get.dart';
import '../../data/services/excel_service.dart';
import '../../data/services/topsis_service.dart';
import '../../data/services/riwayat_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ExcelService(), permanent: true);
    Get.put(TopsisService(), permanent: true);
    Get.put(RiwayatService(), permanent: true);
  }
}
