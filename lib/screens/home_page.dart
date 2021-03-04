import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/configuration.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/screens/course_preview.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:mobile/screens/authentication_page.dart';
import 'package:mobile/services/course_service.dart';
import 'package:mobile/services/global_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';
import 'add_salesperson_coupon_code.dart';
import 'course_page.dart';

class HomePage extends StatefulWidget {
  HomePage(this.courses);
  HomePage.basic();

  dynamic courses;

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
  // final String url = 'http://10.0.2.2:5000/api/courses/';
  DateTime currentBackPressTime;
  Future<dynamic> courses;
  CourseStore courseStore;
  List<Course> courseList = List<Course>();
  int tabIndex = 1;
  bool delete = false;
  double totalBasketPrice = 0;
  Widget dropdownValue = Icon(Icons.person_pin, size: 50, color: Colors.white,);
  bool alertReturn = false;
  GlobalService globalService;
  MethodChannel platform =
    MethodChannel('audioshoppp.ir.mobile/notification');

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
    // courseData = CourseData();
    // courses = getCourses();
    // loginStatement();
  }

  @override
  void didChangeDependencies(){
    courseStore = Provider.of<CourseStore>(context);
    courseData = CourseData();
    courses = getCourses();
    loginStatement();
    courseStore.setAllCourses(courseList);
    super.didChangeDependencies();
  }

  Future _onSelectPromotionNotification(String payload) async {
    print('payload: $payload');
    Course course = await courseData.getCourseById(int.parse(payload));
    var courseCover = await DefaultCacheManager().getSingleFile(course.photoAddress);

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CoursePage(course, courseCover);
    }));
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

  tz.TZDateTime _nextInstanceOfTimeToShowNotification(int hour) {
    try{
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, 56);
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

  Future<List<Course>> getCourses() async {
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
    if (courseList != null)
      await updateUI(courseList);
    else
      await updateUI(widget.courses);
    return courseList;
  }

  Future setLocalNotificationSettings() async{
    localPromotionNotificationsPlugin = FlutterLocalNotificationsPlugin();
    localReminderNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android: android, iOS: iOS);
    localPromotionNotificationsPlugin
        .initialize(initSettings, onSelectNotification: _onSelectPromotionNotification);
    await _setUpPromotionNotification();

    localReminderNotificationsPlugin
        .initialize(initSettings, onSelectNotification: _onSelectReminderNotification);
    await _setUpReminderNotification();
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
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CoursePreview(course);
    }));
  }

  Future updateUI(List<Course> coursesData) async {
    for (var course in coursesData) {
      String picUrl = course.photoAddress;
      String courseName = course.name;
      String courseDescription = course.description;
      var pictureFile = await DefaultCacheManager().getSingleFile(picUrl);
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
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.file(
                    pictureFile,
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    courseName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    'بیطرف',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      carouselSlider.add(TextButton(
        onPressed: () {
          // goToCoursePage(course, pictureFile);
          goToCoursePreview(course);
        },
        child: Container(
            child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            //picUrl,
            pictureFile,
          ),
        )),
      ));
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
      notLoggedInWidget() : SafeArea(
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context){
                        return AddSalesPersonCouponCode();
                      })
                  );
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
          )
        ],
      ),
    );
  }

  Widget home() {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Card(
            color: Color(0xFF403F44),
            child: SafeArea (
              child: CarouselSlider(
                  options: CarouselOptions(
                      height: height,
                      viewportFraction: 0.6,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true),
                  items: carouselSlider),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Card(
            color: Color(0xFF403F44),
            child: GridView.count(
              padding: const EdgeInsets.all(5),
              crossAxisCount: 3,
              childAspectRatio: (width / height),
              children: coursesList,
            ),
          ),
        ),
      ],
    );
  }

  Widget library() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
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

  Widget myCoursesWidget(){
    return (courseStore.token == null || courseStore.token == '') ?
      notLoggedInWidget() : SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
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
              ),
              Expanded(
                flex: 15,
                child: courseStore.userEpisodes != null ? userCourses() : Container(),
              )
            ],
          ),
      );
  }

  Widget notLoggedInWidget(){
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Text(
                'این بخش مخصوص کاربرانی است که ثبت نام کرده اند.'
                  'اگر قبلا ثبت نام کرده اید وارد شوید. در غیر اینصورت'
                  'ثبت نام کنید',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: Padding(
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
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return AuthenticationPage(FormName.SignIn);
                                }));
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
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return AuthenticationPage(FormName.SignUp);
                                }));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget myFavoriteCoursesWidget(){
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text((courseStore.userFavoriteCourses != null && courseStore.userFavoriteCourses.length > 0) ?
                    'دوره های مورد علاقه شما' : 'هنوز دوره ای را به علاقه مندی های خود اضافه نکرده اید',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 15,
            child: courseStore.userEpisodes != null ? userFavoriteCourses() : Container(),
          )
        ],
      ),
    );
  }

  Widget userFavoriteCourses(){
    List<Course> userFavoriteCourses = courseStore.userFavoriteCourses;
    return ListView.builder(
        itemCount: courseStore.userFavoriteCourses.length,
        itemBuilder: (BuildContext context, int index) {
          return TextButton(
            onPressed: () async {
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

                              if(alertReturn)
                                setState(() {
                                  courseStore.addToUserFavoriteCourses(userFavoriteCourses[index]);
                                });
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
        });
  }

  Widget registerPhoneButton(){
    if(courseStore.hasPhoneNumber)
      return SizedBox();
    return Expanded(
      flex: 2,
      child: TextButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return AuthenticationPage(FormName.RegisterPhoneNumber);
          }));
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
    return ListView.builder(
        itemCount: userCourses.length,
        itemBuilder: (BuildContext context, int index) {
          return TextButton(
            onPressed: () async {
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
        });
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
    if (token != null && token.isNotEmpty && !courseStore.isTokenExpired(token))
      await courseStore.setUserDetails(token, hasPhoneNumber.toLowerCase() == 'true', salespersonCouponCode);
    else if(courseStore.isTokenExpired(token)){
      await secureStorage.write(key: 'token', value: '');
      await secureStorage.write(key: 'hasPhoneNumber', value: 'false');
      await courseStore.setUserDetails('', false, '');
    }
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
            return Container(
              color: Color(0xFF202028),
              child: SpinKitWave(
                color: Color(0xFF20BFA9),
                size: 100.0,
              ),
            );
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
