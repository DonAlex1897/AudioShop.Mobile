import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  String discountPercent;
  String descriptionText = '';

  @override
  Future<void> didChangeDependencies() async {
    courseStore = Provider.of<CourseStore>(context);
    await getDiscountPercent();
    await setDescriptionText();
    super.didChangeDependencies();
  }

  Future setDescriptionText() async{
    setState(() {
      if(discountPercent != null)
        descriptionText =
            'کد معرف فعلی شما ' + courseStore.salespersonCouponCode +
                ' می باشد و به صورت پیشفرض از هر خرید ' + discountPercent +
                ' درصد تخفیف، شامل حال شما خواهد شد';
      else
        descriptionText =
            'کد معرف فعلی شما ' + courseStore.salespersonCouponCode +
                ' می باشد و به صورت پیشفرض از هر خرید '
                + courseStore.salespersonDefaultDiscountPercent.toString() +
                ' درصد تخفیف، شامل حال شما خواهد شد';
    });
  }

  Future getDiscountPercent() async{
    DiscountService discountService = DiscountService();
    int tempDiscountPercent =
          await discountService
            .salespersonDiscountPercent(courseStore.salespersonCouponCode);
    setState(() {
      discountPercent = tempDiscountPercent.toString();
    });
  }

  Future addSalespersonCouponCode(String salespersonCouponCode) async{
    int tempDiscountPercent = await discountService
        .salespersonDiscountPercent(salespersonCouponCode);
    if(tempDiscountPercent < 0){
      Fluttertoast.showToast(msg: 'کد وارد شده معتبر نیست');
      return;
    }
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


      await getDiscountPercent();
      await setDescriptionText();

      Fluttertoast.showToast(
          msg: 'کد معرف با موفقیت ثبت شد');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('ثبت کد معرف'),
      ),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(65.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(courseStore.salespersonCouponCode == null ||
                     courseStore.salespersonCouponCode == '' ?
                  'در صورت در اختیار داشتن کد معرف آن را وارد کنید '
                    'تا از تخفیف ها و مزایای آن بهره مند شوید' : descriptionText,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 45,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: 200,
                        child: TextField(
                          style: TextStyle(
                              decorationColor: Colors.black, color: Colors.white),
                          keyboardType: TextInputType.text,
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
                          ),
                          controller: couponCodeController,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 200,
                        child: Card(
                          color: Color(0xFF20BFA9),
                          child: TextButton(
                              onPressed: () async{
                                await addSalespersonCouponCode(couponCodeController.text);
                              },
                              child:
                              Text(courseStore.salespersonCouponCode == null ||
                                  courseStore.salespersonCouponCode == '' ?
                              'افزودن کد معرف' : 'تغییر کد معرف',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              )
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
