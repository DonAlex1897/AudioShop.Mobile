import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/user_update.dart';
import 'package:mobile/services/authentication_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';

class UserInformationPage extends StatefulWidget {
  @override
  _UserInformationPageState createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  CourseStore courseStore;
  Future<User> userFuture;
  double width;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController salespersonCouponCodeController = TextEditingController();
  String genderString = 'جنسیت';
  Gender gender = Gender.Default;
  bool isEmployed;
  String employmentStatus = 'اشتغال';
  bool isFirstLoad = true;
  FlutterSecureStorage secureStorage;

  @override
  void initState() {
    super.initState();
    secureStorage = FlutterSecureStorage();
  }

  String replaceFarsiNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(farsi[i], english[i]);
    }

    return input;
  }

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);
    if(isFirstLoad){
      isFirstLoad = false;
      firstNameController.text = courseStore.firstName;
      lastNameController.text = courseStore.lastName;
      phoneNumberController.text = courseStore.phoneNumber;
      ageController.text = courseStore.age.toString();
      cityController.text = courseStore.city;
      cityController.text = courseStore.city;
      salespersonCouponCodeController.text = courseStore.salespersonCouponCode;
      // gender = Gender.values[courseStore.gender];
      setState(() {
        if(courseStore.gender == 1)
          genderString = 'مذکر';
        else if(courseStore.gender == 2)
          genderString = 'مونث';
      });
      setState(() {
        if(courseStore.employed != null && courseStore.employed)
          employmentStatus = 'شاغل';
        else if(courseStore.employed != null && !courseStore.employed)
          employmentStatus = 'جویای کار';
      });
      // isEmployed = courseStore.employed;
    }
    width = MediaQuery.of(context).size.width;
    return Scaffold(
              appBar: AppBar(
                title: Text('مشخصات کاربری'),
              ),
              body: SafeArea(
                  child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  width: width * 0.35,
                                  height: width * 0.35,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: AssetImage('assets/images/appMainIcon.png'),
                                        fit: BoxFit.fill
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              child: TextField(
                                style: TextStyle(
                                    decorationColor: Colors.black, color: Colors.white),
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  border: OutlineInputBorder(),
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  labelText: 'نام',
                                  hintStyle: TextStyle(
                                    color: Colors.white60,
                                  ),
                                  icon: Icon(
                                    Icons.person,
                                    size: 22,
                                  ),
                                ),
                                controller: firstNameController,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              child: TextField(
                                style: TextStyle(
                                    decorationColor: Colors.black, color: Colors.white),
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  border: OutlineInputBorder(),
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  labelText: 'نام خانوادگی',
                                  hintStyle: TextStyle(
                                    color: Colors.white60,
                                  ),
                                  icon: Icon(
                                    Icons.person,
                                    size: 22,
                                  ),
                                ),
                                controller: lastNameController,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    child: TextField(
                                      style: TextStyle(
                                          decorationColor: Colors.black, color: Colors.white),
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.white, width: 2.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.white, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(),
                                        labelStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        labelText: 'سن',
                                        hintStyle: TextStyle(
                                          color: Colors.white60,
                                        ),
                                        icon: Icon(
                                          Icons.cake,
                                          size: 22,
                                        ),
                                      ),
                                      controller: ageController,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    child: TextField(
                                      style: TextStyle(
                                          decorationColor: Colors.black, color: Colors.white),
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.white, width: 2.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.white, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(),
                                        labelStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        labelText: 'شهر',
                                        hintStyle: TextStyle(
                                          color: Colors.white60,
                                        ),
                                        icon: Icon(
                                          Icons.location_city,
                                          size: 22,
                                        ),
                                      ),
                                      controller: cityController,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          icon: Icon(Icons.wc),
                                          dropdownColor: Color(0xFF44434C),
                                          style: TextStyle(color: Colors.white),
                                          value: genderString,
                                          onChanged: (String newValue){
                                            setState(() {
                                                genderString = newValue;
                                              });
                                            switch(newValue){
                                              case 'مذکر':
                                                gender = Gender.Male;
                                                break;
                                              case 'مونث':
                                                gender = Gender.Female;
                                                break;
                                              case 'جنسیت':
                                                gender = Gender.Default;
                                                break;
                                            }
                                          },
                                          items: <String>['جنسیت', 'مذکر', 'مونث']
                                               .map<DropdownMenuItem<String>>((String value) {
                                             return DropdownMenuItem<String>(
                                               value: value,
                                               child: Text(value),
                                             );
                                           }).toList(),

                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          icon: Icon(Icons.work),
                                          dropdownColor: Color(0xFF44434C),
                                          style: TextStyle(color: Colors.white),
                                          value: employmentStatus,
                                          onChanged: (String newValue) {
                                            setState(() {
                                              employmentStatus = newValue;
                                            });
                                            switch(newValue){
                                              case 'شاغل':
                                                isEmployed = true;
                                                break;
                                              case 'جویای کار':
                                                isEmployed = false;
                                                break;
                                              case 'اشتغال':
                                                isEmployed = null;
                                            }
                                          },
                                          items: <String>['اشتغال', 'شاغل', 'جویای کار']
                                                        .map<DropdownMenuItem<String>>((String value) {
                                                      return DropdownMenuItem<String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    child: TextField(
                                      enabled: false,
                                      style: TextStyle(
                                          decorationColor: Colors.black, color: Colors.white),
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.white, width: 2.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.white, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(),
                                        labelStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        labelText: 'شماره همراه',
                                        hintStyle: TextStyle(
                                          color: Colors.white60,
                                        ),
                                        icon: Icon(
                                          Icons.phone_android,
                                          size: 22,
                                        ),
                                      ),
                                      controller: phoneNumberController,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    child: TextField(
                                      enabled: false,
                                      style: TextStyle(
                                          decorationColor: Colors.black, color: Colors.white),
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.white, width: 2.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.white, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(),
                                        labelStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        labelText: 'کد معرف',
                                        hintStyle: TextStyle(
                                          color: Colors.white60,
                                        ),
                                        icon: Icon(
                                          Icons.card_giftcard,
                                          size: 22,
                                        ),
                                      ),
                                      controller: salespersonCouponCodeController,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ArgonButton(
                              height: 50,
                              width: 400,
                              borderRadius: 5.0,
                              color: Color(0xFF20BFA9),
                              child: Text(
                                "ذخیره تغییرات",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700
                                ),
                              ),
                              loader: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SpinKitRing(
                                  color: Colors.white,
                                  lineWidth: 4,
                                ),
                              ),
                              onTap:(startLoading, stopLoading, btnState) async {
                                  startLoading();
                                  AuthenticationService authService = AuthenticationService();

                                  User updatedUserInfo = await authService.updateUserInfo(UserUpdate(
                                    userId: courseStore.userId,
                                    firstName: firstNameController.text,
                                    lastName: lastNameController.text,
                                    phoneNumber: courseStore.phoneNumber,
                                    age: ageController.text != null ?
                                      int.parse(replaceFarsiNumber(ageController.text)): 0,
                                    city: cityController.text,
                                    gender: gender.index,
                                    employed: isEmployed
                                  ));

                                  if (updatedUserInfo == null)
                                    Fluttertoast.showToast(
                                        msg: 'ثبت شماره با مشکل مواجه شد. لطفا مجددا تلاش کنید.');
                                  else {
                                    await secureStorage.write(
                                        key: 'token',
                                        value: updatedUserInfo.token);
                                    await secureStorage.write(
                                        key: 'hasPhoneNumber',
                                        value: updatedUserInfo.hasPhoneNumber.toString());
                                    await secureStorage.write(
                                        key: 'firstName',
                                        value: updatedUserInfo.firstName);
                                    await secureStorage.write(
                                        key: 'lastName',
                                        value: updatedUserInfo.lastName);
                                    await secureStorage.write(
                                        key: 'phoneNumber',
                                        value: updatedUserInfo.phoneNumber);
                                    await secureStorage.write(
                                        key: 'age',
                                        value: updatedUserInfo.age.toString());
                                    await secureStorage.write(
                                        key: 'city',
                                        value: updatedUserInfo.city);
                                    await secureStorage.write(
                                        key: 'gender',
                                        value: updatedUserInfo.gender.toString());
                                    await secureStorage.write(
                                        key: 'employed',
                                        value: updatedUserInfo.employed.toString());
                                    await secureStorage.write(
                                        key: 'salespersonCouponCode',
                                        value: updatedUserInfo.salespersonCouponCode);
                                    await secureStorage.write(
                                        key: 'subscriptionExpirationDate',
                                        value: updatedUserInfo.subscriptionExpirationDate.toString());
                                    await secureStorage.write(
                                        key: 'subscriptionType',
                                        value: updatedUserInfo.subscriptionType.toString());

                                    await courseStore.setUserDetails(updatedUserInfo);

                                    setState(() { });
                                  }
                                  stopLoading();
                              },
                            ),
                          ),
                        ],
                      ),
                  ),
              ),
            );
  }
}
