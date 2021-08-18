import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/models/favorite.dart';
import 'package:mobile/models/progress.dart';
import 'package:mobile/models/review.dart';
import 'package:mobile/screens/authentication_page.dart';
import 'package:mobile/screens/checkout_page.dart';
import 'package:mobile/screens/course_page.dart';
import 'package:mobile/screens/review_page.dart';
import 'package:mobile/services/course_episode_service.dart';
import 'package:mobile/services/course_service.dart';
import 'package:mobile/services/statistics_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/store/course_store.dart';
import 'package:mobile/utilities/Utility.dart';
import 'package:mobile/utilities/banner_ads.dart';
import 'package:mobile/utilities/native_ads.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'dart:ui' as ui;
import 'package:async/async.dart';
import 'package:http/http.dart' as http;

import 'advertisement_page.dart';

class CoursePreview extends StatefulWidget {

  CoursePreview(this.courseDetails);
  final Course courseDetails;
  @override
  _CoursePreviewState createState() => _CoursePreviewState();
}

class _CoursePreviewState extends State<CoursePreview> {
  Future<List<Review>> courseReviews;
  List<Review> courseReviewList;
  int totalReviewsCount = 0;
  CourseData courseData = CourseData();
  TextEditingController reviewController = TextEditingController();
  CourseStore courseStore;
  double yourRate = 0;
  double averageCourseRate = 0;
  String favoriteButtonText = 'افزودن دوره به علاقه مندی ها';
  final secureStorage = FlutterSecureStorage();
  String sendButtonText = 'ارسال';
  double sendButtonSize = 20;
  Color sendButtonColor = Color(0xFF20BFA9);
  bool isWholeCourseAvailable = true;
  bool alertReturn = false;
  bool isTakingMuchTime = false;
  Duration _timerDuration = new Duration(seconds: 15);
  IconData favoriteIcon = Icons.favorite_border;
  var pictureFile;
  bool isSendingReview = false;
  bool isVpnConnected = false;
  int nonFreeEpisodesCount = 0;
  int purchasedEpisodesCount = 0;
  double totalEpisodesPrice = 0;
  final currencyFormat = new NumberFormat("#,##0");
  StatisticsService statisticsService = StatisticsService();
  RestartableTimer _timer;
  bool showLoadingUpAds = false;
  bool showLoadingDownAds = false;
  bool showAdsInPopUp = true;


  @override
  void initState() {
    super.initState();
    courseReviews = getCourseReviews();
    statisticsService.enteredCoursePage(widget.courseDetails.id);
  }

  @override
  void didChangeDependencies() async{
    super.didChangeDependencies();
    courseStore = Provider.of<CourseStore>(context);
    Progress courseProgress = await courseStore.setCourseProgress(
        widget.courseDetails.id, courseStore.token);
    if(courseProgress != null && courseProgress.id == 0){
      Fluttertoast.showToast(msg: 'اشکال در برقراری ارتباط با سرور');
      Navigator.of(context).pop();
    }
  }

  Future<List<Review>> getCourseReviews() async{

    pictureFile = widget.courseDetails.photoAddress != '' ?
      await DefaultCacheManager().getSingleFile(widget.courseDetails.photoAddress):
      null;

    _timer = RestartableTimer(_timerDuration, setTimerState);
    List reviewsResult =
      await courseData.getCourseReviews(widget.courseDetails.id);
    totalReviewsCount = reviewsResult[0];
    courseReviewList = reviewsResult[1];
    int allReviewsRateSum = 0;
    if(courseReviewList != null){
      courseReviewList.forEach((element) {
        allReviewsRateSum += element.rating;
      });
      averageCourseRate = allReviewsRateSum / courseReviewList.length;
    }
    CourseEpisodeData courseEpisodeData = CourseEpisodeData();
    List<CourseEpisode> courseEpisodes =
      await courseEpisodeData.getCourseEpisodes(widget.courseDetails.id);

    courseEpisodes.forEach((episode) {
      if(episode.price != 0 && episode.price != null){
        totalEpisodesPrice += episode.price;
        nonFreeEpisodesCount++;
      }

      if(courseStore.userEpisodes != null){
        for(CourseEpisode tempEpisode in courseStore.userEpisodes){
          if(tempEpisode.id == episode.id)
          {
            purchasedEpisodesCount++;
            break;
          }
        }
      }
    });
    return courseReviewList;
  }

