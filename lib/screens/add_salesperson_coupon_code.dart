import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/services/discount_service.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';

class AddSalesPersonCouponCode extends StatefulWidget {
  @override
  _AddSalesPersonCouponCodeState createState() => _AddSalesPersonCouponCodeState();
}

class _AddSalesPersonCouponCodeState extends State<AddSalesPersonCouponCode> {
  TextEditingController couponCodeController = TextEditingController();
  DiscountService discountService = DiscountService();
  CourseStore courseStore;
  FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future addSalespersonCouponCode(String salespersonCouponCode) async{
    User user = await discountService
        .setSalespersonCouponCode(couponCodeController.text, courseStore.token);

    if (user == null)
      Fluttertoast.showToast(
          msg: 'اشکال در ثبت کد معرف.');
    else {
      await secureStorage.write(
          key: 'token',
          value: user.token);
      await secureStorage.write(
          key: 'hasPhoneNumber',
          value: user.hasPhoneNumber.toString());
      await secureStorage.write(
          key: 'salespersonCouponCode',
          value: user.salespersonCouponCode);

      await courseStore.setUserDetails(
          user.token, user.hasPhoneNumber, user.salespersonCouponCode);

      Fluttertoast.showToast(
          msg: 'کد معرف با موفقیت ثبت شد');
    }
  }

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('ثبت کد معرف'),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'در صورت در اختیار داشتن کد معرف آن را وارد کنید '
                      'تا از تخفیف ها و مزایای آن بهره مند شوید',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 45,
                  ),
                  TextField(
                    style: TextStyle(
                        decorationColor: Colors.black, color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
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
                    ),
                    controller: couponCodeController,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Card(
                    color: Color(0xFF20BFA9),
                    child: TextButton(
                      onPressed: () async{
                        await addSalespersonCouponCode(couponCodeController.text);
                      },
                      child: Text(
                        'تایید کد معرف',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      )
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
