import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/screens/now_playing.dart';
import 'package:mobile/services/authentication_service.dart';
import 'package:mobile/services/course_episode_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'authentication_page.dart';
import 'checkout_page.dart';

class CoursePage extends StatefulWidget {
  CoursePage(this.courseDetails, this.courseCover);
  CoursePage.noPhoto(this.courseDetails, this.noPictureAsset);

  final Course courseDetails;
  var courseCover;
  String noPictureAsset;

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  Widget scrollView;
  double width;
  double height;
  List<Widget> episodesList = List<Widget>();
  Future<dynamic> episodesFuture;
  CourseStore courseStore;
  bool isEpisodePurchasedBefore = false;
  bool isWholeCourseAvailable = true;
  AuthenticationService authService = AuthenticationService();
  bool alertReturn = false;
  int nonFreeEpisodesCount = 0;
  int purchasedEpisodesCount = 0;
  final secureStorage = FlutterSecureStorage();
  bool isTakingMuchTime = false;
  Duration _timerDuration = new Duration(seconds: 15);
  bool isVpnConnected = false;
  final currencyFormat = new NumberFormat("#,##0");
  int totalEpisodesCount = 0;
  double totalEpisodesPrice = 0;
  List<CourseEpisode> courseEpisodes = List<CourseEpisode>();



  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    episodesFuture = getCourseEpisodes();
  }

  Future<List<CourseEpisode>> getCourseEpisodes() async{
    RestartableTimer(_timerDuration, setTimerState);
    CourseEpisodeData courseEpisodeData = CourseEpisodeData();
    courseEpisodes =
      await courseEpisodeData.getCourseEpisodes(widget.courseDetails.id);

    if(courseEpisodes != null)
      await updateUI(widget.courseDetails, courseEpisodes);

    return courseEpisodes;
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

    return basketEpisodes;
  }

  Future<bool> isEpisodeAccessible(
      int courseId,
      int episodeSortNumber,
      int waitingTime) async
  {
    String courseKey = 'course' + courseId.toString();
    String inProgressCourseCachedValue = await secureStorage.read(key: courseKey);
    if(inProgressCourseCachedValue == null && episodeSortNumber != 0){
      AlertDialog alert = AlertDialog(
        title: Text('توجه'),
        content: Text('لطفا دوره را از اولین قسمت شروع کنید'),
      );
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      return false;
    }
    else if(inProgressCourseCachedValue != null){
      List<String> inProgressCourseItems = inProgressCourseCachedValue.split(',');
      int lastFinishedEpisodeSortNumber = int.parse(inProgressCourseItems[0]);
      int sortDifference = episodeSortNumber - lastFinishedEpisodeSortNumber;
      DateTime lastFinishedEpisodeTime = DateTime.parse(inProgressCourseItems[1]);
      String nextEpisode = (lastFinishedEpisodeSortNumber + 2).toString();
      if(sortDifference > 0){
        if(sortDifference > 1){
          AlertDialog alert = AlertDialog(
            title: Text('توجه'),
            content: Text('هنوز قسمت $nextEpisode را گوش نداده اید'),
          );
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
          return false;
        }
        else{
          DateTime currentTime = DateTime.now();
          int timeElapsedSinceLastEpisode = currentTime
              .difference(lastFinishedEpisodeTime).inHours;
          if(timeElapsedSinceLastEpisode < waitingTime){
            int remainedTimeToWait = waitingTime - timeElapsedSinceLastEpisode;
            AlertDialog alert = AlertDialog(
              title: Text('توجه'),
              content: Text('زمان انتظار بین هر دو قسمت در این دوره، $waitingTime است.'
                  ' این قسمت $remainedTimeToWait ساعت دیگر در دسترس شما قرار میگیرد'),
            );
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              },
            );
            return false;
          }
        }
      }
    }
    return true;
  }

  Future writeInProgressCourseInCache(CourseEpisode episode) async{
    String courseKey = 'course' + episode.courseId.toString();
    String inProgressCourseCacheValue =
        episode.sort.toString() + ',' +
        DateTime.now().toString();
    await secureStorage.write(
        key: courseKey,
        value: inProgressCourseCacheValue);
  }

  Future<bool> isEpisodePlayedBefore(CourseEpisode episode) async{
    String courseKey = 'course' + episode.courseId.toString();
    String inProgressCourseCachedValue = await secureStorage.read(key: courseKey);
    if(inProgressCourseCachedValue == null){
      return false;
    }
    else if(inProgressCourseCachedValue != null){
      List<String> inProgressCourseItems = inProgressCourseCachedValue.split(',');
      int lastFinishedEpisodeSortNumber = int.parse(inProgressCourseItems[0]);
      if(episode.sort > lastFinishedEpisodeSortNumber)
        return false;
    }
    return true;
  }

  String getEpisodeDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future playEpisode(Course course, CourseEpisode episode) async{
    if(episode.price != 0 && episode.price != null){
      if (courseStore.token != null && courseStore.token != ''){
        isEpisodePurchasedBefore = false;
        courseStore.userEpisodes.forEach((element) {
          if(element.id == episode.id){
            isEpisodePurchasedBefore = true;
          }
        });
        if(!isEpisodePurchasedBefore){
          List<CourseEpisode> tempEpisodes = [];
          tempEpisodes.add(episode);
          await createBasket(PurchaseType.SingleEpisode, tempEpisodes, course);
        }
        else{
          if(await isEpisodeAccessible(
              episode.courseId,
              episode.sort,
              course.waitingTimeBetweenEpisodes))
          {
            if(!(await isEpisodePlayedBefore(episode)))
              await writeInProgressCourseInCache(episode);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return NowPlaying(episode, course.photoAddress);
                }));
          }
        }
      }
      else {
        bool goToSignUpPage = false;
        AlertDialog alert = AlertDialog(
          title: Text('توجه'),
          content: Text('برای خرید دوره آموزشی، ابتدا باید ثبت نام کنید'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: 400,
                height: 70,
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
              height: 70,
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
        if(goToSignUpPage){

          await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
                return AuthenticationPage(FormName.SignUp);
              }));
          isEpisodePurchasedBefore = false;
          courseStore.userEpisodes.forEach((element) {
            if(element.id == episode.id){
              isEpisodePurchasedBefore = true;
            }
          });
          if(!isEpisodePurchasedBefore){
            List<CourseEpisode> tempEpisodes = [];
            tempEpisodes.add(episode);
            await createBasket(PurchaseType.SingleEpisode, tempEpisodes, course);
          }
          else{
            if(await isEpisodeAccessible(
                episode.courseId,
                episode.sort,
                course.waitingTimeBetweenEpisodes))
            {
              if(!(await isEpisodePlayedBefore(episode)))
                await writeInProgressCourseInCache(episode);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return NowPlaying(episode, course.photoAddress);
                  }));
            }
          }
        }
      }
    }
    else{
      if(await isEpisodeAccessible(
          episode.courseId,
          episode.sort,
          course.waitingTimeBetweenEpisodes))
      {
        if(!(await isEpisodePlayedBefore(episode)))
          await writeInProgressCourseInCache(episode);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return NowPlaying(episode, course.photoAddress);
            }));
      }
    }
  }

  Future updateUI(Course course, List<CourseEpisode> episodes) async {
    episodesList = List<Widget>();
    for (var episode in episodes) {
      // String picUrl = course.photoAddress;
      String episodeName = episode.name;
      String episodeDescription = episode.description;
      Duration duration = Duration(
          seconds: episode.totalEpisodeAudio != 0 ?
              episode.totalEpisodeAudio.toInt() : 0);

      totalEpisodesCount++;
      totalEpisodesPrice += episode.price;
      String episodeDuration = getEpisodeDuration(duration);
      var picFile = widget.courseCover;

      if(episode.price != 0 && episode.price != null)
        nonFreeEpisodesCount++;

      isEpisodePurchasedBefore = false;
      if(courseStore.userEpisodes != null){
        for(CourseEpisode tempEpisode in courseStore.userEpisodes){
          if(tempEpisode.id == episode.id)
          {
            purchasedEpisodesCount++;
            isEpisodePurchasedBefore = true;
            break;
          }
        }
      }

      episodesList.add(Padding(
        padding: const EdgeInsets.fromLTRB(8,8,8,0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: InkWell(
                    onTap: () async{
                      await playEpisode(course, episode);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: picFile != null ?
                        Image.file(
                          picFile,
                          height: height/10,
                        ):
                        Image.asset(widget.noPictureAsset),
                    ),
                  ),
                ),
                Expanded(
                  flex: 21,
                  child: InkWell(
                    onTap: () async{
                      await playEpisode(course, episode);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            episodeName,
                            style: TextStyle(fontSize: 16),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Color(0xFFFFFFFF),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  episodeDuration,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          )],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 12,
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () async {
                            AlertDialog alert = AlertDialog(
                              title: Text(episodeName),
                              content: Text(episodeDescription),
                            );
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );
                          },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.preview,
                                size: 20,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                            Text(
                              'توضیحات',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),)
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async{
                          await playEpisode(course, episode);
                        },
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            (isEpisodePurchasedBefore ||
                                episode.price == 0 ||
                                episode.price == null) ?
                            Icon(
                              Icons.play_arrow_outlined,
                              size: 30,
                              color: Color(0xFFFFFFFF),
                            ):
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.add_shopping_cart,
                                size: 25,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                            Text(
                              (isEpisodePurchasedBefore ||
                                  episode.price == 0 ||
                                  episode.price == null)  ? 'پخش' : 'خرید',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Expanded(
                //   flex: 4,
                //   child: TextButton(
                //     onPressed: () async{
                //       await playEpisode(course, episode);
                //     },
                //     child:
                //       (isEpisodePurchasedBefore ||
                //        episode.price == 0 ||
                //        episode.price == null) ?
                //           Icon(
                //             Icons.play_arrow_outlined,
                //             size: 35,
                //             color: Color(0xFFFFFFFF),
                //           ):
                //           Icon(
                //             Icons.add_shopping_cart,
                //             size: 25,
                //             color: Color(0xFFFFFFFF),
                //           ),
                //   ),
                // )
              ],
            ),
            SizedBox(
              width: width * 0.89,
              child: Divider(
                color: Colors.black26,
              ),
            )
          ]
        ),
      ));
    }

    scrollView = CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0.0,
          floating: false, pinned: true, snap: false,
          backgroundColor: Colors.transparent,
          //title: Text(course['name']),
          expandedHeight: 150,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: widget.courseCover != null ?
                    FileImage(widget.courseCover) :
                    AssetImage(widget.noPictureAsset),
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  color: Colors.black12.withOpacity(0.3),
                ),
              ),
            ),
            title:
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.courseCover != null ?
                    Image.file(
                      widget.courseCover,
                    ):
                    Image.asset(
                      widget.noPictureAsset,
                    ),
                ],
              ),
            ),
            titlePadding: EdgeInsetsDirectional.fromSTEB(10, 80, 0, 10),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              textBaseline: TextBaseline.ideographic,
              children: <Widget>[
                Expanded(
                  flex: 9,
                  child: Text(
                    course.name,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: () async {
                      AlertDialog alert = AlertDialog(
                        title: Text(widget.courseDetails.name),
                        content: Text(widget.courseDetails.description),
                      );
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    },
                    icon: Icon(
                      Icons.preview,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: () async {
                      String userFavoriteCourseIds = await secureStorage
                          .read(key: 'UserFavoriteCourseIds');
                      if(courseStore.addToUserFavoriteCourses(widget.courseDetails)){
                        Fluttertoast.showToast(msg: 'دوره به علاقه مندی های شما افزوده شد');
                        String courseId = widget.courseDetails.id.toString();
                        userFavoriteCourseIds == null ?
                        userFavoriteCourseIds = courseId :
                        userFavoriteCourseIds += ',' + courseId;
                        await secureStorage.write(
                            key: 'UserFavoriteCourseIds',
                            value: userFavoriteCourseIds);
                      }
                      else{
                        Fluttertoast.showToast(msg: 'دوره از علاقه مندی های شما حذف شد');
                        List<String> favCourseIds = userFavoriteCourseIds.split(',');
                        userFavoriteCourseIds = '';
                        favCourseIds.forEach((element) {
                          if(element != widget.courseDetails.id.toString())
                            userFavoriteCourseIds += element + ',';
                        });
                        await secureStorage.write(
                            key: 'UserFavoriteCourseIds',
                            value: userFavoriteCourseIds);
                      }
                    },
                    icon: Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: coursePurchaseButton(episodes, course),
                )
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Container(
              child: episodesList[index],
            ),
            childCount: episodesList.length,
          ),
        )
      ],
    );
  }

  Widget coursePurchaseButton(List<CourseEpisode> episodes, Course course){
    if(nonFreeEpisodesCount == purchasedEpisodesCount)
      return Text('');
    else
      return IconButton(
        onPressed: () async{
          if (courseStore.token != null && courseStore.token != ''){
            await createBasket(PurchaseType.WholeCourse, episodes, course);
          }
          else {
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
            if(goToSignUpPage){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return AuthenticationPage(FormName.SignUp);
                  }));

              await createBasket(PurchaseType.WholeCourse, episodes, course);
            }
          }
        },
        icon: Icon(
          Icons.add_shopping_cart,
          size: 20,
          color: Colors.white,
        ),
      );
  }

  Future createBasket(PurchaseType purchaseType, List<CourseEpisode> episodes, Course course) async{
    if(courseStore.token != null && courseStore.token != ''){
      if(purchaseType == PurchaseType.WholeCourse){
        List<CourseEpisode> episodesToBePurchased = [];
        for(var episode in episodes){
          if(episode.price != null || episode.price != 0)
            episodesToBePurchased.add(episode);
        }
        List<CourseEpisode> finaleEpisodeIds = await eliminateRepetitiveEpisodes(episodesToBePurchased);
          await courseStore.setUserBasket(finaleEpisodeIds, course /*isWholeCourseAvailable ? course : null*/);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) {
                return CheckOutPage();
              })
          );
      }
      else{
        bool isAgree = false;
        bool isCancelled = true;
        AlertDialog alert = AlertDialog(
          scrollable: true,
          backgroundColor: Colors.white70,
          title: Text('توجه', style: TextStyle(color: Colors.black,)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('این دوره شامل $totalEpisodesCount قسمت می باشد.', style: TextStyle(color: Colors.black,)),
              Text('در صورت خرید دوره بصورت یکجا، خرید شما شامل ', style: TextStyle(color: Colors.black,)),
              Text('${(100 - widget.courseDetails.price / totalEpisodesPrice * 100).toStringAsFixed(1)} درصد تخفیف خواهد شد.', style: TextStyle(color: Colors.black,)),
              SizedBox(
                height: 40,
              ),
              Text(
                'قیمت این قسمت:',
                style: TextStyle(color: Colors.red),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                      currencyFormat.format(episodes[0].price/10000)
                          + " هزار تومان",
                      style: TextStyle(color: Colors.red)),
                ],
              ),
              Text(
                'قیمت دوره کامل:',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                      currencyFormat.format(widget.courseDetails.price/10000)
                          + " هزار تومان",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                'قیمت دوره (قسمت به قسمت):',
                style: TextStyle(color: Colors.red),),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(totalEpisodesPrice/10000).toString() + " هزار تومان",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: 400,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(5),

                ),
                child: TextButton(
                  onPressed: (){
                    isCancelled = false;
                    isAgree = false;
                    Navigator.of(context).pop();
                  },
                  child:
                  Text(
                      'خرید دوره به صورت کامل',
                      style: TextStyle(color: Colors.black,)
                  ),
                ),
              ),
            ),
            Container(
              width: 400,
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5),

              ),
              child: TextButton(
                onPressed: (){
                  isCancelled = false;
                  isAgree = true;
                  Navigator.of(context).pop();
                },
                child:
                Text(
                    'خرید قسمت انتخاب شده',
                    style: TextStyle(color: Colors.black,)
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

        if(!isCancelled && isAgree) {
          if (courseStore.userEpisodes.contains(episodes[0]))
            Fluttertoast.showToast(msg: 'این قسمت را قبلا خریداری کرده اید');
          else {
            await courseStore.setUserBasket(episodes, null);
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CheckOutPage();
            }));
          }
        }
        else if(!isCancelled){
          // List<CourseEpisode> episodesToBePurchased = [];
          // for(var episode in courseEpisodes){
          //   if(episode.price != null || episode.price != 0)
          //     episodesToBePurchased.add(episode);
          // }
          // List<CourseEpisode> basketEpisodes = List.from(episodes);
          // List<int> courseEpisodeIds = List<int>();
          // basketEpisodes.forEach((episode) {
          //   courseEpisodeIds.add(episode.id);
          // });
          // courseStore.userEpisodes.forEach((episode) {
          //   if(courseEpisodeIds.contains(episode.id)){
          //     basketEpisodes.removeWhere((ep) => ep.id == episode.id);
          //     isWholeCourseAvailable = false;
          //   }
          // });
          // basketEpisodes.removeWhere((ep) => ep.price == 0);
          // await courseStore.setUserBasket(basketEpisodes, widget.courseDetails /*isWholeCourseAvailable ? course : null*/);
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) {
          //       return CheckOutPage();
          //     })
          // );
          List<CourseEpisode> episodes = List<CourseEpisode>();
          CourseEpisodeData courseEpisodeData = CourseEpisodeData();
          episodes = await courseEpisodeData.getCourseEpisodes(course.id);

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
      }
    }
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
      onPressed: () {
        Navigator.of(context).pop();
        alertReturn = true;
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

  Widget spinner(){
    return Scaffold(
        body: !isTakingMuchTime ? SpinKitWave(
          type: SpinKitWaveType.center,
          color: Color(0xFF20BFA9),
          size: 65.0,
        ) :
        Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container(
                //     width: width * 1.5,
                //     child: Image.asset('assets/images/internetdown.png')
                // ),
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
                )
              ]
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

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    // iconData = Icons.favorite_border;
    // courseStore.userFavoriteCourses.contains(widget.courseDetails) ?
    //     iconData = Icons.favorite : iconData = Icons.favorite_border;

    return FutureBuilder(
        future: episodesFuture,
        builder: (context, data){
          if(data.hasData){
            return SafeArea(
                child: Scaffold(
                    body: scrollView,
                ),
            );
          }
          else{
            return spinner();
          }
        }
    );
  }
}