import 'package:get/get.dart';

class ProfileHandler extends GetxController {
  var id = ''.obs; // 사용자 ID
  var region = ''.obs; // 사용자 지역 정보

  // 사용자 데이터 설정
  setUserData(String userId, String userRegion) {
    id.value = userId;
    region.value = userRegion;
  }

  // 데이터 초기화 (로그아웃 시)
  clearUserData() {
    id.value = '';
    region.value = '';
  }
}
