class AdsPlace{
  int id;
  String titleEn;
  bool isEnabled;

  AdsPlace({
    this.id,
    this.titleEn,
    this.isEnabled
  });

  AdsPlace.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        titleEn = json['titleEn'],
        isEnabled = json['isEnabled'];
}