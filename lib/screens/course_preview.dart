import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    courseReviews = getCourseReviews();
  }

  Future<List<Review>> getCourseReviews() async{
    courseReviewList = await courseData.getCourseReviews(widget.courseDetails.id);
    return courseReviewList;
  }

  Future postReview() async{
    Review review = Review(
      userId: courseStore.userId,
      text: reviewController.text,
      courseId: widget.courseDetails.id,
      userFirstName: courseStore.userName
    );
  }

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);
    Course course = widget.courseDetails;

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
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(
                          child: Text(
                            course.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(
                          child: Card(
                            color: Color(0xFF20BFA9),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return CoursePage(course, course.photoAddress);
                                }));
                              },
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
                        padding: const EdgeInsets.all(20),
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
                      Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: SmoothStarRating(
                          allowHalfRating: false,
                          onRated: (value){
                            yourRate = value;
                          },
                          color: Colors.yellow,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                        child: TextField(
                          style: TextStyle(
                              decorationColor: Colors.black, color: Colors.white),
                          keyboardType: TextInputType.phone,
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
                        padding: const EdgeInsets.only(left: 20, right: 20),
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
                                      Fluttertoast.showToast(msg: 'لطفا امتیاز خود را انتخاب تعداد ستاره مشخص کنید');
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
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: courseReviewList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              color: Colors.white10,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        courseReviewList[index].userFirstName != null ?
                                          courseReviewList[index].userFirstName :
                                        'کاربر نرم افزار',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        courseReviewList[index].date.toLocal().toString(),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    courseReviewList[index].text,)
                                ],
                              ),
                            );
                          },
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
