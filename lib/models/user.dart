class User{

  String token;
  bool hasPhoneNumber;

  User({this.token, this.hasPhoneNumber});

  User.fromJson(Map<String, dynamic> json)
      : token = json[0]['token'],
        hasPhoneNumber = json[1]['hasPhoneNumber'];

  Map<String, dynamic> toJson() => {
    'token': token,
    'hasPhoneNumber': hasPhoneNumber,
  };
}