class Station {
  final double lat;
  final double lng;
  final String name;

  Station({required this.lat, required this.lng, required this.name});

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      lat: json['lat'],
      lng: json['lng'],
      name: json['stationName'],
    );
  }
}
