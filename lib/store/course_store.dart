import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/models/basket.dart';
import 'package:mobile/models/configuration.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/models/in_progress_course.dart';
import 'package:mobile/services/authentication_service.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:mobile/services/discount_service.dart';


var audioManagerInstance = AudioManager.instance;
HashMap<String, String> audioCache;
class CourseStore extends ChangeNotifier{

  List<Course> _courses = [];
  Basket _basket;
  Course _currentCourse;
  int _totalBasketPrice = 0;
  List<CourseEpisode> _userEpisodes =[];
  List<Course> _userFavoriteCourses = [];
  int _playingEpisodeId = 0;
  List<InProgressCourse> _inProgressCourses = [];

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
  List<Course> get userFavoriteCourses => _userFavoriteCourses;
  int get playingEpisodeId => _playingEpisodeId;
  List<InProgressCourse> get inProgressCourses => _inProgressCourses;

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
      if(_userEpisodes != null)
          _userEpisodes.clear();
    }

    _salespersonCouponCode = salespersonCouponCode;
    _hasPhoneNumber = hasPhoneNumber;
    _token = receivedToken;

  }

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
      if(episode.price != 0 && episode.price != null)
        episodesIds.add(episode.id);
    }
    this._basket.episodeIds = episodesIds;
    if(this._salespersonCouponCode != null){
      int salespersonDiscountPercent = await discountService.salespersonDiscountPercent(this._salespersonCouponCode);
      if(salespersonDiscountPercent > 0)
        this._salespersonDefaultDiscountPercent = salespersonDiscountPercent;
    }
    else
      this._salespersonDefaultDiscountPercent = 0;

    if(course != null){
      this._basket.totalPrice = course.price;
      this._basket.discount = course.price
          * this._salespersonDefaultDiscountPercent / 100;
      this._basket.priceToPay = course.price - this._basket.discount;
    }
    else{
      double price = 0;
      episodes.forEach((episode) {
        price += episode.price;
      });

      this._basket.totalPrice = price;
      this._basket.discount = price * this._salespersonDefaultDiscountPercent / 100;
      this._basket.priceToPay = price - this._basket.discount;
    }
  }

  applyCouponCodeDiscount(int discountPercent){
    double newDiscount = this._basket.totalPrice * discountPercent/100;
    this._basket.discount += newDiscount;
    this._basket.priceToPay -= newDiscount;
  }

  setOtherCouponCodeInBasket(String couponCode){
    this._basket.otherCouponCode = couponCode;
  }

  setConfigs(List<Configuration> configs){
    var config = configs.firstWhere((x) => x.titleEn == 'DefaultDiscountPercentage', orElse: () => null); //TODO change the titleEn in database to SalespersonDefaultDiscountPercent
    if(config != null)
      this._salespersonDefaultDiscountPercent = int.parse(config.value);
  }

  bool addToUserFavoriteCourses(Course course){
    Course repetitiveCourse = this._userFavoriteCourses
        .firstWhere((element) => element.id == course.id, orElse: () => null);
    if(repetitiveCourse == null) {
      this._userFavoriteCourses.add(course);
      return true;
    }
    else{
      this._userFavoriteCourses.remove(repetitiveCourse);
      return false;
    }
  }

  updateInProgressCourses(int courseId, int episodeSortNumber, int waitingTime){
      InProgressCourse testInProgressEpisode = this._inProgressCourses
          .firstWhere((element) => element.courseId == courseId, orElse: () => null);
      DateTime currentTime = DateTime.now();
      if(testInProgressEpisode != null){
        this._inProgressCourses.firstWhere((element) => element.courseId == courseId)
          .lastFinishedEpisodeSortNumber = episodeSortNumber;
        this._inProgressCourses.firstWhere((element) => element.courseId == courseId)
            .lastFinishedEpisodeTime = currentTime;
      }
      else{
        InProgressCourse newInProgressEpisode = InProgressCourse(
          courseId: courseId,
          lastFinishedEpisodeSortNumber: episodeSortNumber,
          waitingTimeBetweenEpisodes: waitingTime,
          lastFinishedEpisodeTime: currentTime,
        );
        this._inProgressCourses.add(newInProgressEpisode);
      }
  }

  bool isEpisodeAccessible(int courseId, int episodeSortNumber, int waitingTime){
    InProgressCourse testInProgressEpisode = this._inProgressCourses
        .firstWhere((element) => element.courseId == courseId, orElse: () => null);
    if(testInProgressEpisode == null && episodeSortNumber != 0){
      Fluttertoast.showToast(msg: 'لطفا دوره را از ابتدا شروع کنید');
      return false;
    }
    else if(testInProgressEpisode != null){
      int sortDifference = episodeSortNumber - testInProgressEpisode.lastFinishedEpisodeSortNumber;
      String nextEpisode = (testInProgressEpisode.lastFinishedEpisodeSortNumber + 2).toString();
      if(sortDifference > 0){
        if(sortDifference > 1){
          Fluttertoast.showToast(msg: 'هنوز قسمت $nextEpisode را گوش نداده اید');
          return false;
        }
        else{
          DateTime currentTime = DateTime.now();
          int timeElapsedSinceLastEpisode = currentTime
              .difference(testInProgressEpisode.lastFinishedEpisodeTime).inHours;
          if(timeElapsedSinceLastEpisode < waitingTime){
            int remainedTimeToWait = waitingTime - timeElapsedSinceLastEpisode;
            Fluttertoast.showToast(msg: 'زمان انتظار بین هر دو قسمت در این دوره، $waitingTime است.'
                ' این قسمت $remainedTimeToWait ساعت دیگر در دسترس شما قرار میگیرد');
            return false;
          }
        }
      }
    }
    return true;
  }
}