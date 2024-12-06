import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ddareungi_web/model/station.dart';

class StationController {
  // API에서 Station 데이터를 가져오는 메서드
  Future<List<Station>> fetchStations() async {
    final url = Uri.parse('http://127.0.0.1:8000/map/stations');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map<Station>((json) => Station.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stations');
    }
  }
}
