import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/models/review.dart';
import 'package:mobile/screens/course_page.dart';
import 'package:mobile/services/course_service.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'dart:ui' as ui;

class CoursePreview extends StatefulWidget {

  CoursePreview(this.courseDetails);
  final Course courseDetails;
  @override
  _CoursePreviewState createState() => _CoursePreviewState();
}

class _CoursePreviewState extends State<CoursePreview> {
  Future<List<Review>> courseReviews;
  List<Review> courseReviewList;
  CourseData courseData = CourseData();
  TextEditingController reviewController = TextEditingController();
  CourseStore courseStore;
  double yourRate = 0;
  double averageCourseRate = 0;
  String favoriteButtonText = 'افزودن به علاقه مندی';
  final secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    courseReviews = getCourseReviews();
  }

  Future<List<Review>> getCourseReviews() async{
    courseReviewList = await courseData.getCourseReviews(widget.courseDetails.id);
    int allReviewsRateSum = 0;
    courseReviewList.forEach((element) {
      allReviewsRateSum += element.rating;
    });
    averageCourseRate = allReviewsRateSum / courseReviewList.length;
    return courseReviewList;
  }

  Future postReview() async{
    Review review = Review(
      userId: courseStore.userId,
      text: reviewController.text,
      rating: yourRate.toInt(),
      courseId: widget.courseDetails.id,
      userFirstName: courseStore.userName
    );
    if(courseStore.token != '' && courseStore.token != null)
      bool sentReview = await courseData.addReviewToCourse(review, courseStore.token);
    else
      Fluttertoast.showToast(msg: 'برای ثبت نظر باید وارد حساب کاربریتان شوید');
  }

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);
    Course course = widget.courseDetails;
    courseStore.userFavoriteCourses.contains(widget.courseDetails) ?
      favoriteButtonText = 'حذف از علاقه مندی':
      favoriteButtonText = 'افزودن به علاقه مندی';

    return FutureBuilder(
      future: courseReviews,
      builder: (context, data){
        if(data.hasData){
          return SafeArea(
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(course.photoAddress),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            course.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21.0,
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
                              var pictureFile = await DefaultCacheManager()
                                  .getSingleFile(course.photoAddress);
                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return CoursePage(course, pictureFile);
                              }));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Text(
                                'ادامه به دوره',
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
                        padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 10),
                        child: Center(
                          child: Text(
                            course.description,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23.0,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  color: Color(0xFF20BFA9),
                                  child: TextButton(
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

                                      if(courseStore.userFavoriteCourses.contains(widget.courseDetails))
                                        setState(() {
                                          favoriteButtonText = 'حذف از علاقه مندی';
                                        });
                                      else
                                        setState(() {
                                          favoriteButtonText = 'افزودن به علاقه مندی';
                                        });
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(
                                          Icons.library_add,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          favoriteButtonText,
                                          style: TextStyle(color: Colors.white),)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  color: Color(0xFF20BFA9),
                                  child: TextButton(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          Icons.add_shopping_cart,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          'خرید',
                                          style: TextStyle(color: Colors.white),)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Divider(
                          color: Colors.black
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text('نظرات کاربران', style: TextStyle(fontSize: 17),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
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
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 5),
                        child: TextField(
                          minLines: 1,
                          maxLines: 15,
                          style: TextStyle(
                              decorationColor: Colors.black, color: Colors.white),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
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
                              child: Card(
                                color: Color(0xFF20BFA9),
                                child: TextButton(
                                  onPressed: () async {
                                    if (reviewController.text.isNotEmpty && yourRate != 0)
                                      await postReview();
                                    else if(reviewController.text.isEmpty)
                                      Fluttertoast.showToast(msg: 'لطفا نظر خود را بنویسید');
                                    else
                                      Fluttertoast.showToast(msg: 'لطفا امتیاز خود را با انتخاب تعداد ستاره مشخص کنید');
                                  },
                                  child: Text(
                                    'ارسال',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                color: Colors.red[700],
                                child: TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      reviewController.text = '';
                                    });
                                  },
                                  child: Text(
                                    'پاک کردن',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
          return Container(
            color: Color(0xFF202028),
            child: SpinKitWave(
              type: SpinKitWaveType.center,
              color: Color(0xFF20BFA9),
              size: 65.0,
            ),
          );
      }
    );
  }
}
