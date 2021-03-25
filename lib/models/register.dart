import 'package:mobile/shared/enums.dart';

class Register{
  String userName;
  String password;
  String firstName;
  String lastName;
  String city;
  int age;
  Gender gender;
  bool employed;

  Register({this.userName, this.password, this.firstName, this.lastName,
    this.city, this.age, this.gender, this.employed
  });

  Register.fromJson(Map<String, dynamic> json)
      : userName = json['userName'],
        password = json['password'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        city = json['city'],
        age = json['age'],
        gender = json['gender'],
        employed = json['employed'];

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    'city': city,
    'age': age,
    'gender': gender,
    'employed': employed,
  };
}