class Course {
  int id;
  String name;
  double price;
  int waitingTimeBetweenEpisodes;
  String photoAddress;
  String description;

  Course({this.id, this.name, this.price,this.waitingTimeBetweenEpisodes, this.photoAddress, this.description});

  Course.fromJson(Map<String, dynamic> json,String photoUrl)
      : id = json['id'],
        name = json['name'],
        price = json['price'],
        waitingTimeBetweenEpisodes = json['waitingTimeBetweenEpisodes'],
        photoAddress = photoUrl +json['id'].toString() + '/'+ json['photoFileName'],
        description = json['description'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'waitingTimeBetweenEpisodes': waitingTimeBetweenEpisodes,
        //'photoFileName': photoAddress,
        'description': description
      };
}
