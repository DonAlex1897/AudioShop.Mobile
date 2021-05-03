import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/screens/course_preview.dart';
import 'package:mobile/services/course_service.dart';
import 'package:async/async.dart';

class SearchResultPage extends StatefulWidget {
  SearchResultPage(this.courseName);
  final String courseName;

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  Future<List<Course>> coursesFuture;
  List<Course> coursesList = List<Course>();
  bool isTakingMuchTime = false;
  Duration _timerDuration = new Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    coursesFuture = getCourses(widget.courseName);
  }

  Future<List<Course>> getCourses(String searchParameter) async{
    RestartableTimer(_timerDuration, setTimerState);
    CourseData courseData = CourseData();
    coursesList = await courseData.searchCourses(searchParameter);
    return coursesList;
  }


  goToCoursePreview(Course course){
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CoursePreview(course);
    }));
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
                Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Image.asset('assets/images/internetdown.png')
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'لطفا اتصال اینترنت خود را بررسی کنید',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
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
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: coursesFuture,
      builder: (context, data){
        if(data.hasData)
          return Scaffold(
            body: coursesList.length == 0 ?
                Center(
                  child: Text(
                    'دوره ای پیدا نشد',
                    style: TextStyle(fontSize: 30),
                  ),
                )
                : ListView.builder(
                itemCount: coursesList.length,
                itemBuilder: (BuildContext context, int index) {
                  return TextButton(
                    onPressed: () async {
                      goToCoursePreview(coursesList[index]);
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
                                      coursesList[index].photoAddress),
                                )),
                            Expanded(
                              flex: 6,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                  child: Text(
                                    coursesList[index].name,
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
        else
          return spinner();
      });
  }
}
