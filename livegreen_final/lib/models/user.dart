import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? username;
  String? email;
  String? uid;
  String? profilePic;
  String? bio;
  int? score;
  List? followers;
  List? following;
  List? likedPosts;
  List? posts;

  UserModel({
    this.username,
    this.email,
    this.uid,
    this.profilePic,
    this.bio,
    this.followers,
    this.posts,
    this.following,
    this.likedPosts,
    this.score,
  });
  UserModel.fromJson(Map<String, dynamic>? json) {
    username = json!['username'];
    email = json['email'];
    followers = json['followers'];
    following = json['following'];
    posts = json['posts'];
    likedPosts = json['likedPosts'];
    uid = json['uid'];
    profilePic = json['profilePic'];
    bio = json['bio'];
    score = json['score'];
  }
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'uid': uid,
      'profilePic': profilePic,
      'bio': bio,
      'followers': followers,
      'following': following,
      'posts': posts,
      'likedPosts': likedPosts,
      'score': score,
    };
  }
}
