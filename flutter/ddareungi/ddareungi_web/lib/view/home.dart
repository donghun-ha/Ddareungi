import 'package:ddareungi_web/controllers/bike_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final BikeController bikeController = Get.put(BikeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('따릉이 정보'),
      ),
      body: Center(
        child: Obx(() {
          if (bikeController.isLoading.value) {
            return const CircularProgressIndicator();
          } else {
            final info = bikeController.stationInfo.value;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('스테이션 이름: ${info['stationName']}'),
                Text('사용 가능한 자전거 수: ${info['availableBikes']}'),
                Text('거치대 개수: ${info['rackCount']}'),
                Text('거치율: ${info['shared']}%'),
              ],
            );
          }
        }),
      ),
    );
  }
}
