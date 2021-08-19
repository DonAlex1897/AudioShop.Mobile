import 'dart:convert';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/models/register.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/store/course_store.dart';
import 'package:async/async.dart';
import 'package:mobile/services/authentication_service.dart';
import 'package:provider/provider.dart';


class AuthenticationPage extends StatefulWidget {
  AuthenticationPage(this.baseForm);

  final baseForm;
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  var formName = FormName.SignUp;
  var purchaseType = PurchaseType.SingleEpisode;
  AuthenticationService authService = AuthenticationService();
  TextEditingController phoneNumberController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController userNameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  TextEditingController verificationCodeController =
    new TextEditingController();
  TextEditingController presenterController = new TextEditingController();
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController countryController = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController ageController = new TextEditingController();
  TextEditingController salespersonCouponCodeController =
    new TextEditingController();
  bool isEmployed;
  String employmentStatus = 'اشتغال';
  Gender gender = Gender.Default;
  String genderString = 'جنسیت';
  FlutterSecureStorage secureStorage;
  CourseStore courseStore;
  Duration _timerDuration = new Duration(seconds: 60);
  RestartableTimer _timer;
  bool sentCode = false;
  bool isTimerActive = false;
  bool isCheckingUserName = false;
  String phoneNumberError = '';
  String verificationCodeError = '';
  String userNameError = '';
  String passwordError = '';
  FocusNode focusRepeatPassword = new FocusNode();
  FocusNode focusReceivedCode = FocusNode();

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    formName = widget.baseForm;
    secureStorage = FlutterSecureStorage();
    focusRepeatPassword.addListener(onFocusChange);
  }

  void onFocusChange(){
    if(passwordController.text.length < 6)
      setState(() {
        passwordError = 'رمز عبور حداقل باید 6 کاراکتر باشد';
      });
    else{
      setState(() {
        passwordError = '';
      });
    }
  }

  Future<bool> receiveCode() async {
    _timer = RestartableTimer(_timerDuration, setTimerState);

    setState(() {
      isTimerActive = true;
    });

    bool isRepetitiveUser = await authService
        .isPhoneNumberRegistered(phoneNumberController.text);

    if (formName == FormName.SignIn) {
      if (isRepetitiveUser) {
        sentCode = await authService.sendVerificationCode(phoneNumberController.text);
      } else {
        Fluttertoast.showToast(
            msg: 'کاربری با این شماره تلفن یافت نشد. لطفا ثبت نام کنید.');
        setState(() {
          isTimerActive = false;
        });
        return false;
      }
    } else {
      if(!isRepetitiveUser){
        sentCode = await authService.
          verifyPhoneNumber(phoneNumberController.text, courseStore.userId);
      }
      else {
        Fluttertoast.showToast(msg: 'شماره همراه تکراری است. کافی است وارد شوید.');
        setState(() {
          isTimerActive = false;
        });
        return false;
      }
    }

    if (sentCode)
      Fluttertoast.showToast(msg: 'کد تایید برای شما ارسال شد');
    else{
      Fluttertoast.showToast(msg: 'کد تایید ارسال نشد. لطفا مجددا امتحان کنید');
      setState(() {
        isTimerActive = false;
      });
      return false;
    }

    sentCode = false;
    return true;
  }

  Future<bool> isUserNameRepetitive(String username) async {
    var usernameExists = await authService.usernameExists(username);
    if (usernameExists)
      Fluttertoast.showToast(
          msg: 'نام کاربری تکراری است. لطفا آن را تغییر دهید');
    else if (!usernameExists)
      Fluttertoast.showToast(msg: 'نام کاربری در دسترس است');
    else
      Fluttertoast.showToast(
          msg: 'مشکل در برقراری ارتباط. لطفا مجددا تلاش کنید');
    return usernameExists;
  }

  Widget sendCodeButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: (!isTimerActive) ? Colors.red[700] : Colors.red[200],
      ),
      child: ArgonTimerButton(
        initialTimer: 0, // Optional
        height: 50,
        width: MediaQuery.of(context).size.width * 0.45,
        minWidth: MediaQuery.of(context).size.width * 0.45,
        color: (!isTimerActive) ? Colors.red[700] : Colors.red[200],
        borderRadius: 5.0,
        child: Text(
          "ارسال کد",
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700
          ),
        ),
        roundLoadingShape: false,
        loader: (timeLeft) {
          return Text(
            "ارسال مجدد | $timeLeft",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        },
        onTap: (startTimer, btnState) async {
          if (btnState == ButtonState.Idle) {
            bool isQualified = true;
            setState(() {
              if (!isTimerActive) {
                if(phoneNumberController.text.isNotEmpty &&
                    phoneNumberController.text[0] == '0')
                  phoneNumberController.text =
                      phoneNumberController.text.substring(1);
                setState(() {
                  phoneNumberError = verificationCodeError = '';
                  if (phoneNumberController.text.isEmpty){
                    phoneNumberError = 'شماره موبایل الزامی است';
                    isQualified = false;
                  }
                  else if(phoneNumberController.text.length != 10){
                    phoneNumberError = 'فرمت شماره همراه اشتباه است';
                    isQualified = false;
                  }
                });
              }
            });
            if(isQualified){
              focusReceivedCode.requestFocus();
              startTimer(60);
              if(!await receiveCode())
                startTimer(1);
            }
          }
        },
      )
      // child: TextButton(
      //   onPressed: () {
      //     setState(() {
      //       if (!isTimerActive) {
      //         bool isQualified = true;
      //         if(phoneNumberController.text.isNotEmpty &&
      //             phoneNumberController.text[0] == '0')
      //           phoneNumberController.text =
      //               phoneNumberController.text.substring(1);
      //         setState(() {
      //           phoneNumberError = verificationCodeError = '';
      //           if (phoneNumberController.text.isEmpty){
      //             phoneNumberError = 'شماره موبایل الزامی است';
      //             isQualified = false;
      //           }
      //           else if(phoneNumberController.text.length != 10){
      //             phoneNumberError = 'فرمت شماره همراه اشتباه است';
      //             isQualified = false;
      //           }
      //         });
      //         if(isQualified)
      //           receiveCode();
      //       }
      //     });
      //   },
      //   child: Text(
      //     (!isTimerActive) ? 'دریافت کد' : 'کد ارسال شد',
      //     style: TextStyle(
      //       fontSize: 16,
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //     ),
      //   ),
      // ),
    );
  }

  void setTimerState() {
    setState(() {
      isTimerActive = false;
    });
  }

  Future registerPhoneNumber() async{
    User user = await authService.registerPhoneNumber(
        phoneNumberController.text, verificationCodeController.text, courseStore.userId);
    if (user == null)
      Fluttertoast.showToast(
          msg: 'ثبت شماره با مشکل مواجه شد. لطفا مجددا تلاش کنید.');
    else {
      await secureStorage.write(
          key: 'token',
          value: user.token);
      await secureStorage.write(
          key: 'hasPhoneNumber',
          value: user.hasPhoneNumber.toString());
      await secureStorage.write(
          key: 'firstName',
          value: user.firstName);
      await secureStorage.write(
          key: 'lastName',
          value: user.lastName);
      await secureStorage.write(
          key: 'phoneNumber',
          value: user.phoneNumber);
      await secureStorage.write(
          key: 'age',
          value: user.age.toString());
      await secureStorage.write(
          key: 'city',
          value: user.city);
      await secureStorage.write(
          key: 'gender',
          value: user.gender.toString());
      await secureStorage.write(
          key: 'employed',
          value: user.employed.toString());
      await secureStorage.write(
          key: 'salespersonCouponCode',
          value: user.salespersonCouponCode);

      await courseStore.setUserDetails(user);

      setState(() { });

      Navigator.pop(context);
    }
  }

  Future<bool> signUp() async {
    bool isUserNotOk = await isUserNameRepetitive(userNameController.text);
    if (!isUserNotOk) {
      Register registerInfo = Register();
      registerInfo.userName = userNameController.text;
      registerInfo.password = passwordController.text;
      registerInfo.firstName = firstNameController.text;
      registerInfo.lastName = lastNameController.text;
      if(isEmployed != null)
        registerInfo.employed = isEmployed;
      registerInfo.city = cityController.text;
      if(gender != Gender.Default)
        registerInfo.gender = gender;
      if(ageController.text != '')
        registerInfo.age = int.parse(ageController.text);
      User registeredUser = await authService.signUp(registerInfo);
      if (registeredUser == null) {
        Fluttertoast.showToast(
            msg: 'ثبت نام با مشکل مواجه شد. لطفا مجددا تلاش کنید.');
        return false;
      } else {
        await secureStorage.write(
            key: 'token',
            value: registeredUser.token);
        await secureStorage.write(
            key: 'hasPhoneNumber',
            value: registeredUser.hasPhoneNumber.toString());
        await secureStorage.write(
            key: 'firstName',
            value: registeredUser.firstName);
        await secureStorage.write(
            key: 'lastName',
            value: registeredUser.lastName);
        await secureStorage.write(
            key: 'phoneNumber',
            value: registeredUser.phoneNumber);
        await secureStorage.write(
            key: 'age',
            value: registeredUser.age.toString());
        await secureStorage.write(
            key: 'city',
            value: registeredUser.city);
        await secureStorage.write(
            key: 'gender',
            value: registeredUser.gender.toString());
        await secureStorage.write(
            key: 'employed',
            value: registeredUser.employed.toString());
        await secureStorage.write(
            key: 'salespersonCouponCode',
            value: registeredUser.salespersonCouponCode);

        await courseStore.setUserDetails(registeredUser);

        setState(() { });

        return true;
      }
    }
    return false;
  }

  Future signIn() async {
    User loggedInUser = await authService.signIn(
        phoneNumberController.text, verificationCodeController.text);
    if (loggedInUser == null)
      Fluttertoast.showToast(
          msg: 'ثبت نام با مشکل مواجه شد. لطفا مجددا تلاش کنید.');
    else {
      await secureStorage.write(
          key: 'token',
          value: loggedInUser.token);
      await secureStorage.write(
          key: 'hasPhoneNumber',
          value: loggedInUser.hasPhoneNumber.toString());
      await secureStorage.write(
          key: 'firstName',
          value: loggedInUser.firstName);
      await secureStorage.write(
          key: 'lastName',
          value: loggedInUser.lastName);
      await secureStorage.write(
          key: 'phoneNumber',
          value: loggedInUser.phoneNumber);
      await secureStorage.write(
          key: 'age',
          value: loggedInUser.age.toString());
      await secureStorage.write(
          key: 'city',
          value: loggedInUser.city);
      await secureStorage.write(
          key: 'gender',
          value: loggedInUser.gender.toString());
      await secureStorage.write(
          key: 'employed',
          value: loggedInUser.employed.toString());
      await secureStorage.write(
          key: 'salespersonCouponCode',
          value: loggedInUser.salespersonCouponCode);

      await courseStore.setUserDetails(loggedInUser);

      setState(() { });

      Navigator.pop(context);
    }
  }

  Widget authForm(FormName formName) {
    if (formName == FormName.SignIn)
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(65, 65, 65, 0),
            child: Center(
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'برای ورود به حساب کاربری، شماره همراه خود را وارد کنید',
                        style:
                            TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 28.0),
                      child: Container(
                        child: TextField(
                          style: TextStyle(
                              decorationColor: Colors.black, color: Colors.white),
                          keyboardType: TextInputType.phone,
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
                            hintText: 'مثال: 9121111111',
                            hintStyle: TextStyle(
                              color: Colors.white60,
                            ),
                          ),
                          controller: phoneNumberController,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                      child: Text(
                        phoneNumberError,
                        style: TextStyle(color: Colors.red[200]),
                      ),
                    ),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: sendCodeButton(),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: TextField(
                                focusNode: focusReceivedCode,
                                style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  labelText: 'کد دریافتی',
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                controller: verificationCodeController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25,
                      child: Text(
                        verificationCodeError,
                        style: TextStyle(color: Colors.red[200]),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(0xFF20BFA9),
                      ),
                      child: ArgonButton(
                        height: 50,
                        width: 400,
                        borderRadius: 5.0,
                        color: Color(0xFF20BFA9),
                        child: Text(
                          "تایید",
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
                          bool isQualified = true;
                          if(phoneNumberController.text.isNotEmpty &&
                              phoneNumberController.text[0] == '0')
                            phoneNumberController.text =
                                phoneNumberController.text.substring(1);
                          setState(() {
                            phoneNumberError = verificationCodeError = '';
                            if (phoneNumberController.text.isEmpty){
                              phoneNumberError = 'شماره موبایل الزامی است';
                              isQualified = false;
                            }
                            else if(phoneNumberController.text.length != 10){
                              phoneNumberError =
                              'فرمت شماره همراه اشتباه است';
                              isQualified = false;
                            }
                            if (verificationCodeController.text.isEmpty){
                              verificationCodeError =
                              'کد ارسال شده به همراهتان را وارد کنید';
                              isQualified = false;
                            }
                          });
                          if(isQualified){
                            startLoading();
                            await signIn();
                            stopLoading();
                          }
                        },
                      ),
                      // child: TextButton(
                      //   onPressed: () async {
                      //     bool isQualified = true;
                      //     if(phoneNumberController.text.isNotEmpty &&
                      //         phoneNumberController.text[0] == '0')
                      //       phoneNumberController.text =
                      //           phoneNumberController.text.substring(1);
                      //     setState(() {
                      //       phoneNumberError = verificationCodeError = '';
                      //       if (phoneNumberController.text.isEmpty){
                      //         phoneNumberError = 'شماره موبایل الزامی است';
                      //         isQualified = false;
                      //       }
                      //       else if(phoneNumberController.text.length != 10){
                      //         phoneNumberError =
                      //           'فرمت شماره همراه اشتباه است';
                      //         isQualified = false;
                      //       }
                      //       if (verificationCodeController.text.isEmpty){
                      //         verificationCodeError =
                      //           'کد ارسال شده به همراهتان را وارد کنید';
                      //         isQualified = false;
                      //       }
                      //     });
                      //     if(isQualified)
                      //       await signIn();
                      //   },
                      //   child: Text(
                      //     'تایید',
                      //     style: TextStyle(
                      //       fontSize: 20,
                      //       fontWeight: FontWeight.bold,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    else if (formName == FormName.RegisterPhoneNumber)
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(65, 65, 65, 0),
            child: Center(
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'لطفا شماره همراه خود را جهت بازیابی وارد کنید',
                        style:
                            TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      style: TextStyle(
                          decorationColor: Colors.black, color: Colors.white),
                      keyboardType: TextInputType.phone,
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
                        hintText: 'مثال: 9121111111',
                        hintStyle: TextStyle(
                          color: Colors.white60,
                        ),
                      ),
                      controller: phoneNumberController,
                    ),
                    SizedBox(
                      height: 25,
                      child: Text(
                        phoneNumberError,
                        style: TextStyle(color: Colors.red[200]),
                      ),
                    ),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: sendCodeButton(),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2.0),
                                  ),
                                  labelText: 'کد دریافتی',
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                controller: verificationCodeController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25,
                      child: Text(
                        verificationCodeError,
                        style: TextStyle(color: Colors.red[200]),
                      ),
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFF20BFA9),
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: ArgonButton(
                        height: 50,
                        width: 400,
                        borderRadius: 5.0,
                        color: Color(0xFF20BFA9),
                        child: Text(
                          "تایید",
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
                          bool isQualified = true;
                          if(phoneNumberController.text.isNotEmpty &&
                              phoneNumberController.text[0] == '0')
                            phoneNumberController.text =
                                phoneNumberController.text.substring(1);
                          setState(() {
                            phoneNumberError = verificationCodeError = '';
                            if (phoneNumberController.text.isEmpty){
                              phoneNumberError = 'شماره موبایل الزامی است';
                              isQualified = false;
                            }
                            else if(phoneNumberController.text.length != 10){
                              phoneNumberError =
                              'فرمت شماره همراه اشتباه است';
                              isQualified = false;
                            }
                            if (verificationCodeController.text.isEmpty){
                              verificationCodeError =
                              'کد ارسال شده به همراهتان را وارد کنید';
                              isQualified = false;
                            }
                          });
                          if(isQualified){
                            startLoading();
                            await registerPhoneNumber();
                            stopLoading();
                          }
                        }
                      ),
                      // child: TextButton(
                      //   onPressed: () async {
                      //     bool isQualified = true;
                      //     if(phoneNumberController.text.isNotEmpty &&
                      //         phoneNumberController.text[0] == '0')
                      //       phoneNumberController.text =
                      //           phoneNumberController.text.substring(1);
                      //     setState(() {
                      //       phoneNumberError = verificationCodeError = '';
                      //       if (phoneNumberController.text.isEmpty){
                      //         phoneNumberError = 'شماره موبایل الزامی است';
                      //         isQualified = false;
                      //       }
                      //       else if(phoneNumberController.text.length != 10){
                      //         phoneNumberError =
                      //         'فرمت شماره همراه اشتباه است';
                      //         isQualified = false;
                      //       }
                      //       if (verificationCodeController.text.isEmpty){
                      //         verificationCodeError =
                      //         'کد ارسال شده به همراهتان را وارد کنید';
                      //         isQualified = false;
                      //       }
                      //     });
                      //     if(isQualified)
                      //       await registerPhoneNumber();
                      //   },
                      //   child: Text(
                      //     'تایید',
                      //     style: TextStyle(
                      //       fontSize: 20,
                      //       fontWeight: FontWeight.bold,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    else
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(65, 65, 65, 0),
            child: Center(
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'جهت ثبت نام موارد زیر را کامل کنید',
                        style:
                            TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 28.0),
                      child: IntrinsicHeight(
                        child: Row(
                          // crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextField(
                                style: TextStyle(
                                    decorationColor: Colors.black,
                                    color: Colors.white),
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2.0),
                                  ),
                                  border: OutlineInputBorder(),
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  labelText: 'نام کاربری',
                                ),
                                controller: userNameController,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: ArgonButton(
                                  height: 50,
                                  width: 400,
                                  minWidth: 400,
                                  borderRadius: 5.0,
                                  color: Colors.red[700],
                                  child: Text(
                                    "بررسی",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
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
                                    if(userNameController.text == '') {
                                      Fluttertoast.showToast(msg: 'نام کاربری را وارد کنید');
                                      return;
                                    }
                                    if(btnState == ButtonState.Idle) {
                                      startLoading();
                                        setState(() {
                                          if (!isCheckingUserName) {
                                            isCheckingUserName = true;
                                          }
                                        });
                                        await isUserNameRepetitive(
                                            userNameController.text);
                                        setState(() {
                                          isCheckingUserName = false;
                                        });
                                      stopLoading();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                      child: Text(
                        userNameError,
                        style: TextStyle(color: Colors.red[200]),
                      ),
                    ),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: TextField(
                                onChanged: (text){
                                  if(text.length >= 6)
                                    setState(() {
                                      passwordError = '';
                                    });
                                },
                                style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2.0),
                                  ),
                                  labelText: 'رمز عبور',
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                controller: passwordController,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: TextField(
                                onChanged: (text){
                                  if(text != passwordController.text)
                                    setState(() {
                                      passwordError = 'رمز عبور مطابقت ندارد';
                                    });
                                  else
                                    setState(() {
                                      passwordError = '';
                                    });
                                },
                                focusNode: focusRepeatPassword,
                                style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2.0),
                                  ),
                                  labelText: 'تکرار رمز عبور',
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                controller: confirmPasswordController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25,
                      child: Text(
                        passwordError,
                        style: TextStyle(color: Colors.red[200]),
                      ),
                    ),
                    // IntrinsicHeight(
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    //     children: <Widget>[
                    //       Expanded(
                    //         child: Padding(
                    //           padding: const EdgeInsets.only(left: 4.0),
                    //           child: TextField(
                    //             style: TextStyle(color: Colors.white),
                    //             keyboardType: TextInputType.text,
                    //             decoration: InputDecoration(
                    //               contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    //               border: OutlineInputBorder(),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderSide: BorderSide(
                    //                     color: Colors.white, width: 2.0),
                    //               ),
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderSide: BorderSide(
                    //                     color: Colors.white, width: 2.0),
                    //               ),
                    //               labelText: 'نام',
                    //               labelStyle: TextStyle(
                    //                 color: Colors.white,
                    //               ),
                    //             ),
                    //             controller: firstNameController,
                    //           ),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: Padding(
                    //           padding: const EdgeInsets.only(right: 4.0),
                    //           child: TextField(
                    //             style: TextStyle(color: Colors.white),
                    //             keyboardType: TextInputType.text,
                    //             decoration: InputDecoration(
                    //               contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    //               border: OutlineInputBorder(),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderSide: BorderSide(
                    //                     color: Colors.white, width: 2.0),
                    //               ),
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderSide: BorderSide(
                    //                     color: Colors.white, width: 2.0),
                    //               ),
                    //               labelText: 'نام خانوادگی',
                    //               labelStyle: TextStyle(
                    //                 color: Colors.white,
                    //               ),
                    //             ),
                    //             controller: lastNameController,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 25,
                    // ),
                    // IntrinsicHeight(
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    //     children: <Widget>[
                    //       Expanded(
                    //         child: Padding(
                    //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //           child: DropdownButton(
                    //             dropdownColor: Color(0xFF44434C),
                    //             value: employmentStatus,
                    //             style: TextStyle(color: Colors.white),
                    //             onChanged: (String newValue) {
                    //               setState(() {
                    //                 employmentStatus = newValue;
                    //               });
                    //               switch(newValue){
                    //                 case 'شاغل':
                    //                   isEmployed = true;
                    //                   break;
                    //                 case 'جویای کار':
                    //                   isEmployed = false;
                    //                   break;
                    //                 case 'اشتغال':
                    //                   isEmployed = null;
                    //               }
                    //             },
                    //             items: <String>['اشتغال', 'شاغل', 'جویای کار']
                    //                 .map<DropdownMenuItem<String>>((String value) {
                    //               return DropdownMenuItem<String>(
                    //                 value: value,
                    //                 child: Text(value),
                    //               );
                    //             }).toList(),
                    //           ),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: Padding(
                    //           padding: const EdgeInsets.only(right: 4.0),
                    //           child: TextField(
                    //             style: TextStyle(color: Colors.white),
                    //             keyboardType: TextInputType.text,
                    //             decoration: InputDecoration(
                    //               contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    //               border: OutlineInputBorder(),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderSide: BorderSide(
                    //                     color: Colors.white, width: 2.0),
                    //               ),
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderSide: BorderSide(
                    //                     color: Colors.white, width: 2.0),
                    //               ),
                    //               labelText: 'شهر محل سکونت',
                    //               labelStyle: TextStyle(
                    //                 color: Colors.white,
                    //                 fontSize: 14
                    //               ),
                    //             ),
                    //             controller: cityController,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 25,
                    // ),
                    // IntrinsicHeight(
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    //     children: <Widget>[
                    //       Expanded(
                    //         child: Padding(
                    //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //           child: DropdownButton(
                    //             dropdownColor: Color(0xFF44434C),
                    //             value: genderString,
                    //             style: TextStyle(color: Colors.white),
                    //             onChanged: (String newValue) {
                    //               setState(() {
                    //                 genderString = newValue;
                    //               });
                    //               switch(newValue){
                    //                 case 'مذکر':
                    //                   gender = Gender.Male;
                    //                   break;
                    //                 case 'مونث':
                    //                   gender = Gender.Female;
                    //                   break;
                    //                 case 'جنسیت':
                    //                   gender = Gender.Default;
                    //                   break;
                    //               }
                    //             },
                    //             items: <String>['جنسیت', 'مذکر', 'مونث']
                    //                 .map<DropdownMenuItem<String>>((String value) {
                    //               return DropdownMenuItem<String>(
                    //                 value: value,
                    //                 child: Text(value),
                    //               );
                    //             }).toList(),
                    //           ),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: Padding(
                    //           padding: const EdgeInsets.only(right: 4.0),
                    //           child: TextField(
                    //             style: TextStyle(color: Colors.white),
                    //             keyboardType: TextInputType.number,
                    //             decoration: InputDecoration(
                    //               contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    //               border: OutlineInputBorder(),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderSide: BorderSide(
                    //                     color: Colors.white, width: 2.0),
                    //               ),
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderSide: BorderSide(
                    //                     color: Colors.white, width: 2.0),
                    //               ),
                    //               labelText: 'سن',
                    //               labelStyle: TextStyle(
                    //                   color: Colors.white,
                    //               ),
                    //             ),
                    //             controller: ageController,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 25,
                    // ),
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(0xFF20BFA9),
                      ),
                      child: ArgonButton(
                        height: 50,
                        width: 400,
                        borderRadius: 5.0,
                        color: Color(0xFF20BFA9),
                        child: Text(
                          "تایید",
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
                          bool isQualified = true;
                          setState(() {
                            userNameError = passwordError = '';
                            if (userNameController.text.isEmpty){
                              userNameError = 'نام کاربری الزامی است';
                              isQualified = false;
                            }
                            if (passwordController.text.isEmpty){
                              passwordError = 'رمز عبور الزامی است';
                              isQualified = false;
                            }
                            else if (confirmPasswordController.text.isEmpty ||
                                passwordController.text !=
                                    confirmPasswordController.text){
                              passwordError = 'رمز عبور مطابقت ندارد';
                              isQualified = false;
                            }
                          });
                          if(isQualified){
                            startLoading();
                            if(await signUp()) {
                              stopLoading();
                              Navigator.pop(context);
                            }
                            stopLoading();
                          }
                        },
                      ),
                      // child: TextButton(
                      //   onPressed: () async {
                      //     bool isQualified = true;
                      //     setState(() {
                      //       userNameError = passwordError = '';
                      //       if (userNameController.text.isEmpty){
                      //         userNameError = 'نام کاربری الزامی است';
                      //         isQualified = false;
                      //       }
                      //       if (passwordController.text.isEmpty){
                      //         passwordError = 'رمز عبور الزامی است';
                      //         isQualified = false;
                      //       }
                      //       else if (confirmPasswordController.text.isEmpty ||
                      //           passwordController.text !=
                      //               confirmPasswordController.text){
                      //         passwordError = 'رمز عبور مطابقت ندارد';
                      //         isQualified = false;
                      //       }
                      //     });
                      //     if(isQualified)
                      //       await signUp();
                      //   },
                      //   child: Text(
                      //     'تایید',
                      //     style: TextStyle(
                      //       fontSize: 20,
                      //       fontWeight: FontWeight.bold,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);

    return Scaffold(
      body: authForm(formName),
      persistentFooterButtons: formName != FormName.RegisterPhoneNumber ?
        <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 12,
            child: Card(
              color: formName == FormName.SignIn
                  ? Color(0xFF20BFA9)
                  : Color(0xFF202028),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    formName = FormName.SignIn;
                  });
                },
                child: Text(
                  'ورود',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 12,
          child: Card(
            color: (formName == FormName.SignUp ||
                    formName == FormName.RegisterPhoneNumber)
                ? Color(0xFF20BFA9)
                : Color(0xFF202028),
            child: TextButton(
              onPressed: () {
                setState(() {
                  formName = FormName.SignUp;
                });
              },
              child: Text(
                'ثبت نام',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        ] :
        <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Card(
              color: (formName == FormName.SignUp ||
                  formName == FormName.RegisterPhoneNumber)
                  ? Color(0xFF20BFA9)
                  : Color(0xFF202028),
              child: TextButton(
                onPressed: () {
                },
                child: Text(
                  'ثبت شماره همراه',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ]
      ,
    );
  }
}
