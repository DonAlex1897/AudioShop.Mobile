import 'dart:convert';

class Progress {
  int id;
  String userId;
  int courseId;
  DateTime lastListened;
  int lastIndex;
  int lastEpisodeId;

  Progress({
    this.id,
    this.userId,
    this.courseId,
    this.lastListened,
    this.lastIndex,
    this.lastEpisodeId});

  Progress.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['userId'],
        courseId = json['courseId'],
        lastListened = DateTime.parse(json['lastListened']),
        lastIndex = json['lastIndex'],
        lastEpisodeId = json['lastEpisodeId'];

  String toJson() {
    if(id != null){
      return jsonEncode({
        'id': id,
        'userId': userId,
        'courseId': courseId,
        'lastListened': lastListened.toString(),
        'lastIndex': lastIndex,
        'lastEpisodeId': lastEpisodeId
      });
    }
    else{
      return jsonEncode({
        'userId': userId,
        'courseId': courseId,
        'lastListened': lastListened.toString(),
        'lastIndex': lastIndex,
        'lastEpisodeId': lastEpisodeId
      });
    }
  }
}