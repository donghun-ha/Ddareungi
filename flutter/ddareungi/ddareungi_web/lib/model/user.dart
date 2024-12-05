class User {
  final String id;
  final String region;

  User({required this.id, required this.region});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      region: json['region'],
    );
  }
}
