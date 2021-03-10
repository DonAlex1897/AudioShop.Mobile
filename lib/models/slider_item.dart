class SliderItem{
  int id;
  String title;
  int description;
  int courseId;
  String isActive;
  String photoAddress;

  SliderItem({this.id, this.title, this.description, this.courseId, this.isActive, this.photoAddress});

  SliderItem.fromJson(Map<String, dynamic> json, String photoUrl)
      : id = json['id'],
        title = json['title'],
        description = json['description'],
        courseId = json['courseId'],
        isActive = json['isActive'],
        photoAddress = photoUrl +json['courseId'].toString() + '/'+ json['photoFileName'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'courseId': courseId,
    'isActive': isActive,
  };
}