class BiHelData {
  String id;
  String userMail;
  String date;
  DateTime dateTime;
  double averageSpeed;
  double totalDistance;
  double time;
  String imageUrl;

  BiHelData({
    required this.id,
    required this.userMail,
    required this.date,
    required this.dateTime,
    required this.averageSpeed,
    required this.totalDistance,
    required this.time,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userMail': userMail,
        'date': date,
        'dateTime': dateTime,
        'averageSpeed': averageSpeed,
        'totalDistance': totalDistance,
        'time': time,
        'imageUrl': imageUrl,
      };

  // static BiHelData fromJson(Map<String, dynamic> json) => BiHelData(
  //       id: json['id'],
  //       name: json['name'],
  //       quantity: json['quantity'],
  //       image: json['image'],
  //     );
}
