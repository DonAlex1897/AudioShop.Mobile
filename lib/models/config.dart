class Config{
  int id;
  String titleEn;
  String titleFa;
  String value;

  Config({this.id, this.titleEn, this.titleFa, this.value});

  Config.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        titleEn = json['titleEn'],
        titleFa = json['titleFa'],
        value = json['value'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'titleEn': titleEn,
    'titleFa': titleFa,
    'value': value,
  };
}