  Future postReview() async{
    setState(() {
      sendButtonSize = 18;
      sendButtonColor = Color(0xff2afcdd);
    });
    Review review = Review(
      userId: courseStore.userId,
      text: reviewController.text,
      rating: yourRate.toInt(),
      courseId: widget.courseDetails.id,
      userFirstName: courseStore.userName
    );
    if(courseStore.token != '' && courseStore.token != null){
      bool sentReview = await courseData.addReviewToCourse(review, courseStore.token);
      setState(() {
        isSendingReview = false;
      });
      if(sentReview){
        Widget cancelB = cancelButton('باشه');
        AlertDialog alert = AlertDialog(
          title: Text('توجه'),
          content: Text('نظر شما با موفقیت ثبت شد و پس از تایید نمایش داده می شود.'),
          actions: [cancelB],
        );
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
        reviewController.text = '';
        // if(courseStore.isAdsEnabled){
        //   Utility.showAdsAlertDialog(
        //     context,
        //     NavigatedPage.AddReview,
        //   );
        // }
      }
    }
    else{
      setState(() {
        isSendingReview = false;
      });
      Widget cancelB = cancelButton('بعدا');
      Widget continueB = continueButton('ورود', null, FormName.SignIn);
      AlertDialog alert = AlertDialog(
        title: Text('توجه'),
        content: Text('برای ثبت نظر باید وارد حساب کاربریتان شوید'),
        actions: [cancelB, continueB],
      );
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    setState(() {
      isSendingReview = false;
      sendButtonText = 'ارسال';
      sendButtonSize = 20;
      sendButtonColor = Color(0xFF20BFA9);
    });
  }

  Future<List<CourseEpisode>> eliminateRepetitiveEpisodes(List<CourseEpisode> episodes) async{

    List<CourseEpisode> basketEpisodes = List.from(episodes);
    List<int> courseEpisodeIds = List<int>();
    basketEpisodes.forEach((episode) {
      courseEpisodeIds.add(episode.id);
    });
    courseStore.userEpisodes.forEach((episode) {
      if(courseEpisodeIds.contains(episode.id)){
        basketEpisodes.removeWhere((ep) => ep.id == episode.id);
        isWholeCourseAvailable = false;
      }
    });
    basketEpisodes.removeWhere((ep) => ep.price == 0);

    return basketEpisodes;
  }

  Future createBasket(Course course) async{
    List<CourseEpisode> episodes = List<CourseEpisode>();
    CourseEpisodeData courseEpisodeData = CourseEpisodeData();
    episodes = await courseEpisodeData.getCourseEpisodes(course.id);

    if(courseStore.token != null && courseStore.token != ''){
        List<CourseEpisode> episodesToBePurchased = [];
        for(var episode in episodes){
          if(episode.price != null || episode.price != 0)
            episodesToBePurchased.add(episode);
        }
        List<CourseEpisode> finaleEpisodeIds =
          await eliminateRepetitiveEpisodes(episodesToBePurchased);
        if(course.price == 0){
          Fluttertoast
              .showToast(msg: 'این دوره رایگان می باشد');
          return;
        }
        else if(finaleEpisodeIds.length == 0){
          Fluttertoast
              .showToast(msg: 'شما این دوره را به طور کامل خریداری کرده اید');
          return;
        }
        await courseStore.setUserBasket(finaleEpisodeIds, course /*isWholeCourseAvailable ? course : null*/);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return CheckOutPage();
            })
        );
    }
    else{
      bool goToSignUpPage = false;
      AlertDialog alert = AlertDialog(
        title: Text('توجه'),
        content: Text('برای خرید دوره آموزشی، ابتدا باید ثبت نام کنید'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              width: 400,
              height: 40,
              decoration: BoxDecoration(
                //border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5),
                color: Color(0xFF20BFA9),
              ),
              child: TextButton(
                onPressed: (){
                  goToSignUpPage = true;
                  Navigator.of(context).pop();
                },
                child:
                Text(
                    'ثبت نام',
                    style: TextStyle(color: Colors.white,)
                ),
              ),
            ),
          ),
          Container(
            width: 400,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70),
              borderRadius: BorderRadius.circular(5),

            ),
            child: TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child:
              Text(
                  'انصراف',
                  style: TextStyle(color: Colors.white70,)
              ),
            ),
          ),
        ],
      );
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      if(goToSignUpPage)
        if(!courseStore.isAdsEnabled){
          Navigator.push(context,
              MaterialPageRoute(builder: (context) {
                return AuthenticationPage(FormName.SignUp);
              }));
        }
        else if(courseStore.signUpFull && courseStore.signUpFullAds != null &&
            courseStore.signUpFullAds.isEnabled){
          if(!courseStore.isPopUpEnabled){
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AdvertisementPage(
                navigatedPage: NavigatedPage.SignUpPurchase,
                ads: courseStore.signUpFullAds,
              );
            }));
          }
          else{
            Utility.showAdsAlertDialog(
                context,
                NavigatedPage.SignUpPurchase,
                courseStore.signUpFullAds
            );
          }
        }
        else{
          Navigator.push(context,
              MaterialPageRoute(builder: (context) {
                return AuthenticationPage(FormName.SignUp);
              }));
        }
    }
  }

  Widget coursePurchaseButton(Course course){
    if(nonFreeEpisodesCount == purchasedEpisodesCount)
      return SizedBox();
    else
      return
        TextButton(
          onPressed: () async{
            await createBasket(course);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.add_shopping_cart,
                  color: Colors.white,
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    'خریــــد  کــــامل  دوره',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18
                    ),
                  ),
                ),
              )
            ],
          ),
        );
  }

  Widget priceTagWidget(){
    if(nonFreeEpisodesCount == purchasedEpisodesCount)
      return SizedBox();
    else
      return
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'قیمت دوره کامل:',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'قیمت دوره (قسمت به قسمت):',
                      style: TextStyle(color: Colors.red),),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      currencyFormat.format(widget.courseDetails.price/10000).toString() + " هزار تومان",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      currencyFormat.format(totalEpisodesPrice/10000).toString() + " هزار تومان",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
          // Column(
          //   children: [
          //     Text(
          //       'قیمت خرید دوره بصورت کامل: ${currencyFormat.format(widget.courseDetails.price)} ریال',
          //       style: TextStyle(color: Colors.red),
          //     ),
          //     Text('قیمت خرید دوره بصورت قسمت به قسمت: ${currencyFormat.format(totalEpisodesPrice)} ریال' )
          //   ],
          // );
  }

  Widget cancelButton(String cancelText){
    return TextButton(
      child: Text(cancelText, style: TextStyle(color: Colors.white),),
      onPressed: () {
        Navigator.of(context).pop();
        alertReturn = false;
      },
    );
  }

  Widget continueButton(String continueText, Alert alert, FormName formName){
    if(alert != null)
      return TextButton(
        child: Text(continueText, style: TextStyle(color: Colors.white),),
        onPressed: () {
          Navigator.of(context).pop();
          alertReturn = true;
        },
      );
    else{
      return TextButton(
        child: Text(continueText, style: TextStyle(color: Colors.white),),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AuthenticationPage(formName);
          }));
        },
      );
    }
  }

  AlertDialog alert(String titleText, String contentText, List<Widget> actions){
    return AlertDialog(
      title: Text(titleText),
      content: Text(contentText),
      actions: actions,
    );
  }

  Future showBasketAlertDialog(BuildContext context, AlertDialog alert) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget spinner(){
    return Scaffold(
        body: !isTakingMuchTime ? Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                courseStore.isAdsEnabled &&
                    courseStore.loadingUpNative &&  courseStore.loadingUpNativeAds != null &&
                    courseStore.loadingUpNativeAds.isEnabled ?
                NativeAds(courseStore.loadingUpNativeAds) : SizedBox(),
                SpinKitWave(
                  type: SpinKitWaveType.center,
                  color: Color(0xFF20BFA9),
                  size: 65.0,
                ),
                courseStore.isAdsEnabled &&
                    courseStore.loadingDownNative &&  courseStore.loadingDownNativeAds != null &&
                    courseStore.loadingDownNativeAds.isEnabled ?
                NativeAds(courseStore.loadingDownNativeAds) : SizedBox(),
              ],
            ),
          ),
        ) :
        Center(
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Container(
                  //     width: MediaQuery.of(context).size.width * 0.7,
                  //     child: Image.asset('assets/images/internetdown.png')
                  // ),
                  courseStore.isAdsEnabled &&
                      courseStore.loadingUpNative &&  courseStore.loadingUpNativeAds != null &&
                      courseStore.loadingUpNativeAds.isEnabled ?
                  NativeAds(courseStore.loadingUpNativeAds) : SizedBox(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitWave(
                        type: SpinKitWaveType.center,
                        color: Color(0xFF20BFA9),
                        size: 65.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(//!isVpnConnected ?
                          'لطفا اتصال اینترنت خود را بررسی کنید', //:
                          //'لطفا جهت برخورداری از سرعت بیشتر، فیلتر شکن خود را قطع کنید',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Text(//!isVpnConnected ? '' :
                          'جهت تجربه سرعت بهتر،',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Text(//!isVpnConnected ? '' :
                          'در صورت وصل بودن فیلترشکن، آنرا خاموش کنید',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          setState(() {
                            isTakingMuchTime = false;
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => super.widget));
                          });
                        },
                        child: Card(
                          color: Color(0xFF20BFA9),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'تلاش مجدد',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18
                              ),),
                          ),
                        ),
                      ),
                    ],
                  ),
                  courseStore.isAdsEnabled &&
                      courseStore.loadingDownNative &&  courseStore.loadingDownNativeAds != null &&
                      courseStore.loadingDownNativeAds.isEnabled ?
                  NativeAds(courseStore.loadingDownNativeAds) : SizedBox(),
                ]
            ),
          ),
        )
    ) ;
  }

  setTimerState() {
    if(_timer.isActive)
    setState(() {
      isTakingMuchTime = true;
    });
    // checkVpnConnection();
  }

  Future checkVpnConnection() async{
    setState(() {
      isVpnConnected = false;
    });
    try {
      http.Response response = await http.get('https://api.ipregistry.co?key=tryout');
      if(response.statusCode == 200 &&
          json.decode(response.body)['location']['country']['name']
              .toString().toLowerCase() != 'iran'){
        setState(() {
          isVpnConnected = true;
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Course course = widget.courseDetails;
    Favorite favorite = courseStore.favoriteCourses.firstWhere((element) =>
      element.courseId == widget.courseDetails.id, orElse: () => null);
    if(favorite != null) {
      favoriteIcon = Icons.favorite;
      favoriteButtonText = 'حذف دوره از علاقه مندی ها';
    }
    else{
      favoriteIcon = Icons.favorite_border;
      favoriteButtonText = 'افزودن دوره به علاقه مندی ها';
    }

    return FutureBuilder(
      future: courseReviews,
      builder: (context, data){
        if(data.hasData){
          return SafeArea(
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      courseStore.isAdsEnabled?
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child:
                        courseStore.isAdsEnabled &&
                            courseStore.coursePreviewTopBanner &&
                            courseStore.coursePreviewTopBannerAds != null &&
                            courseStore.coursePreviewTopBannerAds.isEnabled ?
                        BannerAds(courseStore.coursePreviewTopBannerAds) : SizedBox(),
                      ) :
                      SizedBox(),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.width * 0.8,
                            child:
                            course.photoAddress != '' ?
                            Image.file(
                              pictureFile,
                              fit: BoxFit.fill,
                            ):
                            Image.asset(
                            'assets/images/noPicture.png',
                            fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(35,20,35,0),
                        child: Center(
                          child: Text(
                            course.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.
                        fromLTRB(35,5,35,20),
                        child: Center(
                          child: Text(
                            course.instructor != null ?
                            'مدرس: ' + course.instructor :
                            'مدرس: ' + 'اِستارشو',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: SmoothStarRating(
                          size: 30,
                          allowHalfRating: false,
                          isReadOnly: true,
                          rating: averageCourseRate,
                          color: Colors.yellow,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          color: Color(0xFF20BFA9),
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextButton(
                            onPressed: () async {
                              if(!courseStore.isAdsEnabled){
                                if(pictureFile != null){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return CoursePage(course, pictureFile);
                                  }));
                                }
                                else{
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return CoursePage.noPhoto(course, 'assets/images/noPicture.png');
                                  }));
                                }
                              }
                              else if(courseStore.coursePageFull && courseStore.coursePageFullAds != null &&
                                  courseStore.coursePageFullAds.isEnabled){
                                if(!courseStore.isPopUpEnabled){
                                  if(pictureFile != null){
                                    print('cover: $pictureFile');
                                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                                      return AdvertisementPage(
                                        navigatedPage: NavigatedPage.CoursePage,
                                        ads: courseStore.coursePageFullAds,
                                        course: course,
                                        courseCover: pictureFile,
                                      );
                                    }));
                                  }
                                  else{
                                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                                      return AdvertisementPage(
                                          navigatedPage: NavigatedPage.CoursePage,
                                          ads: courseStore.coursePageFullAds,
                                          course: course,
                                          noPictureAsset: 'assets/images/noPicture.png',
                                      );
                                    }));
                                  }
                                }
                                else{
                                  Utility.showAdsAlertDialog(
                                      context,
                                      NavigatedPage.CoursePage,
                                      courseStore.coursePageFullAds,
                                      course,
                                      pictureFile,
                                      'assets/images/noPicture.png'
                                  );
                                }
                              }
                              else{
                                if(pictureFile != null){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return CoursePage(course, pictureFile);
                                  }));
                                }
                                else{
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return CoursePage.noPhoto(course, 'assets/images/noPicture.png');
                                  }));
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Text(
                                'شروع دوره آموزشی (رایگان)',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 40,
                            top: 20,
                            right: 40,
                            bottom: 10),
                        child: Center(
                          child: Text(
                            course.description,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21.0,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // Card(
                      //   elevation: 10,
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: SizedBox(
                      //       width: MediaQuery.of(context).size.width * 0.8,
                      //       child: priceTagWidget(),
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Color(0xFF20BFA9),
                            child: coursePurchaseButton(course),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Color(0xFF20BFA9),
                            child: TextButton(
                              onPressed: () async {
                                Favorite favorite = await courseStore.addToUserFavoriteCourses(widget.courseDetails);
                                courseStore.updateUserFavoriteCourses(widget.courseDetails);

                                if(courseStore.favoriteCourses.contains(favorite))

                                  setState(() {
                                    favoriteButtonText = 'حذف دوره از علاقه مندی ها';
                                  });
                                else
                                  setState(() {
                                    favoriteButtonText = 'افزودن دوره به علاقه مندی ها';
                                  });

                                // if(courseStore.isAdsEnabled){
                                //   Utility.showAdsAlertDialog(
                                //     context,
                                //     NavigatedPage.AddToFavorite,
                                //   );
                                // }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Icon(
                                      favoriteIcon,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Center(
                                      child: Text(
                                        favoriteButtonText,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      courseStore.isAdsEnabled?
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child:
                        courseStore.isAdsEnabled &&
                            courseStore.coursePreviewBelowAddToFavoriteBanner &&
                            courseStore.coursePreviewBelowAddToFavoriteBannerAds != null &&
                            courseStore.coursePreviewBelowAddToFavoriteBannerAds.isEnabled ?
                        BannerAds(courseStore.coursePreviewBelowAddToFavoriteBannerAds) : SizedBox(),
                      ) :
                      SizedBox(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Divider(
                          color: Colors.black
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          courseReviewList.length != 0 ?
                            'نظرات کاربران':'هنوز نظری ثبت نشده است',
                          style: TextStyle(fontSize: 17),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15,
                            top: 20,
                            right: 15,
                            bottom: 5),
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: courseReviewList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              color: Colors.white10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          courseReviewList[index].userFirstName != null ?
                                            courseReviewList[index].userFirstName :
                                          'کاربر نرم افزار',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        // Text(
                                        //   courseReviewList[index].date.toLocal().toString(),
                                        //   style: TextStyle(fontSize: 16),
                                        // ),
                                        Directionality(
                                          textDirection: ui.TextDirection.ltr,
                                          child: SmoothStarRating(
                                            size: 15,
                                            allowHalfRating: false,
                                            isReadOnly: true,
                                            rating: double.parse(courseReviewList[index].rating.toString()),
                                            color: Colors.yellow,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      courseReviewList[index].text,
                                      style: TextStyle(fontSize: 18),
                                      textAlign: TextAlign.justify,
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      totalReviewsCount > 0 ?
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15,
                                top: 5,
                                right: 15,
                                bottom: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white54),
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xFF34333A),
                              ),
                              height: 35,
                              child: TextButton(
                                onPressed: () async {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return ReviewPage(widget.courseDetails.id);
                                      })
                                  );
                                },
                                child: Text(
                                  'نمایش  تمام نظرات ($totalReviewsCount)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                          :
                          SizedBox(
                          ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Divider(
                            color: Colors.black
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Directionality(
                          textDirection: ui.TextDirection.ltr,
                          child: SmoothStarRating(
                            spacing: 15,
                            allowHalfRating: false,
                            onRated: (value){
                              yourRate = value;
                            },
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                        child: TextField(
                          minLines: 1,
                          maxLines: 15,
                          style: TextStyle(
                              decorationColor: Colors.black, color: Colors.white),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                            ),
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            labelText: 'نظر شما',
                          ),
                          controller: reviewController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: sendButtonColor,
                                  ),
                                  height: 55,
                                  child: TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        isSendingReview = true;
                                      });
                                      if (reviewController.text.isNotEmpty && yourRate != 0)
                                        await postReview();
                                      else if(reviewController.text.isEmpty)
                                        Fluttertoast.showToast(msg: 'لطفا نظر خود را بنویسید');
                                      else
                                        Fluttertoast.showToast(msg: 'لطفا امتیاز خود را با انتخاب تعداد ستاره مشخص کنید');
                                      setState(() {
                                        isSendingReview = false;
                                      });
                                    },
                                    child: !isSendingReview ?
                                      Text(
                                        sendButtonText,
                                        style: TextStyle(
                                          fontSize: sendButtonSize,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ) :
                                      SpinKitRing(
                                        lineWidth: 5,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.red[700],
                                  ),
                                  height: 55,
                                  child: TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        reviewController.text = '';
                                      });
                                    },
                                    child: Text(
                                      'پاک کردن',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          );
        }
        else
          return spinner();
      }
    );
  }
}
