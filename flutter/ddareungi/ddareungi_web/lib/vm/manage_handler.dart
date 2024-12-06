import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ddareungi_web/model/manage.dart';

class ManageHandler {
  final String baseUrl;

  ManageHandler({this.baseUrl = 'http://127.0.0.1:8000'});

  /// stationName을 기반으로 stationCode를 가져오는 함수
  Future<String?> getStationCodeByName(String stationName) async {
    final url = Uri.parse('$baseUrl/manage/get-station-code/$stationName');
    // print("Requesting URL: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // print("Response Data: $data");
      return data['station_code'];
    } else {
      // print("Error: ${response.statusCode}, Body: ${response.body}");
      return null; // station_code를 찾지 못한 경우
    }
  }

  /// stationCode를 기반으로 manage 데이터를 가져오는 함수
  Future<List<Manage>> fetchManageDataByStationCode(String stationCode) async {
    final url = Uri.parse('$baseUrl/manage/get-manage-data/$stationCode');
    // print("Fetching manage data URL: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      // print("Fetched Data: $data");
      return data.map<Manage>((json) => Manage.fromJson(json)).toList();
    } else {
      // print("Error: ${response.statusCode}, Body: ${response.body}");
      throw Exception('Failed to fetch manage data: ${response.statusCode}');
    }
  }

  /// stationName을 사용해 바로 manage 데이터를 가져오는 함수
  Future<List<Manage>> fetchManageDataByStationName(String stationName) async {
    // Step 1: stationName으로 stationCode 가져오기
    final stationCode = await getStationCodeByName(stationName);
    if (stationCode == null) {
      throw Exception('Station code not found for station name: $stationName');
    }

    // Step 2: stationCode로 manage 데이터를 가져오기
    return await fetchManageDataByStationCode(stationCode);
  }
}
