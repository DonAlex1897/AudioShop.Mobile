import 'dart:convert';

import 'package:http/http.dart' as http;

class DiscountService{

  DiscountService();

  String baseCouponUrl = 'http://10.0.2.2:5000/api/coupons/';

  Future<int> salespersonDiscountPercent(String couponCode) async{
    String url = baseCouponUrl + '$couponCode/IsSalespersonCoupon';
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
}