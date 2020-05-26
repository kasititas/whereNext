import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String email;
  String name;
  String pictureUrl;
  Timestamp accountCreated;

  User({
    this.uid,
    this.email,
    this.name,
    this.pictureUrl,
    this.accountCreated,
  });
}
