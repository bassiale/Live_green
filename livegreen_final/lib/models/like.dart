import 'package:cloud_firestore/cloud_firestore.dart';

class LikesModel {
  String? uid;
  String? lid;
  String? username;
  String? image;

  LikesModel({
    this.uid,
    this.lid,
    this.username,
    this.image,
  });

  LikesModel.fromJson(Map<String, dynamic>? json) {
    uid = json!['uid'];
    lid = json['lid'];
    username = json['username'];
    image = json['image'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'lid': lid,
      'username': username,
      'image': image,
    };
  }
}
