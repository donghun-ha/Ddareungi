import 'package:ddareungi_web/services/bike_service.dart';
import 'package:get/get.dart';

class BikeController extends GetxController {
  final BikeService _bikeService = BikeService();
  final stationInfo = Rx<Map<String, dynamic>>({});
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBikeStationInfo();
  }

  fetchBikeStationInfo() async {
    try {
      isLoading(true);
      final info = await _bikeService.getBikeStationInfo();
      stationInfo(info);
    } catch (e) {
      Get.snackbar('오류', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
