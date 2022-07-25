import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  String? title;
  String? icon;
  int? points;

  TaskModel({
      this.title,
      this.icon,
      this.points
  });
  TaskModel.fromJson(Map<String, dynamic>? json) {
    title = json!['title'];
    icon = json['icon'];
    points = json['points'];
  }
    
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'points': points,
      'icon': icon,
    };
  }
}