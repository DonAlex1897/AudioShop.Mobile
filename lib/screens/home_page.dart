import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:async/async.dart';
import 'package:mobile/models/configuration.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/models/slider_item.dart';
import 'package:mobile/screens/course_preview.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screens/search_result_page.dart';
import 'package:mobile/screens/support_page.dart';
import 'package:mobile/services/statistics_service.dart';
import 'package:mobile/utilities/Utility.dart';
import 'package:mobile/utilities/banner_ads.dart';
import 'package:mobile/utilities/native_ads.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:mobile/screens/authentication_page.dart';
import 'package:mobile/services/course_service.dart';
import 'package:mobile/services/global_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';
import 'add_salesperson_coupon_code.dart';
import 'advertisement_page.dart';
import 'course_page.dart';
import 'psychological_tests_page.dart';

class HomePage extends StatefulWidget {
  HomePage(this.currentVersion);
  //HomePage.basic();

  final String currentVersion;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterLocalNotificationsPlugin localPromotionNotificationsPlugin;
  FlutterLocalNotificationsPlugin localReminderNotificationsPlugin;
  final secureStorage = FlutterSecureStorage();
  CourseData courseData;
  double width = 0;
  double height = 0;
  List<Widget> coursesList = List<Widget>();
  List<Widget> carouselSlider = List<Widget>();
  DateTime currentBackPressTime;
  Future<dynamic> courses;
  CourseStore courseStore;
  List<Course> courseList = List<Course>();
  List<SliderItem> sliderItemList = List<SliderItem>();
  int tabIndex = 1;
  bool delete = false;
  double totalBasketPrice = 0;
  Widget dropdownValue = Icon(Icons.person_pin, size: 50, color: Colors.white,);
  bool alertReturn = false;
  GlobalService globalService;
  MethodChannel platform = MethodChannel('audioshoppp.ir.mobile/notification');
  TextEditingController searchController = TextEditingController();
  int currentSlideIndex = 0;
  bool isTakingMuchTime = false;
  Duration _timerDuration = new Duration(seconds: 15);
  Widget appBarTitle = new Text("اِستارشو");
  Icon actionIcon = new Icon(Icons.search);
  bool isVpnConnected = false;
  StatisticsService statisticsService = StatisticsService();
  bool showLoadingUpAds = false;
  bool showLoadingDownAds = false;
  bool showHomePageAds = false;
  bool showLibraryAds = false;
  bool showProfileAds = false;
  bool showAdsInPopUp = true;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    globalService = GlobalService();
    setFirstTimeTrue();
    statisticsService.enteredApplication();
    // courseData = CourseData();
    // courses = getCourses();
    // loginStatement();
  }

  @override
  void didChangeDependencies(){
    courseStore = Provider.of<CourseStore>(context);
    courseData = CourseData();
    if(courses == null)
      courses = getCourses();
    loginStatement();
    super.didChangeDependencies();
  }

  Future setFirstTimeTrue() async{
    await secureStorage.write(key: 'isFirstTime', value: 'false');
  }

  Future _onSelectPromotionNotification(String payload) async {
    print('payload: $payload');
    if(payload != 0.toString()){
      Course course = await courseData.getCourseById(int.parse(payload));
      var courseCover = await DefaultCacheManager().getSingleFile(course.photoAddress);

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return CoursePreview(course);
      }));
    }
    else{
      setState(() {
        tabIndex = 0;
      });
    }
  }

  Future _onSelectReminderNotification(String payload) async {
    print('payload: $payload');
    setState(() {
      tabIndex = 0;
    });
  }

  Future _setUpPromotionNotification() async{
    List<Configuration> promotionConfigurations = await globalService.getConfigsByGroup('Promote');
    String body = promotionConfigurations
        .firstWhere((element) => element.titleEn == 'PromoteNotifBody', orElse: () => null).value;
    String title = promotionConfigurations
        .firstWhere((element) => element.titleEn == 'PromoteNotifTitle', orElse: () => null).value;
    String courseId = promotionConfigurations
        .firstWhere((element) => element.titleEn == 'PromoteNotifCourseId', orElse: () => null).value;
    String timeOfDay = promotionConfigurations
        .firstWhere((element) => element.titleEn == 'PromoteNotifTime', orElse: () => null).value;
    var android = AndroidNotificationDetails('channelId', 'channelName', 'channelDescription');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
    // await localPromotionNotificationsPlugin.show(0, title, body, platform, payload: courseId);
    await localPromotionNotificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        _nextInstanceOfTimeToShowNotification(int.parse(timeOfDay)),
        platform,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: courseId);
  }

  Future _setUpReminderNotification() async{
    List<Configuration> promotionConfigurations = await globalService.getConfigsByGroup('Reminder');
    String body = promotionConfigurations
        .firstWhere((element) => element.titleEn == 'ReminderNotifBody', orElse: () => null).value;
    String title = promotionConfigurations
        .firstWhere((element) => element.titleEn == 'ReminderNotifTitle', orElse: () => null).value;
    String courseId = promotionConfigurations
        .firstWhere((element) => element.titleEn == 'ReminderNotifCourseId', orElse: () => null).value;
    String timeOfDay = promotionConfigurations
        .firstWhere((element) => element.titleEn == 'ReminderNotifTime', orElse: () => null).value;
    var android = AndroidNotificationDetails('channelId', 'channelName', 'channelDescription');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
    await localReminderNotificationsPlugin.zonedSchedule(
        1,
        title,
        body,
        _nextInstanceOfTimeToShowNotification(int.parse(timeOfDay)),
        platform,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: courseId);
  }

  tz.TZDateTime _nextInstanceOfTimeToShowNotification(int hour) {
    try{
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, 0);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      return scheduledDate;
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  Widget spinner(){
    return Scaffold(
      body: !isTakingMuchTime ?
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 20,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      showLoadingUpAds ?
                        NativeAds(NativeAdsLocation.LoadingUp) : SizedBox(),
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Image.asset(
                          'assets/images/appMainIcon.png',
                          width: MediaQuery.of(context).size.width * 0.2,
                        ),
                      ),
                      Text(
                        'اِستارشو، اپلیکیشن مهارتهای ارتباطی',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'با اِستارشو، ستاره شو',
                        style: TextStyle(fontSize: 18),
                      ),
                      SpinKitWave(
                        type: SpinKitWaveType.center,
                        color: Color(0xFF20BFA9),
                        size: 20.0,
                      ),
                      showLoadingDownAds ?
                          NativeAds(NativeAdsLocation.LoadingDown) : SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'نسخه ' + widget.currentVersion,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70
                ),
              ),
            )
          ],
        ),
      ) :
      Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                showLoadingUpAds ?
                  NativeAds(NativeAdsLocation.LoadingUp) : SizedBox(),
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
                showLoadingDownAds ?
                  NativeAds(NativeAdsLocation.LoadingDown) : SizedBox(),
              ]
          ),
        ),
      )
    ) ;
  }

  setTimerState() {
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


  Future<List<Course>> getCourses() async {
    RestartableTimer(_timerDuration, setTimerState);
    try{
      tz.initializeTimeZones();
      final String timeZoneName = await platform.invokeMethod('getTimeZoneName');
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    }
    catch(e){
      print(e.toString());
      tz.setLocalLocation(tz.getLocation('Asia/Tehran'));
    }
    await setLocalNotificationSettings();
    await setGeneralConfigurations();
    courseList = await courseData.getCourses();
    sliderItemList = await courseData.getSliderItems();
    courseStore.setAllCourses(courseList);
    if (courseList != null)
      await updateUI(courseList, sliderItemList);
    // else
    //   await updateUI(widget.courses, sliderItemList);
    return courseList;
  }

  Future setLocalNotificationSettings() async{
    localPromotionNotificationsPlugin = FlutterLocalNotificationsPlugin();
    localReminderNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android: android, iOS: iOS);

    localReminderNotificationsPlugin
        .initialize(initSettings, onSelectNotification: _onSelectReminderNotification);
    await _setUpReminderNotification();

    localPromotionNotificationsPlugin
        .initialize(initSettings, onSelectNotification: _onSelectPromotionNotification);
    await _setUpPromotionNotification();
  }

  Future setGeneralConfigurations() async{
    List<Configuration> generalConfigurations = await globalService.getConfigsByGroup('');
    courseStore.setConfigs(generalConfigurations);
  }

  //TODO delete this method
  goToCoursePage(Course course, var courseCover) {
    courseStore.setCurrentCourse(course);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CoursePage(course, courseCover);
    }));
  }

  goToCoursePreview(Course course){
    if(!courseStore.isAdsEnabled){
      Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CoursePreview(course);
      }));
    }
    else{
      if(!showAdsInPopUp){
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return AdvertisementPage(
            navigatedPage: NavigatedPage.CoursePreview,
            course: course,
          );
        }));
      }
      else{
        Utility.showAdsAlertDialog(context, NavigatedPage.CoursePreview, course);
      }
    }
  }

  Future updateUI(List<Course> coursesData, List<SliderItem> sliderItems) async {
    for (var course in coursesData) {
      String picUrl = course.photoAddress;
      String courseName = course.name;
      String courseDescription = course.description;
      var pictureFile = picUrl != '' ?
        await DefaultCacheManager().getSingleFile(picUrl):
        null;
      coursesList.add(
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: Color(0xFF2c3335),
          child: TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(vertical: 0, horizontal: 0)),
            ),
            onPressed: () {
              // goToCoursePage(course, pictureFile);
              goToCoursePreview(course);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      child: pictureFile != null ?
                        Image.file(
                          pictureFile,
                          fit: BoxFit.fill,
                        ):
                        Image.asset(
                          'assets/images/noPicture.png',
                          fit: BoxFit.fill,
                        ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        courseName,
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5,0,5,0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          course.instructor != null ? course.instructor : 'اِستارشو',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.yellow[300],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left:3, right:2,),
                            child: Text(
                              course.averageScore != null ?
                                course.averageScore.toStringAsFixed(1):'5.0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
      )
      );
    }

    for(var sliderItem in sliderItems){
      try{
        String sliderPicUrl = sliderItem.photoAddress;
        var pictureFile = await DefaultCacheManager().getSingleFile(sliderPicUrl);
        carouselSlider.add(
          InkWell(
            onTap: () async {
              if(sliderItem.courseId != null){
                Course course = await courseData.getCourseById(sliderItem.courseId);
                goToCoursePreview(course);
              }
            },
            child: Stack(children: <Widget>[
              Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(pictureFile),
                        fit: BoxFit.cover,
                      ),
                    )
              ), //I
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color.fromARGB(200, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    sliderItem.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        );
      }
      catch(e){
        print(e.toString());
      }
    }
  }

  Future<bool> onWilPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'برای خروج دو بار روی دکمه بازگشت بزنید');
      return Future.value(false);
    }
    SystemNavigator.pop();
    return Future.value(true);
  }

  Widget navigationSelect(int tab) {
    if (tab == 0)
      return library();
    else if (tab == 1)
      return home();
    else
      return profile();
  }

  Widget profile(){
    return (courseStore.token == null || courseStore.token == '') ?
      notLoggedInWidget() : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 90,
              child: Card(
                color: Color(0xFF202028),
                elevation: 20,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.person_pin,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      flex: courseStore.hasPhoneNumber ? 4 : 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8,0,8,0),
                        child: Text(courseStore.userName),
                      ),
                    ),
                    registerPhoneButton(),
                    Expanded(
                      flex: 2,
                      child: TextButton(
                          onPressed: () async {
                            Widget cancelB = cancelButton('خیر');
                            Widget continueB =
                            continueButton('بله', Alert.LogOut, null);
                            AlertDialog alertD = alert('هشدار',
                                'میخواهید از برنامه خارج شوید؟',
                                [cancelB, continueB]);

                            await showBasketAlertDialog(context, alertD);

                            if(alertReturn){
                              await logOut();
                            }
                            alertReturn = false;

                            setState(() {
                              navigationSelect(1);
                            });
                          },
                          child: Card(
                            color: Colors.red[700],
                            child: Center(child: Text('خروج')),
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ),
            notRegisteredPhoneNumber(),
            SizedBox(
              height: 80,
              width: width,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white24,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                ),
                child: TextButton(
                  onPressed: () {
                    if(!courseStore.isAdsEnabled){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context){
                            return AddSalesPersonCouponCode();
                          })
                      );
                    }
                    else{
                      if(!showAdsInPopUp){
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return AdvertisementPage(
                            navigatedPage: NavigatedPage.AddSalesPersonCouponCode,
                          );
                        }));
                      }
                      else{
                        Utility.showAdsAlertDialog(
                            context,
                            NavigatedPage.AddSalesPersonCouponCode,
                        );
                      }
                    }
                  },
                  child: Text(
                    'ثبت کد معرف',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    )
                  ),
                )
              )
            ),
            SizedBox(
                height: 80,
                width: width,
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        if(!courseStore.isAdsEnabled){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context){
                                return SupportPage();
                              })
                          );
                        }
                        else{
                          if(!showAdsInPopUp){
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return AdvertisementPage(
                                navigatedPage: NavigatedPage.SupportPage,
                              );
                            }));
                          }
                          else{
                            Utility.showAdsAlertDialog(
                              context,
                              NavigatedPage.SupportPage,
                            );
                          }
                        }
                      },
                      child: Text(
                          'پشتیبانی',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          )
                      ),
                    )
                )
            ),
            SizedBox(
                height: 80,
                width: width,
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // if(!courseStore.isAdsEnabled){
                        //   Navigator.push(context,
                        //       MaterialPageRoute(builder: (context){
                        //         return PsychologicalTestsPage();
                        //       })
                        //   );
                        // }
                        // else{
                        //   if(!showAdsInPopUp){
                        //     Navigator.push(context, MaterialPageRoute(builder: (context) {
                        //       return AdvertisementPage(
                        //         navigatedPage: NavigatedPage.PsychologicalTests,
                        //       );
                        //     }));
                        //   }
                        //   else{
                        //     Utility.showAdsAlertDialog(
                        //       context,
                        //       NavigatedPage.PsychologicalTests,
                        //     );
                        //   }
                        // }

                        Fluttertoast.showToast(
                            msg: 'این قسمت به زودی بارگذاری خواهد شد'
                        );
                      },
                      child: Text(
                          'تست های روانشناسی',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          )
                      ),
                    )
                )
            ),
            NativeAds(NativeAdsLocation.Profile)
          ],
        ),
      );
  }

  search(String searchElement){
    if(searchElement != '')
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SearchResultPage(searchElement);
      }));
    else
      Fluttertoast.showToast(msg: 'لطفا قسمتی از نام '
          'دوره را وارد کنید');
  }

  Widget home() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            courseStore.isAdsEnabled?
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: BannerAds(),
            ) :
            SizedBox(),
            Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                      height: width * 1.2,
                      viewportFraction: 1,
                      // aspectRatio: 1.75,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 5),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      onPageChanged: pageChanged
                  ),
                  items: carouselSlider,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: carouselSlider.map((image) {
                        int index=carouselSlider.indexOf(image); //are changed
                        return Container(
                          width: 6.0,
                          height: 6.0,
                          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentSlideIndex == index
                                  ? Colors.black
                                  : Colors.black38),
                        );
                      }).toList()
                  ),
                )
              ]
            ),
            courseStore.isAdsEnabled?
            Padding(
              padding: const EdgeInsets.only(top:8, bottom: 8),
              child: BannerAds(),
            ) :
            SizedBox(),
            Padding(
              padding: const EdgeInsets.only(top: 10, right:10),
              child: SizedBox(
                height: 30,
                child: Text('جدیدترین دوره ها', style: TextStyle(fontSize: 18),),
              ),
            ),
            GridView.count(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.all(5),
              crossAxisCount: 2,
              childAspectRatio: (width / height),
              children: coursesList,
              physics: ScrollPhysics(),
            ),
            NativeAds(NativeAdsLocation.HomePage),
          ],
        ),
      ),
    );
  }

  Widget library() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: courseStore.isAdsEnabled? 130: 50,
          flexibleSpace:
          courseStore.isAdsEnabled?
          BannerAds() :
          SizedBox(),
          leading: Container(),
          bottom: TabBar(
            tabs: [
              Tab(text: 'دوره های من',),
              Tab(text: 'مورد علاقه ها',)
            ],
          ),
        ),
        body: TabBarView(children: [
          myCoursesWidget(),
          myFavoriteCoursesWidget(),
        ]),
      ),
    );

  }

  pageChanged(int index, CarouselPageChangedReason changedReason){
    setState(() {
      currentSlideIndex = index;
    });
  }

  Widget myCoursesWidget(){
    return (courseStore.token == null || courseStore.token == '') ?
      notLoggedInWidget() : SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 8),
              child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text((courseStore.userEpisodes != null && courseStore.userEpisodes.length > 0) ?
                        'دوره های شما' : 'هنوز دوره ای در حساب کاربری شما ثبت نشده است',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
              ),
            ),
            courseStore.userEpisodes != null ?
              userCourses() : Container(),
            NativeAds(NativeAdsLocation.Library),
          ],
        ),
      );
  }

  Widget notLoggedInWidget(){
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Text(
              ' این بخش مخصوص کاربرانی است که ثبت نام کرده اند.'
                ' اگر قبلا ثبت نام کرده اید وارد شوید. در غیر اینصورت'
                ' ثبت نام کنید',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Card(
                    color: Color(0xFF20BFA9),
                    child: TextButton(
                      child: Text(
                        'ورود',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white),
                      ),
                      onPressed: () {
                        if(!courseStore.isAdsEnabled){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return AuthenticationPage(FormName.SignIn);
                              }));
                        }
                        else{
                          if(!showAdsInPopUp){
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return AdvertisementPage(
                                navigatedPage: NavigatedPage.SignInLibrary,
                              );
                            }));
                          }
                          else{
                            Utility.showAdsAlertDialog(
                                context,
                                NavigatedPage.SignInLibrary
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Color(0xFF20BFA9),
                    child: TextButton(
                      child: Text(
                        'ثبت نام',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,),
                      ),
                      onPressed: () {
                        if(!courseStore.isAdsEnabled){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return AuthenticationPage(FormName.SignUp);
                              }));
                        }
                        else{
                          if(!showAdsInPopUp){
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return AdvertisementPage(
                                navigatedPage: NavigatedPage.SignUpLibrary,
                              );
                            }));
                          }
                          else{
                            Utility.showAdsAlertDialog(
                                context,
                                NavigatedPage.SignUpLibrary
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          NativeAds(NativeAdsLocation.Library),
        ],
      ),
    );
  }

  Widget myFavoriteCoursesWidget(){
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text((courseStore.userFavoriteCourses != null &&
                    courseStore.userFavoriteCourses.length > 0) ?
                  'دوره های مورد علاقه شما' :
                  'هنوز دوره ای را به علاقه مندی های خود اضافه نکرده اید',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          (courseStore.userFavoriteCourses != null &&
              courseStore.userFavoriteCourses.length > 0) ?
            userFavoriteCourses() : Container(),
          NativeAds(NativeAdsLocation.Library),
        ],
      ),
    );
  }

  Widget userFavoriteCourses(){
    List<Course> userFavoriteCourses = courseStore.userFavoriteCourses;
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: courseStore.userFavoriteCourses.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () async {
                var picFile = await DefaultCacheManager().getSingleFile(
                    userFavoriteCourses[index].photoAddress);
                // goToCoursePage(userFavoriteCourses[index], picFile);
                goToCoursePreview(userFavoriteCourses[index]);
              },
              child: Card(
                color: Color(0xFF403F44),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                                userFavoriteCourses[index].photoAddress),
                          )),
                      Expanded(
                        flex: 6,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8,0,8,0),
                            child: Text(
                              userFavoriteCourses[index].name,
                              style: TextStyle(fontSize: 19),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                          child: Container(
                            color: Colors.red,
                            child: TextButton(
                              child: Icon(Icons.delete_outline_sharp,
                                  size: 25, color: Colors.white),
                              onPressed: () async {
                                Widget cancelB = cancelButton('خیر');
                                Widget continueB =
                                continueButton('بله', Alert.DeleteFromFavorite, index);
                                AlertDialog alertD = alert('هشدار',
                                    'آیا از حذف دوره از علاقه مندی ها مطمئنید؟',
                                    [cancelB, continueB]);
                                await showBasketAlertDialog(context, alertD);

                                if(alertReturn){
                                  String userFavoriteCourseIds = await secureStorage
                                      .read(key: 'UserFavoriteCourseIds');
                                  List<String> favCourseIds = userFavoriteCourseIds.split(',');
                                  userFavoriteCourseIds = '';
                                  favCourseIds.forEach((element) {
                                    if(element != userFavoriteCourses[index].id.toString())
                                      userFavoriteCourseIds += element + ',';
                                  });
                                  await secureStorage.write(
                                      key: 'UserFavoriteCourseIds',
                                      value: userFavoriteCourseIds);
                                  setState(() {
                                    courseStore.addToUserFavoriteCourses(userFavoriteCourses[index]);
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget registerPhoneButton(){
    if(courseStore.hasPhoneNumber)
      return SizedBox();
    return Expanded(
      flex: 2,
      child: TextButton(
        onPressed: (){
          if(!courseStore.isAdsEnabled){
            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return AuthenticationPage(FormName.RegisterPhoneNumber);
                }));
          }
          else{
            if(!showAdsInPopUp){
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AdvertisementPage(
                  navigatedPage: NavigatedPage.RegisterPhoneNumber,
                );
              }));
            }
            else{
              Utility.showAdsAlertDialog(
                  context,
                  NavigatedPage.RegisterPhoneNumber
              );
            }
          }
        },
        child: Card(
          color: Color(0xFF20BFA9),
          child: Center(child: Text('ثبت همراه')),
        ),
      ),
    );
  }

  Widget notRegisteredPhoneNumber(){
    if(courseStore.token != null &&
        courseStore.token != '' &&
        !courseStore.hasPhoneNumber){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'کاربر عزیز. شماره همراه شما در سیستم ثبت نشده است.'
              ' ورود مجدد به حساب کاربری فقط با شماره همراه ممکن است.'
              'در صورت تمایل به ثبت شماره همراه، دکمه سبز رنگ را '
              'از منوی بالا انتخاب کنید',
          style: TextStyle(color: Colors.red[300]),
      ),
      );
    }
    return SizedBox();
  }

  List<Course> getUserCourses() {
    List<Course> userCourses = [];
    courseStore.userEpisodes.forEach((episode) {
      var tempCourse = courseStore.courses
          .firstWhere((course) => course.id == episode.courseId);
      if(!userCourses.contains(tempCourse))
        userCourses.add(tempCourse);
    });
    return userCourses;
  }

  Widget userCourses(){
    List<Course> userCourses = getUserCourses();
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: userCourses.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () async {
                var picFile = await DefaultCacheManager().getSingleFile(
                    userCourses[index].photoAddress);
                // goToCoursePage(userCourses[index], picFile);
                goToCoursePreview(userCourses[index]);
              },
              child: Card(
                color: Color(0xFF403F44),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                                userCourses[index].photoAddress),
                          )),
                      Expanded(
                        flex: 6,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8,0,8,0),
                            child: Text(
                              userCourses[index].name,
                              style: TextStyle(fontSize: 19),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Future logOut() async{
    await secureStorage.write(key: 'token', value: '');
    await secureStorage.write(key: 'hasPhoneNumber', value: 'false');
    await courseStore.setUserDetails('', false, '');
  }

  Widget cancelButton(String cancelText){
    return FlatButton(
      child: Text(cancelText),
      onPressed: () {
        Navigator.of(context).pop();
        alertReturn = false;
      },
    );
  }

  Widget continueButton(String continueText, Alert alert, int index){
    return FlatButton(
      child: Text(continueText),
      onPressed: () async {
        Navigator.of(context).pop();
        if(alert == Alert.DeleteFromFavorite || alert == Alert.LogOut)
          alertReturn = true;
        else if(alert == Alert.RegisterPhoneNumber){
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return AuthenticationPage(FormName.RegisterPhoneNumber);
          }));
        }
      },
    );
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

  Future loginStatement() async {
    String token = await secureStorage.read(key: 'token');
    String hasPhoneNumber = await secureStorage.read(key: 'hasPhoneNumber');
    String salespersonCouponCode = await secureStorage.read(key: 'salespersonCouponCode');
    String userFavoriteCourseIds = await secureStorage.read(key: 'UserFavoriteCourseIds');
    if(userFavoriteCourseIds != null && userFavoriteCourseIds.length > 0){
      List<String> userFavoriteCourseIdList = userFavoriteCourseIds.split(',');
      userFavoriteCourseIdList.forEach((courseId) async {
        if(courseId != null && courseId != '0' && courseId != ''){
          Course userFavoriteCourse = await courseData.getCourseById(int.parse(courseId));
          courseStore.addToUserFavoriteCourses(userFavoriteCourse);
        }
      });
    }
    if (token != null && token.isNotEmpty && !courseStore.isTokenExpired(token))
      await courseStore.setUserDetails(token, hasPhoneNumber.toLowerCase() == 'true', salespersonCouponCode);
    else if(courseStore.isTokenExpired(token)){
      await secureStorage.write(key: 'token', value: '');
      await secureStorage.write(key: 'hasPhoneNumber', value: 'false');
      await courseStore.setUserDetails('', false, '');
    }
  }

  void _handleSearchStart() {
    setState(() {
      // _IsSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(Icons.search, color: Colors.white,);
      this.appBarTitle =
      new Text("اِستارشو", style: new TextStyle(color: Colors.white),);
      // _IsSearching = false;
      // _searchQuery.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // courseStore = Provider.of<CourseStore>(context);
    // courseStore.setAllCourses(courseList);


    // if(courseStore.token != null)
    //   courseStore.setUserDetails(courseStore.token, courseStore.hasPhoneNumber, );
    // FirebaseAdMob.instance
    //     .initialize(appId: "ca-app-pub-6716792328957551~1144830596")
    //     .then((value) => myBanner
    //       ..load()
    //       ..show(anchorType: AnchorType.bottom));

    width = MediaQuery.of(context).size.width / 2;
    height = (MediaQuery.of(context).size.width / 2) * 1.5;
    return FutureBuilder(
        future: courses,
        builder: (context, data) {
          if (data.hasData)
            return WillPopScope(
                child: Scaffold(
                    appBar: AppBar(
                    leading: Container(),
                      centerTitle: true,
                      title: appBarTitle,
                      actions: <Widget>[
                        new IconButton(icon: actionIcon,onPressed:(){
                          setState(() {
                            if (this.actionIcon.icon == Icons.search) {
                              this.actionIcon = new Icon(Icons.close, color: Colors.white,);
                              this.appBarTitle = new TextField(
                                textInputAction: TextInputAction.search,
                                onSubmitted: (value){
                                  search(value);
                                },
                                controller: searchController,
                                style: new TextStyle(
                                  color: Colors.white,

                                ),
                                decoration: new InputDecoration(
                                    prefixIcon: InkWell(
                                      onTap: (){
                                        search(searchController.text);
                                      },
                                      child: Icon(Icons.search,
                                          size: 25, color: Colors.white),
                                    ),
                                    hintText: "جستجو...",
                                    hintStyle: new TextStyle(color: Colors.white),
                                ),
                              );
                              _handleSearchStart();
                            }
                            else {
                              _handleSearchEnd();
                            }
                          });
                        } ,
                        ),
                      ]
                  ),
                    bottomNavigationBar: Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: CurvedNavigationBar(
                        color: Color(0xFF202028),
                        buttonBackgroundColor: Color(0xFF202028),
                        animationDuration: Duration(milliseconds: 200),
                        height: 50,
                        backgroundColor: Color(0xFF34333A),
                        items: <Widget>[
                          Icon(Icons.my_library_music,
                              size: 25, color: Color(0xFF20BFA9)),
                          Icon(Icons.home, size: 25, color: Color(0xFF20BFA9)),
                          Icon(Icons.person,
                              size: 25, color: Color(0xFF20BFA9)),
                        ],
                        onTap: (index) => {
                          setState(() {
                            tabIndex = index;
                          })
                        },
                        index: 1,
                      ),
                    ),
                    body: navigationSelect(tabIndex)),
                onWillPop: onWilPop);
          else
            return spinner();
        });
  }
}
//
// MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//   keywords: <String>['podcast', 'hadi'],
//   contentUrl: 'https://flutter.io',
//   childDirected: false,
//   testDevices: <String>[
//     'A36235BD5DAEAA4D6FA305A209159D2A'
//   ], // Android emulators are considered test devices
// );
//
// BannerAd myBanner = BannerAd(
//   // Replace the testAdUnitId with an ad unit id from the AdMob dash.
//   // https://developers.google.com/admob/android/test-ads
//   // https://developers.google.com/admob/ios/test-ads
//   adUnitId: BannerAd.testAdUnitId,
//   size: AdSize.fullBanner,
//   targetingInfo: targetingInfo,
//   listener: (MobileAdEvent event) {
//     print("BannerAd event is $event");
//   },
// );
//
// InterstitialAd myInterstitial = InterstitialAd(
//   // Replace the testAdUnitId with an ad unit id from the AdMob dash.
//   // https://developers.google.com/admob/android/test-ads
//   // https://developers.google.com/admob/ios/test-ads
//   adUnitId: InterstitialAd.testAdUnitId,
//   targetingInfo: targetingInfo,
//   listener: (MobileAdEvent event) {
//     print("InterstitialAd event is $event");
//   },
// );
