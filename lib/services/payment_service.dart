import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/models/basket.dart';

class PaymentService{

  PaymentService();

  String createOrderUrl = 'https://95.216.229.251/api/orders';
  String payOrderUrl = 'https://95.216.229.251/api/payment/payorder';

  Future<String> createOrder(Basket basket, String userId, String token) async {
    var body = jsonEncode({
      'userId': userId,
      'totalPrice': basket.totalPrice,
      'discount': basket.discount,
      'priceToPay': basket.priceToPay,
      'otherCouponCode': basket.otherCouponCode,
      'episodeIds': basket.episodeIds,
      'SalespersonCouponCode': basket.salespersonCouponCode,
    });

    http.Response response = await http.post(Uri.encodeFull(createOrderUrl),
        body: body,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
          "Authorization": "Bearer $token",
        });

    if(response.statusCode == 200){
      String data = response.body;
      // var orderMap = jsonDecode(data);
      // Order verifiedOrder = Order.fromJson(orderMap);
      return data;
    }
    else{
      print(response.statusCode);
      return null;
    }
  }

  Future<String> payOrder(String orderJson) async{
    http.Response response = await http.post(Uri.encodeFull(payOrderUrl),
        body: orderJson,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
        });

    if(response.statusCode == 302){
      String location = response.headers['location'];
      return location;
    }
    else{
      return null;
    }
  }
}