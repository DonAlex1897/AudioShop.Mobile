import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
              child: Card(
                color: Color(0xFF403F44),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Text('مبلغ اصلی (بدون تخفیف)'),
                          Text(courseStore.basket.totalPrice.toString()),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Text('تخفیف شما از این خرید'),
                          Text(courseStore.basket.discount.toString()),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Text('مبلغ قابل پرداخت'),
                          Text(courseStore.basket.priceToPay.toString()),
                        ],
                      ),
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
