class Course {
  int id;
  String name;
  double price;
  String photoAddress;
  String description;

  Course({this.id, this.name, this.price, this.photoAddress, this.description});

  Course.fromJson(Map<String, dynamic> json,String photoUrl)
      : id = json['id'],
        name = json['name'],
        price = json['price'],
        photoAddress = photoUrl +json['id'].toString() + '/'+ json['photoFileName'],
        description = json['description'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        //'photoFileName': photoAddress,
        'description': description
      };
}
