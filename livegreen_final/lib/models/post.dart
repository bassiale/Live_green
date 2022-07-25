import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? username;
  String? description;
  String? profileImage;
  String? uid;
  String? image;
  int? likes;
  int? comments;
  String? pid;
  Timestamp? dateTime;
  bool? isEvent;
  Timestamp? eventDate;
  String? title;

  PostModel({
    this.username,
    this.description,
    this.likes,
    this.comments,
    this.uid,
    this.image,
    this.profileImage,
    this.pid,
    this.dateTime,
    this.isEvent,
    this.title,
    this.eventDate,
  });

  PostModel.fromJson(Map<String, dynamic>? json) {
    username = json!['username'];
    description = json['description'];
    likes = json['likes'];
    comments = json['comments'];
    pid = json['pid'];
    uid = json['uid'];
    image = json['image'];
    profileImage = json['profileImage'];
    dateTime = json['dateTime'];
    isEvent = json['isEvent'];
    title = json['title'];
    eventDate = json['eventDate'];
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'description': description,
      'comments': comments,
      'likes': likes,
      'pid': pid,
      'uid': uid,
      'image': image,
      'profileImage': profileImage,
      'dateTime': dateTime,
      'isEvent': isEvent,
      'title': title,
      'eventDate': eventDate
    };
  }
}
