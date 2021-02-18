import 'dart:convert';

import 'package:http/http.dart' as http;

class DiscountService{

  DiscountService();

  String baseUrl = 'http://10.0.2.2:5000/api/';

  Future<int> salespersonDiscountPercent(String couponCode) async{
    String url = baseUrl + 'coupons/$couponCode/IsSalespersonCoupon';
    try{
      http.Response response = await http.get(url);
      if(response.statusCode == 200){
        String data = response.body;
        int percent = jsonDecode(data);
        return percent;
      }
      else{
        print(response.statusCode);
        return 0;
      }
    }
    catch(e){
      print(e.toString());
      return 0;
    }
  }

  Future<int> couponDiscountPercent(String couponCode, String token) async {
    String url = baseUrl + 'member/canUseCoupon/$couponCode';
    try{
      // http.Response response = await http.get(url);
      http.Response response = await http.get(Uri.encodeFull(url),
          // body: body,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          });
      if(response.statusCode == 200){
        String data = response.body;
        int percent = jsonDecode(data);
        return percent;
      }
      else{
        print(response.statusCode);
        return 0;
      }
    }
    catch(e){
      print(e.toString());
      return 0;
    }
  }
}