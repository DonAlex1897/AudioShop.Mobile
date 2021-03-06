class User{

  String token;
  bool hasPhoneNumber;
  String salespersonCouponCode;

  User({this.token, this.hasPhoneNumber});

  User.fromJson(Map<String, dynamic> json)
      : token = json['token'],
        hasPhoneNumber = json['hasPhoneNumber'],
        salespersonCouponCode = json['salespersonCouponCode'];

  Map<String, dynamic> toJson() => {
    'token': token,
    'hasPhoneNumber': hasPhoneNumber,
    'salespersonCouponCode': salespersonCouponCode,
  };
}