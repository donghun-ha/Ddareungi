class Manage {
  final int standardTime;
  final int crCount;
  final int rent;
  final int restore;
  final int fillCount;

  Manage({
    required this.standardTime,
    required this.crCount,
    required this.rent,
    required this.restore,
    required this.fillCount,
  });

  factory Manage.fromJson(Map<String, dynamic> json) {
    return Manage(
      standardTime: json['standard_time'],
      crCount: json['cr_count'],
      rent: json['rent'],
      restore: json['restore'],
      fillCount: json['fill_count'],
    );
  }
}
