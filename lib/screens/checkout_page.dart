import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/services/discount_service.dart';
import 'package:mobile/services/payment_service.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckOutPage extends StatefulWidget {

  CheckOutPage();

  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  CourseStore courseStore;
  PaymentService orderService = PaymentService();
  String orderJson = '';
  bool isVerifyButtonPressed = false;
  bool isCouponCodeVerified = false;
  TextEditingController discountCodeController = TextEditingController();
  DiscountService discountService = DiscountService();

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  Future<String> createOrder() async{
    return await orderService.createOrder(
        courseStore.basket,
        courseStore.userId,
        courseStore.token
    );
  }

  Widget verifyCodeButton() {
    return Card(
      color: (!isVerifyButtonPressed) ? Colors.red[700] : Colors.red[200],
      child: TextButton(
        onPressed: () async {
          if(!isVerifyButtonPressed){
            setState(() {
              isVerifyButtonPressed = true;
            });
            isCouponCodeVerified = await verifyDiscountCode();
            if(isCouponCodeVerified)
              courseStore.setOtherCouponCodeInBasket(discountCodeController.text);
          }
        },
        child: Text(
          (!isVerifyButtonPressed) ? 'اعمال کد' : 'کد اعمال شد',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<bool> verifyDiscountCode() async{
    int discountPercent = await discountService
        .couponDiscountPercent(discountCodeController.text, courseStore.token);
    if(discountPercent > 0){
      setState(() {
        courseStore.applyCouponCodeDiscount(discountPercent);
      });
      Fluttertoast.showToast(msg: 'کد تخفیف با موفقیت اعمال شد');
      return true;
    }
    else if(discountPercent == -1){
      Fluttertoast.showToast(msg: 'کد وارد شده صحیح نیست');
      setState(() {
        isVerifyButtonPressed = false;
      });
      return false;
    }
    else if(discountPercent == -2){
      Fluttertoast.showToast(msg: 'زمان اعتبار کد به پایان رسیده است');
      setState(() {
        isVerifyButtonPressed = false;
      });
      return false;
    }
    else if(discountPercent == -3){
      Fluttertoast.showToast(msg: 'شما قبلا از این کد استفاده کرده اید');
      setState(() {
        isVerifyButtonPressed = false;
      });
      return false;
    }
    else{
      Fluttertoast.showToast(msg: 'خطا در اعمال کد تخفیف');
      setState(() {
        isVerifyButtonPressed = false;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);


    return Scaffold(
      persistentFooterButtons: [
        TextButton(
            onPressed: () async {
              orderJson = await createOrder();
              String paymentPageUrl = await orderService.payOrder(orderJson);
              if (await canLaunch(paymentPageUrl)){
                try{
                  await launch(paymentPageUrl);
                }
                catch(e){
                  print(e.toString());
                }
                finally{
                  SystemNavigator.pop();
                }
              }
              else
                Fluttertoast.showToast(msg: 'خطا در انتقال به درگاه پرداخت');
            },
            child: Text(
              'پرداخت نهایی'
            ),
        ),
      ],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                        child: Text('توضیحات در مورد درگاه پرداخت'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: verifyCodeButton(),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.white, width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.white, width: 2.0),
                          ),
                          labelText: 'کد تخفیف',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        controller: discountCodeController,
                      ),
                    ),
                  ],
                ),
              ),),
            Expanded(
              flex: 1,
              child: Card(
                color: Color(0xFF403F44),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Text('مبلغ اصلی (بدون تخفیف)'),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Text('تخفیف شما از این خرید'),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Text('مبلغ قابل پرداخت'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Text(courseStore.basket.totalPrice.toString() + "   تومان"),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Text(courseStore.basket.discount.toString() + "   تومان"),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Text(courseStore.basket.priceToPay.toString() + "   تومان"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
