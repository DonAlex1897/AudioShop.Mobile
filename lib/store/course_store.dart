import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/models/basket.dart';
import 'package:mobile/models/config.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/services/authentication_service.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:mobile/services/discount_service.dart';
import 'package:mobile/shared/enums.dart';


var audioManagerInstance = AudioManager.instance;
HashMap<String, String> audioCache;
class CourseStore extends ChangeNotifier{

  List<Course> _courses = [];
  Basket _basket;
  Course _currentCourse;
  int _totalBasketPrice = 0;
  List<CourseEpisode> _userEpisodes =[];
  int _playingEpisodeId = 0;

  String _userId;
  String _userName;
  String _token;
  bool _isLoggedIn = false;
  bool _hasPhoneNumber = false;
  String _salespersonCouponCode;

  int _salespersonDefaultDiscountPercent = 0;

  CourseStore(){
    notifyListeners();
  }

  List<Course> get courses => _courses;
  Basket get basket => _basket;
  Course get currentCourse => _currentCourse;
  int get totalBasketPrice => _totalBasketPrice;
  List<CourseEpisode> get userEpisodes => _userEpisodes;
  int get playingEpisodeId => _playingEpisodeId;

  String get userId => _userId;
  String get userName => _userName;
  String get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasPhoneNumber => _hasPhoneNumber;
  String get salespersonCouponCode => _salespersonCouponCode;

  int get salespersonDefaultDiscountPercent => _salespersonDefaultDiscountPercent;

  setAllCourses(List<Course> allCourses){
    this._courses = allCourses;
  }

  setCurrentCourse(Course tapedCourse){
    this._currentCourse = tapedCourse;
  }

  // bool addCourseToBasket(Course toBeAddedCourse){
  //   Course similarCourse = _basket
  //       .firstWhere((x) => x.id == toBeAddedCourse.id, orElse: () => null);
  //
  //   if(similarCourse == null) {
  //     _basket.add(toBeAddedCourse);
  //     notifyListeners();
  //     return true;
  //   }
  //   return false;
  // }

  // deleteCourseFromBasket(Course toBeDeletedCourse){
  //   _basket.remove(toBeDeletedCourse);
  //   notifyListeners();
  // }

  setTotalBasketPrice(int totalPrice){
    this._totalBasketPrice = totalPrice;
  }

  bool isTokenExpired(String receivedToken){
    _isLoggedIn = JwtDecoder.isExpired(receivedToken);
    return _isLoggedIn;
  }

  Future setUserDetails(String receivedToken, bool hasPhoneNumber, String salespersonCouponCode) async{

    Map<String, dynamic> decodedToken = JwtDecoder.decode(receivedToken);

    if(receivedToken != ""){
      _userId = decodedToken['nameid'];
      _userName = decodedToken['unique_name'];
      AuthenticationService authService = AuthenticationService();
      _userEpisodes = await authService.getUserEpisodes(_userId, receivedToken);
    }
    else{
      _userId = '';
      _userName = '';
      _userEpisodes != null ?? _userEpisodes.clear();
    }

    _salespersonCouponCode = salespersonCouponCode;
    _hasPhoneNumber = hasPhoneNumber;
    _token = receivedToken;

  }

  // refineUserBasket(List<Course> refinedBasket) {
  //   if(refinedBasket.isNotEmpty && refinedBasket.length > 0)
  //     this._basket = refinedBasket;
  //   else
  //     this._basket.clear();
  // }

  setPlayingEpisode(int episodeId){
    this._playingEpisodeId = episodeId;
  }

  Future setUserBasket(List<CourseEpisode> episodes, Course course) async{
    if(this._basket == null)
      this._basket = Basket();

    DiscountService discountService = DiscountService();
    this._basket.userId = this.userId;
    this._basket.salespersonCouponCode = this._salespersonCouponCode;
    List<int> episodesIds = [];
    for(var episode in episodes){
      episodesIds.add(episode.id);
    }
    this._basket.episodeIds = episodesIds;
    int salespersonDiscountPercent = await discountService.salespersonDiscountPercent(this._salespersonCouponCode);
    if(salespersonDiscountPercent > 0)
      this._salespersonDefaultDiscountPercent = salespersonDiscountPercent;

    if(course != null){
      this._basket.totalPrice = course.price;
      this._basket.discount = course.price * this._salespersonDefaultDiscountPercent;
      this._basket.priceToPay = course.price - this._basket.discount;
    }
    else{
      double price = 0;
      episodes.forEach((episode) {
        price += episode.price;
      });

      this._basket.totalPrice = price;
      this._basket.discount = price * this._salespersonDefaultDiscountPercent;
      this._basket.priceToPay = price - this._basket.discount;
    }
  }

  setConfigs(List<Config> configs){
    var config = configs.firstWhere((x) => x.titleEn == 'SalespersonDefaultDiscountPercent');
    if(config != null)
      this._salespersonDefaultDiscountPercent = int.parse(config.value);

  }
}