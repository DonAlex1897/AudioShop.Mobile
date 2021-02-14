import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/models/basket.dart';
import 'package:mobile/models/config.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/services/authentication_service.dart';
import 'package:audio_manager/audio_manager.dart';
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

  double _defaultSalespersonDiscountPercentage = 0;

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

  double get defaultSalespersonDiscountPercentage => _defaultSalespersonDiscountPercentage;

  setAllCourses(List<Course> allCourses){
    this._courses = allCourses;
  }

  setCurrentCourse(Course tapedCourse){
    this._currentCourse = tapedCourse;
  }

  bool addCourseToBasket(Course toBeAddedCourse){
    Course similarCourse = _basket
        .firstWhere((x) => x.id == toBeAddedCourse.id, orElse: () => null);

    if(similarCourse == null) {
      _basket.add(toBeAddedCourse);
      notifyListeners();
      return true;
    }
    return false;
  }

  deleteCourseFromBasket(Course toBeDeletedCourse){
    _basket.remove(toBeDeletedCourse);
    notifyListeners();
  }

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

  refineUserBasket(List<Course> refinedBasket) {
    if(refinedBasket.isNotEmpty && refinedBasket.length > 0)
      this._basket = refinedBasket;
    else
      this._basket.clear();
  }

  setPlayingEpisode(int episodeId){
    this._playingEpisodeId = episodeId;
  }

  setUserBasket(List<CourseEpisode> episodes, Course course, String salespersonCouponCode){
    if(course != null){
      _basket.totalPrice = course.price;
      _basket.
    }
    else{

    }
  }

  setConfigs(List<Config> configs){
    var config = configs.firstWhere((x) => x.titleEn == 'DefaultSalespersonDiscountPercentage');
    if(config != null)
      this._defaultSalespersonDiscountPercentage = double.parse(config.value);

  }
}