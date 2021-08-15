class Category{
  int id;
  String title;

  Category({this.id, this.title});

  Category.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'];
}