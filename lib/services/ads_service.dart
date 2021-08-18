import 'dart:convert';

import 'package:mobile/models/ads.dart';
import 'package:mobile/models/ads_place.dart';
import 'package:mobile/shared/global_variables.dart';
import 'package:http/http.dart' as http;


class AdsService{
  String adsUrl = GlobalVariables.baseUrl + 'api/ads/';
  String adsFileUrl = GlobalVariables.baseUrl + 'ads/';
  AdsService();

  Future<List<AdsPlace>> getAdsPlaces() async{
    try{
      http.Response response = await http.get(adsUrl + 'places');
      if(response.statusCode == 200){
        String data = response.body;
        var adsPlaceMap = jsonDecode(data);
        List<AdsPlace> adsPlaceList = [];
        for(var adsPlace in adsPlaceMap){
          adsPlaceList.add(AdsPlace.fromJson(adsPlace));
        }
        return adsPlaceList;
      }
      else{
        print(response.statusCode);
        return null;
      }
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  Future<Ads> getAds(String titleEn) async{
    try{
      http.Response response = await http.get(adsUrl + 'titles/'+ titleEn);
      if(response.statusCode == 200){
        String data = response.body;
        var adsMap = jsonDecode(data);
        Ads ads = Ads.fromJson(adsMap, adsFileUrl);
        return ads;
      }
      else{
        print(response.statusCode);
        return null;
      }
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }
}