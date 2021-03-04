class Review{
  int id;
  String text;
  int rating;
  bool accepted;
  DateTime date;
  int courseId;
  String userId;
  String userFirstName;
  String userLastName;

  Review({this.id, this.text, this.rating, this.accepted, this.date, this.courseId, this.userId, this.userFirstName, this.userLastName});

  Review.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'],
        rating = json['rating'],
        accepted = json['accepted'],
        date = DateTime.parse(json['date']),
        courseId = json['courseId'],
        userId = json['userId'],
        userFirstName = json['userFirstName'],
        userLastName = json['userLastName'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'rating': rating,
    'accepted': accepted,
    'date': date,
    'courseId': courseId,
    'userId': userId,
    'userFirstName': userFirstName,
    'userLastName': userLastName
  };
}