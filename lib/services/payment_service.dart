import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/basket.dart';
import 'package:mobile/shared/global_variables.dart';

class PaymentService{

  PaymentService();

  String createOrderUrl = GlobalVariables.baseUrl + 'api/orders';
  String payOrderUrl = GlobalVariables.baseUrl + 'api/payment/payorder?orderId=';
  Future<String> createOrder(Basket basket, String userId, String token) async {
    try {
      var body = jsonEncode({
        'userId': userId,
        'totalPrice': basket.totalPrice,
        'discount': basket.discount,
        'priceToPay': basket.priceToPay,
        'otherCouponCode': basket.otherCouponCode,
        'episodeIds': basket.episodeIds != null ? basket.episodeIds : [],
        'salespersonCouponCode': basket.salespersonCouponCode,
        'orderType': basket.orderType != null ? basket.orderType : 0
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
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> payOrder(String orderJson) async{
    try {
      http.Response response = await http.post(payOrderUrl+orderJson);

      if(response.statusCode == 302){
        String location = response.headers['location'];
        return location;
      }
      else{
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}