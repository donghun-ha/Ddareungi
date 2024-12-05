class Station {
  final double lat;
  final double lng;
  final String name;

  Station({required this.lat, required this.lng, required this.name});

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
        lat: json['lat'],
        lng: json['lng'],
        name: json['station_name'] // 예를 들어 JSON에 'station_name' 필드가 있다고 가정
        );
  }
}
