import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/screens/advertisement_page.dart';
import 'package:mobile/screens/course_preview.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/store/course_store.dart';
import 'package:mobile/utilities/Utility.dart';
import 'package:provider/provider.dart';

class CourseCard extends StatefulWidget {
  final Future<List<Course>> coursesFuture;
  final List<Course> courses;
  final List<File> picFiles;
  CourseCard(this.coursesFuture, this.courses,this.picFiles);

  @override
  _CourseCardState createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  CourseStore courseStore;
  bool showAdsInPopUp = true;

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

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);
    return FutureBuilder(
        future: widget.coursesFuture,
        builder: (context, data){
          if(data.hasData){
            return widget.courses != null && widget.courses.length > 0 ?
              ListView.builder(
                scrollDirection: Axis.horizontal,
                // shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                itemCount: widget.courses == null ? 0 : widget.courses.length,
                itemBuilder: (BuildContext context, int index){
                  String picUrl = widget.courses[index].photoAddress;
                  String courseName = widget.courses[index].name;
                  return Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.42,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.black38),
                      child: TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(vertical: 0, horizontal: 0)),
                        ),
                        onPressed: () {
                          // goToCoursePage(course, pictureFile);
                          goToCoursePreview(widget.courses[index]);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                      child: widget.picFiles[index] != null ?
                                      Image.file(
                                        widget.picFiles[index],
                                        fit: BoxFit.fill,
                                      ):
                                      Image.asset(
                                        'assets/images/noPicture.png',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        courseName,
                                        // overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5,0,5,0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        widget.courses[index].instructor != null ?
                                        widget.courses[index].instructor : 'اِستارشو',
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
                                            widget.courses[index].averageScore != null ?
                                            widget.courses[index].averageScore.toStringAsFixed(1):'5.0',
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
            ) :
              Center(
                child: Text(
                  'موردی پیدا نشد',
                  style: TextStyle(fontSize: 25),
                ),
              )
            ;
          }
          else{
            return SpinKitWave(
              type: SpinKitWaveType.center,
              color: Color(0xFF20BFA9),
              size: 25.0,
            );
          }
        }
    );
  }
}
