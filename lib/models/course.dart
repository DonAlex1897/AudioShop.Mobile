class Course {
  int id;
  String name;
  double price;
  int waitingTimeBetweenEpisodes;
  String photoAddress;
  String description;
  String instructor;
  double averageScore;

  Course({
    this.id,
    this.name,
    this.price,
    this.waitingTimeBetweenEpisodes,
    this.photoAddress,
    this.description,
    this.instructor,
    this.averageScore});

  Course.fromJson(Map<String, dynamic> json, String photoUrl)
      : id = json['id'],
        name = json['name'],
        price = json['price'],
        waitingTimeBetweenEpisodes = json['waitingTimeBetweenEpisodes'],
        photoAddress = json['photoFileName'] != null ?
          photoUrl +json['id'].toString() + '/'+ json['photoFileName'] :
          '',
        description = json['description'],
        instructor = json['instructor'],
        averageScore = json['averageScore'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'waitingTimeBetweenEpisodes': waitingTimeBetweenEpisodes,
        //'photoFileName': photoAddress,
        'description': description,
        'instructor': instructor,
        'averageScore': averageScore
      };
}
