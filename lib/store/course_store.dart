import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/models/ads.dart';
import 'package:mobile/models/ads_place.dart';
import 'package:mobile/models/basket.dart';
import 'package:mobile/models/configuration.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/models/favorite.dart';
import 'package:mobile/models/in_progress_course.dart';
import 'package:mobile/models/progress.dart';
import 'package:mobile/screens/now_playing.dart';
import 'package:mobile/services/ads_service.dart';
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

  bool _isAdsEnabled = false;
  bool _isPopUpEnabled = false;
  bool _homePageFull = false;
  bool _coursePreviewTopBanner = false;
  bool _homePageBelowSliderBanner = false;
  bool _profileNative = false;
  bool _libraryNative = false;
  bool _homePageNative = false;
  bool _loadingDownNative = false;
  bool _loadingUpNative = false;
  bool _psychologicalTestsFull = false;
  bool _supportPageFull = false;
  bool _addSalesPersonCouponCodeFull = false;
  bool _signUpFull = false;
  bool _nowPlayingFull = false;
  bool _loginProfileFull = false;
  bool _loginFavoritesFull = false;
  bool _loginCartFull = false;
  bool _coursePageFull = false;
  bool _coursePreviewFull = false;
  bool _coursePreviewBelowAddToFavoriteBanner = false;
  bool _homePageTopOfSliderBanner = false;

  Ads _homePageFullAds;
  Ads _coursePreviewTopBannerAds;
  Ads _homePageBelowSliderBannerAds;
  Ads _profileNativeAds;
  Ads _libraryNativeAds;
  Ads _homePageNativeAds;
  Ads _loadingDownNativeAds;
  Ads _loadingUpNativeAds;
  Ads _psychologicalTestsFullAds;
  Ads _supportPageFullAds;
  Ads _addSalesPersonCouponCodeFullAds;
  Ads _signUpFullAds;
  Ads _nowPlayingFullAds;
  Ads _loginProfileFullAds;
  Ads _loginFavoritesFullAds;
  Ads _loginCartFullAds;
  Ads _coursePageFullAds;
  Ads _coursePreviewFullAds;
  Ads _coursePreviewBelowAddToFavoriteBannerAds;
  Ads _homePageTopOfSliderBannerAds;

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

  bool get isAdsEnabled => _isAdsEnabled;
  bool get isPopUpEnabled => _isPopUpEnabled;
  bool get homePageFull => _homePageFull;
  bool get coursePreviewTopBanner => _coursePreviewTopBanner;
  bool get homePageBelowSliderBanner => _homePageBelowSliderBanner;
  bool get profileNative => _profileNative;
  bool get libraryNative => _libraryNative;
  bool get homePageNative => _homePageNative ;
  bool get loadingDownNative => _loadingDownNative;
  bool get loadingUpNative => _loadingUpNative;
  bool get psychologicalTestsFull => _psychologicalTestsFull;
  bool get supportPageFull => _supportPageFull;
  bool get addSalesPersonCouponCodeFull => _addSalesPersonCouponCodeFull;
  bool get signUpFull => _signUpFull;
  bool get nowPlayingFull => _nowPlayingFull;
  bool get loginProfileFull => _loginProfileFull;
  bool get loginFavoritesFull => _loginFavoritesFull;
  bool get loginCartFull => _loginCartFull;
  bool get coursePageFull => _coursePageFull;
  bool get coursePreviewFull => _coursePreviewFull;
  bool get coursePreviewBelowAddToFavoriteBanner => _coursePreviewBelowAddToFavoriteBanner;
  bool get homePageTopOfSliderBanner => _homePageTopOfSliderBanner;

  Ads get homePageFullAds => _homePageFullAds;
  Ads get coursePreviewTopBannerAds => _coursePreviewTopBannerAds;
  Ads get homePageBelowSliderBannerAds => _homePageBelowSliderBannerAds;
  Ads get profileNativeAds => _profileNativeAds;
  Ads get libraryNativeAds => _libraryNativeAds;
  Ads get homePageNativeAds => _homePageNativeAds ;
  Ads get loadingDownNativeAds => _loadingDownNativeAds;
  Ads get loadingUpNativeAds => _loadingUpNativeAds;
  Ads get psychologicalTestsFullAds => _psychologicalTestsFullAds;
  Ads get supportPageFullAds => _supportPageFullAds;
  Ads get addSalesPersonCouponCodeFullAds => _addSalesPersonCouponCodeFullAds;
  Ads get signUpFullAds => _signUpFullAds;
  Ads get nowPlayingFullAds => _nowPlayingFullAds;
  Ads get loginProfileFullAds => _loginProfileFullAds;
  Ads get loginFavoritesFullAds => _loginFavoritesFullAds;
  Ads get loginCartFullAds => _loginCartFullAds;
  Ads get coursePageFullAds => _coursePageFullAds;
  Ads get coursePreviewFullAds => _coursePreviewFullAds;
  Ads get coursePreviewBelowAddToFavoriteBannerAds => _coursePreviewBelowAddToFavoriteBannerAds;
  Ads get homePageTopOfSliderBannerAds => _homePageTopOfSliderBannerAds;

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
    config = configs.firstWhere((x) => x.titleEn == 'IsAdsEnabled', orElse: () => null);
    if(config != null)
      this._isAdsEnabled = config.value == '1';
    config = configs.firstWhere((x) => x.titleEn == 'IsPopUpEnabled', orElse: () => null);
    if(config != null)
      this._isPopUpEnabled = config.value == '1';
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

  Future setAdsSituation() async {
    AdsService adsService = AdsService();
    List<AdsPlace> adsPlaceList = await adsService.getAdsPlaces();
    for(var element in adsPlaceList) {
      switch(element.titleEn){
        case 'HomePage':
          if(element.isEnabled)
            this._homePageFullAds = await adsService.getAds('HomePage');
          this._homePageFull = element.isEnabled;
          break;
        case 'CoursePreview-Top':
          if(element.isEnabled)
            this._coursePreviewTopBannerAds = await adsService.getAds('CoursePreview-Top');
          this._coursePreviewTopBanner = element.isEnabled;
          break;
        case 'HomePage-BelowSlider':
          if(element.isEnabled)
            this._homePageBelowSliderBannerAds = await adsService.getAds('HomePage-BelowSlider');
          this._homePageBelowSliderBanner = element.isEnabled;
          break;
        case 'Profile':
          if(element.isEnabled)
            this._profileNativeAds = await adsService.getAds('Profile');
          this._profileNative = element.isEnabled;
          break;
        case 'Library':
          if(element.isEnabled)
            this._libraryNativeAds = await adsService.getAds('Library');
          this._libraryNative = element.isEnabled;
          break;
        case 'HomePage':
          if(element.isEnabled)
            this._homePageNativeAds = await adsService.getAds('HomePage');
          this._homePageNative = element.isEnabled;
          break;
        case 'Loading-down':
          if(element.isEnabled)
            this._loadingDownNativeAds = await adsService.getAds('Loading-down');
          this._loadingDownNative = element.isEnabled;
          break;
        case 'Loading-up':
          if(element.isEnabled)
            this._loadingUpNativeAds = await adsService.getAds('Loading-up');
          this._loadingUpNative = element.isEnabled;
          break;
        case 'PsycologicalTests':
          if(element.isEnabled)
            this._psychologicalTestsFullAds = await adsService.getAds('PsycologicalTests');
          this._psychologicalTestsFull = element.isEnabled;
          break;
        case 'SupportPage':
          if(element.isEnabled)
            this._supportPageFullAds = await adsService.getAds('SupportPage');
          this._supportPageFull = element.isEnabled;
          break;
        case 'AddSalesPersonCuponCode':
          if(element.isEnabled)
            this._addSalesPersonCouponCodeFullAds = await adsService.getAds('AddSalesPersonCuponCode');
          this._addSalesPersonCouponCodeFull = element.isEnabled;
          break;
        case 'SignUp':
          if(element.isEnabled)
            this._signUpFullAds = await adsService.getAds('SignUp');
          this._signUpFull = element.isEnabled;
          break;
        case 'NowPlaying':
          if(element.isEnabled)
            this._nowPlayingFullAds = await adsService.getAds('NowPlaying');
          this._nowPlayingFull = element.isEnabled;
          break;
        case 'Login-Profile':
          if(element.isEnabled)
            this._loginProfileFullAds = await adsService.getAds('Login-Profile');
          this._loginProfileFull = element.isEnabled;
          break;
        case 'Login-Favorites':
          if(element.isEnabled)
            this._loginFavoritesFullAds = await adsService.getAds('Login-Favorites');
          this._loginFavoritesFull = element.isEnabled;
          break;
        case 'Login-Cart':
          if(element.isEnabled)
            this._loginCartFullAds = await adsService.getAds('Login-Cart');
          this._loginCartFull = element.isEnabled;
          break;
        case 'CoursePage':
          if(element.isEnabled)
            this._coursePageFullAds = await adsService.getAds('CoursePage');
          this._coursePageFull = element.isEnabled;
          break;
        case 'CoursePreview':
          if(element.isEnabled)
            this._coursePreviewFullAds = await adsService.getAds('CoursePreview');
          this._coursePreviewFull = element.isEnabled;
          break;
        case 'CoursePreview-BelowAddToFavorite':
          if(element.isEnabled)
            this._coursePreviewBelowAddToFavoriteBannerAds = await adsService.getAds('CoursePreview-BelowAddToFavorite');
          this._coursePreviewBelowAddToFavoriteBanner = element.isEnabled;
          break;
        case 'HomePage-TopOfSilder':
          if(element.isEnabled)
            this._homePageTopOfSliderBannerAds = await adsService.getAds('HomePage-TopOfSilder');
          this._homePageTopOfSliderBanner = element.isEnabled;
          break;
      }
    }
  }
}