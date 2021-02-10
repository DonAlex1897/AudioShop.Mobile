class CourseEpisode {
  int id;
  int courseId;
  String name;
  double price;
  String description;
  int sort;

  CourseEpisode({this.id, this.name, this.price, this.courseId, this.description, this.sort});

  CourseEpisode.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        courseId = json['courseId'],
        name = json['name'],
        price = json['price'],
        description = json['description'],
        sort = json['sort'];

  Map<String, dynamic> toJson() => {
        'id': id,
    'courseId': courseId,
        'name': name,
        'price': price,
        'description': description,
        'sort': sort
      };
}
