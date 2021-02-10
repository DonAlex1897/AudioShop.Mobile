class EpisodeAudios {
  int id;
  String audioAddress;

  EpisodeAudios({this.id, this.audioAddress});

  EpisodeAudios.fromJson(Map<String, dynamic> json,String audioUrl, int courseId)
      : id = json['id'],
        audioAddress = audioUrl + courseId.toString() + '/'+ json['fileName'];

  Map<String, dynamic> toJson() => {
    'id': id,
  };
}
