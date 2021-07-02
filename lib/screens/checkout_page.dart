import 'dart:convert';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mobile/services/discount_service.dart';
import 'package:mobile/services/payment_service.dart';
import 'package:mobile/services/statistics_service.dart';
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
  final currencyFormat = new NumberFormat("#,##0");
  bool isAgree = false;
  StatisticsService statisticsService = StatisticsService();


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
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: (!isVerifyButtonPressed) ? Colors.red[700] : Colors.red[200],
        ),
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
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Card(
            color: Color(0xFF20BFA9),
            child: ArgonButton(
              height: 50,
              width: 400,
              borderRadius: 5.0,
              color: Color(0xFF20BFA9),
              child: Text(
                'پرداخت نهایی',
                style: TextStyle(color: Colors.white),
              ),
              roundLoadingShape: false,
              loader: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SpinKitRing(
                  color: Colors.white,
                  lineWidth: 4,
                ),
              ),
              onTap:(startLoading, stopLoading, btnState) async {
                startLoading();
                bool payWithPanel = false;

                AlertDialog alert = AlertDialog(
                  backgroundColor: Colors.white70,
                  title: Text(
                    'پرداخت نهایی',
                    style: TextStyle(color: Colors.black),),
                  content: Text(
                    'پرداخت از طریق کارت به کارت و یا ورود به درگاه '
                        'پرداخت امکان پذیر می باشد.'
                        'لطفا گزینه مورد نظر خود را انتخاب کنید.',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    textAlign: TextAlign.justify,
                  ),

                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: 400,
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5),

                        ),
                        child: TextButton(
                          onPressed: (){
                            payWithPanel = false;
                            Navigator.of(context).pop();
                          },
                          child:
                          Text(
                              'کارت به کارت',
                              style: TextStyle(color: Colors.black,)
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 400,
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5),

                      ),
                      child: TextButton(
                        onPressed: (){
                          payWithPanel = true;
                          Navigator.of(context).pop();
                        },
                        child:
                        Text(
                            'درگاه پرداخت',
                            style: TextStyle(color: Colors.black,)
                        ),
                      ),
                    ),
                  ],
                );
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
                if(payWithPanel) {
                  AlertDialog alert2 = AlertDialog(
                    scrollable: true,
                    backgroundColor: Colors.white70,
                    title: Text(
                      'درباره زرین پال',
                      style: TextStyle(color: Colors.black),),
                    content: Column(
                      children: [
                        Text(
                          'زرین‌پال، اولین پرداخت‌یار پیشگامِ کشور است که'
                              ' با سبک و استانداردهای جدید، سرویس‌های'
                              ' پرداخت الکترونیک را برای کسب‌ وکارها'
                              ' ارائه کرده است. ما هر روزه، میلیاردها'
                              ' تومان را در بستر وبِ کشور، بدون کوچک‌‌‌‌‌ترین '
                              'خطایی به گردش درمی‌آوریم، با این هدف که در'
                              ' افزایش سهم تجارت الکترونیکی در تولید'
                              ' ناخالص ملی و کمک به رشد و توسعه‌ی کسب'
                              ' وکارها، نقش سازنده و موثری داشته باشیم.',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                          textAlign: TextAlign.justify,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 28.0),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: InkWell(
                                child: Image.asset('assets/images/Etemad.png'),
                                onTap: () async {
                                  // String zarinPalUrl = 'https://www.zarinpal.com/aboutus.html';
                                  // try{
                                  //   await launch(zarinPalUrl);
                                  // }
                                  // catch(e){
                                  //   print(e.toString());
                                  //   Fluttertoast.showToast(msg: 'خطا در ارتباط با سایت');
                                  // }
                                },
                              )
                          ),
                        ),
                      ],
                    ),

                    actions: [
                      Container(
                        width: 400,
                        height: 70,
                        decoration: BoxDecoration(
                          //border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xFF20BFA9)
                        ),
                        child: TextButton(
                          onPressed: (){
                            isAgree = true;
                            Navigator.of(context).pop();
                          },
                          child:
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,20,0),
                            child: Text(
                                'انتقال به درگاه پرداخت',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18
                                ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  );
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert2;
                    },
                  );
                  if(isAgree) {
                    orderJson = await createOrder();
                    String paymentPageUrl =
                    await orderService.payOrder(orderJson);
                    try {
                      statisticsService.enteredPaymentPage();
                      await launch(paymentPageUrl);
                    } catch (e) {
                      print(e.toString());
                      Fluttertoast.showToast(
                          msg: 'خطا در انتقال به درگاه پرداخت');
                    } finally {
                      SystemNavigator.pop();
                    }
                  }
                }
                else{
                  orderJson = await createOrder();
                  var orderMap = jsonDecode(orderJson);

                  AlertDialog alert3 = AlertDialog(
                    scrollable: true,
                    backgroundColor: Colors.white70,
                    title: Text(
                      'پرداخت کارت به کارت',
                      style: TextStyle(color: Colors.black),),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'لطفا پس از پرداخت مبلغ سفارش، '
                              'رسید پرداخت و شماره سفارش خود را به پشتیبانی '
                              'ارسال کنید.',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ' شماره سفارش:',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                              textAlign: TextAlign.justify,
                            ),
                            InkWell(
                              onTap: (){
                                Clipboard.setData(ClipboardData
                                  (text: orderMap['id'].toString()));
                                Fluttertoast.showToast(msg: 'شماره سفارش کپی شد');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black45),
                                  borderRadius: BorderRadius.circular(5),
                                  //color: Color(0xFF403F44),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 8
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5.0),
                                        child: Icon(
                                          Icons.copy,
                                          color: Colors.black45,
                                          size: 14,
                                        ),
                                      ),
                                      Text(
                                        'کپی',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black45),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: (){
                            Clipboard.setData(ClipboardData
                              (text: orderMap['id'].toString()));
                            Fluttertoast.showToast(msg: 'شماره سفارش کپی شد');
                          },
                          child: Text(
                            orderMap['id'].toString(),
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(height: 20,),
                        Divider(
                          color: Colors.black54,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'مبلغ قابل پرداخت:',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                              textAlign: TextAlign.justify,
                            ),
                            InkWell(
                              onTap: (){
                                Clipboard.setData(ClipboardData
                                  (text: courseStore.basket.priceToPay.toString()));
                                Fluttertoast.showToast(msg: 'مبلغ سفارش کپی شد.');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black45),
                                  borderRadius: BorderRadius.circular(5),
                                  //color: Color(0xFF403F44),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 8
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5.0),
                                        child: Icon(
                                          Icons.copy,
                                          color: Colors.black45,
                                          size: 14,
                                        ),
                                      ),
                                      Text(
                                        'کپی',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black45),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: (){
                            Clipboard.setData(ClipboardData
                              (text: courseStore.basket.priceToPay.toString()));
                            Fluttertoast.showToast(msg: 'مبلغ سفارش کپی شد.');
                          },
                          child: Text(
                            currencyFormat.format(courseStore.basket.priceToPay/10000)
                                + ' هزار تومان',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(height: 20,),
                        Divider(
                          color: Colors.black54,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'شماره کارت (سیاوش آریا):',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                              textAlign: TextAlign.justify,
                            ),
                            InkWell(
                              onTap: (){
                                Clipboard.setData(ClipboardData
                                  (text: '5022123456789090'));
                                Fluttertoast.showToast(msg: 'شماره کارت کپی شد');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black45),
                                  borderRadius: BorderRadius.circular(5),
                                  //color: Color(0xFF403F44),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 8
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5.0),
                                        child: Icon(
                                          Icons.copy,
                                          color: Colors.black45,
                                          size: 14,
                                        ),
                                      ),
                                      Text(
                                        'کپی',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black45),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: (){
                            Clipboard.setData(ClipboardData
                              (text: '5022123456789090'));
                            Fluttertoast.showToast(msg: 'شماره کارت کپی شد');
                          },
                          child: Text(
                            '5022 - 1234 - 5678 - 9090',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            textAlign: TextAlign.left,
                            textDirection: ui.TextDirection.ltr,
                          ),
                        ),
                        SizedBox(height: 30,),
                        Center(
                          child: Text(
                            'ارتباط با پشتیبانی:',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),

                        SizedBox(height: 5,),
                        Container(
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.white60)
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextButton(
                                    onPressed: () async{
                                      String chatUrl = 'https://telegram.me/StarShow_ir';
                                      //if (await canLaunch(chatUrl)){
                                      try{
                                        await launch(chatUrl);
                                      }
                                      catch(e){
                                        print(e.toString());
                                      }
                                    },
                                    child: Image.asset('assets/images/telegram.png'),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextButton(
                                    onPressed: () async{
                                      String chatUrl = 'https://instagram.com/starshow_ir?utm_medium=copy_link';
                                      //if (await canLaunch(chatUrl)){
                                      try{
                                        await launch(chatUrl);
                                      }
                                      catch(e){
                                        print(e.toString());
                                      }
                                      //}
                                    },
                                    child: Image.asset('assets/images/instagram.png'),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextButton(
                                    onPressed: () async{
                                      String chatUrl = 'https://api.whatsapp.com/send/?phone=989108860897&text&app_absent=0';
                                      // if (await canLaunch(chatUrl)){
                                      try{
                                        await launch(chatUrl);
                                      }
                                      catch(e){
                                        print(e.toString());
                                      }
                                    },
                                    child: Image.asset('assets/images/whatsapp.png'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5,),
                        Container(
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.white60)
                          ),
                          child: TextButton(
                            onPressed: () async{
                              String chatUrl = 'tel://${courseStore.supportPhoneNumber}';
                              //if (await canLaunch(chatUrl)){
                              try{
                                await launch(chatUrl);
                              }
                              catch(e){
                                print(e.toString());
                              }
                              //}
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'تلفن تماس اِستارشو',
                                          style: TextStyle(fontSize: 16, color: Colors.black),),
                                        Text(
                                          courseStore.supportPhoneNumber,
                                          style: TextStyle(fontSize: 16, color: Colors.black),),
                                      ],
                                    )
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Image.asset('assets/images/phone.png'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert3;
                    },
                  );
                }


                stopLoading();
              },
            ),
            // child: TextButton(
            //     onPressed: () async {
            //       orderJson = await createOrder();
            //       String paymentPageUrl = await orderService.payOrder(orderJson);
            //       if (await canLaunch(paymentPageUrl)){
            //         try{
            //           await launch(paymentPageUrl);
            //         }
            //         catch(e){
            //           print(e.toString());
            //         }
            //         finally{
            //           SystemNavigator.pop();
            //         }
            //       }
            //       else
            //         Fluttertoast.showToast(msg: 'خطا در انتقال به درگاه پرداخت');
            //     },
            //     child: Text(
            //       'پرداخت نهایی',
            //       style: TextStyle(color: Colors.white),
            //     ),
            // ),
          ),
        ),
      ],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                      child: Image.asset(
                        'assets/images/purchase.png',
                        width: MediaQuery.of(context).size.width * 0.6,
                      ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
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
                              child: Container(
                                height: 40,
                                child: TextField(
                                  style: TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.text,
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
                                    labelText: 'کد تخفیف',
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  controller: discountCodeController,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0, left: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xFF403F44),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: SizedBox(
                                height: 100,
                                child: Column(
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
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: SizedBox(
                                height: 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Text(currencyFormat.format(courseStore.basket.totalPrice/10000) + " هزار تومان"),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Text(currencyFormat.format(courseStore.basket.discount/10000) + " هزار تومان"),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Text(currencyFormat.format(courseStore.basket.priceToPay/10000) + " هزار تومان"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
