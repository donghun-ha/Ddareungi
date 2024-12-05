import 'package:ddareungi_web/service/private.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BikeService {
  static const String baseUrl = 'http://openapi.seoul.go.kr:8088';

  Future<Map<String, dynamic>> getBikeStationInfo() async {
    const url = '$baseUrl/$apiKey/json/bikeList/1/1000';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final stations = data['rentBikeStatus']['row'];

      for (var station in stations) {
        if (station['stationName'].contains('롯데월드타워(잠실역2번출구 쪽)')) {
          return {
            'stationName': station['stationName'],
            'availableBikes': station['parkingBikeTotCnt'],
            'rackCount': station['rackTotCnt'],
            'shared': station['shared'],
          };
        }
      }
      throw Exception('지정된 스테이션을 찾을 수 없습니다.');
    } else {
      throw Exception('API 호출 실패');
    }
  }
}
