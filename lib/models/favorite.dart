import 'dart:convert';

class Favorite {
  int id;
  String userId;
  int courseId;
  int episodeId;
  String description;

  Favorite({
    this.id,
    this.userId,
    this.courseId,
    this.episodeId,
    this.description});

  Favorite.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['userId'],
        courseId = json['courseId'],
        episodeId = json['episodeId'],
        description = json['description'];

  String toJson() {
    if(id != null){
      return jsonEncode({
        'id': id,
        'userId': userId,
        'courseId': courseId,
        'episodeId': episodeId,
        'description': description
      });
    }
    else{
      return jsonEncode({
        'userId': userId,
        'courseId': courseId,
        'episodeId': episodeId,
        'description': description
      });
    }
  }
}