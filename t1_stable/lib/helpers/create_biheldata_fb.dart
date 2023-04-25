import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_blue_plus_example/helpers/biheldata.dart';

Future createData({
  required String userMail,
  required String date,
  required DateTime dateTime,
  required double averageSpeed,
  required double totalDistance,
  required double time,
  required String imageUrl,
}) async {
  final user = FirebaseAuth.instance.currentUser;

  final docBihelData =
      FirebaseFirestore.instance.collection('BihelData_${user!.email}').doc();

  final product = BiHelData(
    id: docBihelData.id,
    userMail: userMail,
    date: date,
    dateTime: dateTime,
    averageSpeed: averageSpeed,
    totalDistance: totalDistance,
    time: time,
    imageUrl: imageUrl,
  );

  final json = product.toJson();

  await docBihelData.set(json);
}
