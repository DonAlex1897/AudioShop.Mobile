import 'dart:convert';

class User{
  String token;
  bool hasPhoneNumber;
  String salespersonCouponCode;
  String firstName;
  String lastName;
  String phoneNumber;
  String city;
  int age;
  int gender;
  bool employed;

  User({this.token, this.hasPhoneNumber, this.salespersonCouponCode, this.firstName,
    this.age, this.city,this.gender,this.employed, this.phoneNumber, this.lastName});

  User.fromJson(Map<String, dynamic> json)
      : token = json['token'],
        hasPhoneNumber = json['hasPhoneNumber'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        phoneNumber = json['phoneNumber'],
        city = json['city'],
        age = json['age'],
        gender = json['gender'],
        employed = json['employed'],
        salespersonCouponCode = json['salespersonCouponCode'];

  String toJson() => jsonEncode({
    'token': token,
    'hasPhoneNumber': hasPhoneNumber,
    'salespersonCouponCode': salespersonCouponCode,
    'firstName': firstName,
    'lastName': lastName,
    'phoneNumber': phoneNumber,
    'city': city,
    'age': age,
    'gender': gender,
    'employed': employed,
  });
}