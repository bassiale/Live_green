import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String? username;
  String? image;
  String? commentText;
  String? uid;
  String? cid;
  Timestamp? dateTime;
  //Map<String, dynamic>? commentImage;

  CommentModel(
      {this.username,
      this.image,
      this.commentText,
      this.uid,
      this.cid,
      this.dateTime
      //this.commentImage,
      });

  CommentModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    image = json['image'];
    commentText = json['commentText'];
    uid = json['uid'];
    cid = json['cid'];
    dateTime = json['dateTime'];
    //commentImage = json['commentImage'];
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'image': image,
      'commentText': commentText,
      'uid': uid,
      'cid': cid,
      'dateTime': dateTime,
      //'commentImage': commentImage,
    };
  }
}
