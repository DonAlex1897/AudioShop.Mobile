import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/screens/now_playing.dart';
import 'package:mobile/services/authentication_service.dart';
import 'package:mobile/services/course_episode_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';

import 'authentication_page.dart';
import 'checkout_page.dart';

class CoursePage extends StatefulWidget {
  CoursePage(this.courseDetails, this.courseCover);

  final Course courseDetails;
  final courseCover;

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
    CourseEpisodeData courseEpisodeData = CourseEpisodeData();
    List<CourseEpisode> courseEpisodes =
      await courseEpisodeData.getCourseEpisodes(widget.courseDetails.id);

    if(courseEpisodes != null)
      await updateUI(widget.courseDetails, courseEpisodes);

    return courseEpisodes;
  }

  Future<List<CourseEpisode>> eliminateRepetitiveEpisodes(List<CourseEpisode> episodes) async{

      List<CourseEpisode> basketEpisodes = List.from(episodes);

      courseStore.userEpisodes.forEach((episode) {
        if(episodes.contains(episode)){
          basketEpisodes.remove(episode);
          isWholeCourseAvailable = false;
        }
      });

      return basketEpisodes;
  }

  Future updateUI(Course course, List<CourseEpisode> episodes) async {
    episodesList = List<Widget>();
    for (var episode in episodes) {
      String picUrl = course.photoAddress;
      String episodeName = episode.name;
      String episodeDescription = episode.description;
      var picFile = widget.courseCover;

      isEpisodePurchasedBefore = false;
      if(courseStore.userEpisodes != null){
        for(CourseEpisode tempEpisode in courseStore.userEpisodes){
          if(tempEpisode.id == episode.id)
          {
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      picFile,
                      height: height/10,),
                  ),
                ),
                Expanded(
                  flex: 25,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          episodeName,
                          style: TextStyle(fontSize: 16),),
                        Text(
                          episodeDescription,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12),)],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: TextButton(
                    onPressed: () async{
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
                            await createBasket(PurchaseType.SingleEpisode, tempEpisodes, null);
                          }
                          else{
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return NowPlaying(episode, course.photoAddress);
                                }));
                          }
                        }
                        else {
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return AuthenticationPage(FormName.SignUp);
                              }));
                          List<CourseEpisode> tempEpisodes = [];
                          tempEpisodes.add(episode);
                          await createBasket(PurchaseType.SingleEpisode, tempEpisodes, null);
                        }
                      }
                      else{
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return NowPlaying(episode, course.photoAddress);
                            }));
                      }
                    },
                    child: Icon((isEpisodePurchasedBefore ||
                          episode.price == 0 || episode.price == null) ?
                        Icons.play_arrow_outlined : Icons.add_shopping_cart,
                        size: 32,
                        color: Color(0xFFFFFFFF),
                    ),
                  ),
                )
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
          //floating: false, pinned: false, snap: false,
          backgroundColor: Colors.transparent,
          //title: Text(course['name']),
          expandedHeight: 150,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(widget.courseCover),
                  fit: BoxFit.fill,
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
              child: Image.file(
                widget.courseCover,
              ),
            ),
            titlePadding: EdgeInsetsDirectional.fromSTEB(10, 80, 0, 10),
          ),
          title: Row(
            textBaseline: TextBaseline.ideographic,
            children: <Widget>[
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(
                    course.name,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: TextButton(
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
                  child: Icon(
                    Icons.preview,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: () async{
                    if (courseStore.token != null && courseStore.token != ''){
                      await createBasket(PurchaseType.WholeCourse, episodes, course);
                    }
                    else {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return AuthenticationPage(FormName.SignUp);
                          }));

                      await createBasket(PurchaseType.WholeCourse, episodes, course);

                    }
                  },
                  child: Icon(
                    Icons.add_shopping_cart,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              )
            ],
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

  Future createBasket(PurchaseType purchaseType, List<CourseEpisode> episodes, Course course) async{
    if(purchaseType == PurchaseType.WholeCourse){
      List<CourseEpisode> episodesToBePurchased = [];
      for(var episode in episodes){
        if(episode.price != null || episode.price != 0)
          episodesToBePurchased.add(episode);
      }
      List<CourseEpisode> finaleEpisodeIds = await eliminateRepetitiveEpisodes(episodesToBePurchased);
      if(!isWholeCourseAvailable){
        Widget cancelB = cancelButton('خیر');
        Widget continueB =
        continueButton('بله', Alert.LogOut, null);
        AlertDialog alertD = alert('هشدار',
            'با توجه به اینکه قبلا یک یا چند قسمت از این دوره را خریداری کرده اید، قیمت دوره به صورت مجموع قیمت تمام قسمتها محاسبه می شود. ادامه خرید؟',
            [cancelB, continueB]);

        await showBasketAlertDialog(context, alertD);

        if(alertReturn){
          await courseStore.setUserBasket(finaleEpisodeIds, isWholeCourseAvailable ? course : null);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) {
                return CheckOutPage();
              })
          );
        }
        alertReturn = false;
      }
      else{
        await courseStore.setUserBasket(finaleEpisodeIds, isWholeCourseAvailable ? course : null);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return CheckOutPage();
            })
        );
      }
    }
    else{
      if(courseStore.userEpisodes.contains(episodes[0]))
        Fluttertoast.showToast(msg: 'این قسمت را قبلا خریداری کرده اید');
      else{
        await courseStore.setUserBasket(episodes, null);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return CheckOutPage();
            })
        );
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

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

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
            return SpinKitWave(
              color: Color(0xFF20BFA9),
              size: 100.0,
            );
          }
        }
    );
  }
}