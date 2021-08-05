import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/models/basket.dart';
import 'package:mobile/models/configuration.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/models/favorite.dart';
import 'package:mobile/models/in_progress_course.dart';
import 'package:mobile/models/progress.dart';
import 'package:mobile/screens/now_playing.dart';
import 'package:mobile/services/authentication_service.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:mobile/services/course_service.dart';
import 'package:mobile/services/discount_service.dart';
import 'package:mobile/services/user_service.dart';


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
  List<Progress> _inProgressCourses = [];
  String _userId;
  String _userName;
  String _token;
  bool _isLoggedIn = false;
  bool _hasPhoneNumber = false;
  String _salespersonCouponCode;
  int _salespersonDefaultDiscountPercent = 0;
  String _supportPhoneNumber = '';
  List<Favorite> _favoriteCourses = [];


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
  List<Progress> get inProgressCourses => _inProgressCourses;
  String get userId => _userId;
  String get userName => _userName;
  String get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasPhoneNumber => _hasPhoneNumber;
  String get salespersonCouponCode => _salespersonCouponCode;
  int get salespersonDefaultDiscountPercent => _salespersonDefaultDiscountPercent;
  String get supportPhoneNumber => _supportPhoneNumber;
  List<Favorite> get favoriteCourses => _favoriteCourses;

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
    config = configs.firstWhere((x) => x.titleEn == 'PhoneNumber', orElse: () => null);
    if(config != null)
      this._supportPhoneNumber = config.value;
  }

  Future<Progress> setCourseProgress(int courseId, String token) async{
    Progress tempInProgressEpisode = this._inProgressCourses
        .firstWhere((element) => element.courseId == courseId, orElse: () => null);
    if(tempInProgressEpisode == null){
      UserService userService = UserService();
      Progress progress = await userService.getCourseProgress(courseId, token);
      if(progress != null && progress.id != 0)
        this._inProgressCourses.add(progress);
    }
    return _inProgressCourses
        .firstWhere((element) => element.courseId == courseId, orElse: () => null);
  }

  bool isEpisodeAccessible(int courseId, int episodeSortNumber, bool shouldWaitOneDay){
    Progress tempInProgressEpisode = this._inProgressCourses
        .firstWhere((element) => element.courseId == courseId, orElse: () => null);
    if(tempInProgressEpisode == null && episodeSortNumber != 0){
      Fluttertoast.showToast(msg: 'لطفا دوره را از ابتدا شروع کنید');
      return false;
    }
    else if(tempInProgressEpisode != null){
      int sortDifference = episodeSortNumber - tempInProgressEpisode.lastIndex;
      String nextEpisode = (tempInProgressEpisode.lastIndex + 2).toString();
      if(sortDifference > 0){
        if(sortDifference > 1){
          Fluttertoast.showToast(msg: 'هنوز قسمت $nextEpisode را گوش نداده اید');
          return false;
        }
        else if (shouldWaitOneDay){
          DateTime currentTime = DateTime.now();
          if(currentTime.day <= tempInProgressEpisode.lastListened.day){
            Fluttertoast.showToast(msg: 'این دوره به صورت روزانه تعریف شده است. '
                'هر روز فقط یک قسمت را می توانید گوش کنید.');
            return false;
          }
        }
      }
    }
    return true;
  }

  bool isEpisodePlayedBefore(CourseEpisode episode){
    Progress tempInProgressEpisode = this._inProgressCourses
        .firstWhere((element) => element.courseId == episode.courseId, orElse: () => null);
    if(tempInProgressEpisode != null && tempInProgressEpisode.lastIndex >= episode.sort){
      return true;
    }
    return false;
  }

  Future<bool> updateCourseProgress(int courseId, int episodeId, int episodeSortNumber) async{
    Progress tempInProgressEpisode = this._inProgressCourses
        .firstWhere((element) => element.courseId == courseId, orElse: () => null);
    DateTime currentTime = DateTime.now();
    if(tempInProgressEpisode != null){
      Progress progress = Progress(
        id: tempInProgressEpisode.id,
        userId: tempInProgressEpisode.userId,
        courseId: tempInProgressEpisode.courseId,
        lastEpisodeId: episodeId,
        lastIndex: episodeSortNumber,
        lastListened: currentTime
      );

      UserService userService = UserService();
      if(!await userService.updateCourseProgress(
          courseId,
          progress,
          token)){
        Fluttertoast.showToast(msg: 'مشکل در ارتباط با سرور. لطفا مجددا تلاش کنید.');
        return false;
      }
      this._inProgressCourses.removeWhere((element) => element.courseId == courseId);
      this._inProgressCourses.add(progress);
      return true;
    }
    else{
      Progress newInProgressEpisode = Progress(
        userId: _userId,
        courseId: courseId,
        lastIndex: episodeSortNumber,
        lastEpisodeId: episodeId,
        lastListened: currentTime,
      );
      UserService userService = UserService();
      Progress progress = await userService.createCourseProgress(
          courseId,
          newInProgressEpisode,
          token);
      if(progress != null && progress.id == 0){
        Fluttertoast.showToast(msg: 'مشکل در ارتباط با سرور. لطفا مجددا تلاش کنید.');
        return false;
      }
      newInProgressEpisode.id = progress.id;
      this._inProgressCourses.add(newInProgressEpisode);
      return true;
    }
  }

  Future setUserFavoriteCourses(List<Favorite> favorites) async{
    CourseData courseData = CourseData();
    if(favorites != null && favorites.length > 0){
      favorites.forEach((element) async {
        Course course = await courseData.getCourseById(element.courseId);
        this._userFavoriteCourses.add(course);
        this._favoriteCourses.add(element);
      });
    }
  }

  Future<Favorite> addToUserFavoriteCourses(Course course) async{
    UserService userService = UserService();
    Favorite repetitiveFavorite = this._favoriteCourses
        .firstWhere((element) => element.courseId == course.id, orElse: () => null);

    if(repetitiveFavorite == null) {
      Favorite favorite = Favorite(
        userId: this._userId,
        courseId: course.id
      );
      Favorite finalFavorite = await userService.addCourseToUserFavorites(favorite, token);
      if(finalFavorite == null){
        Fluttertoast.showToast(msg: 'اشکال در ارتباط با سرور. لطفا'
            'مجدد تلاش کنید');
        return null;
      }
      // this._userFavoriteCourses.add(course);
      this._favoriteCourses.add(finalFavorite);
      Fluttertoast.showToast(msg: 'دوره به علاقه مندی های شما افزوده شد');
      return finalFavorite;
    }
    else {
      if(!await userService.deleteCourseFromUserFavorites(repetitiveFavorite.id, token)){
        Fluttertoast.showToast(msg: 'اشکال در ارتباط با سرور. لطفا'
            'مجدد تلاش کنید');
        return null;
      }
      // this._userFavoriteCourses.remove(course);
      this._favoriteCourses.remove(repetitiveFavorite);
      Fluttertoast.showToast(msg: 'دوره از علاقه مندی های شما حذف شد');
      return repetitiveFavorite;
    }
  }

  updateUserFavoriteCourses(Course course){
    Course repetitiveFavoriteCourse = this._userFavoriteCourses
        .firstWhere((element) => element.id == course.id, orElse: () => null);

    if(repetitiveFavoriteCourse == null){
      this._userFavoriteCourses.add(course);
    }
    else{
      this._userFavoriteCourses.remove(course);
    }
  }
}