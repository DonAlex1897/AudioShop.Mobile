import 'dart:convert';

class UserUpdate{
  String userId;
  String firstName;
  String lastName;
  String phoneNumber;
  String city;
  int age;
  int gender;
  int employed;

  UserUpdate({this.userId, this.firstName, this.age, this.city,
    this.gender,this.employed, this.phoneNumber, this.lastName});

  UserUpdate.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        phoneNumber = json['phoneNumber'],
        city = json['city'],
        age = json['age'],
        gender = json['gender'],
        employed = json['employed'];

  String toJson() => jsonEncode({
    'userId': userId,
    'firstName': firstName,
    'lastName': lastName,
    'phoneNumber': phoneNumber,
    'city': city,
    'age': age,
    'gender': gender,
    'employed': employed,
  });
}