import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/screens/course_preview.dart';
import 'package:mobile/services/course_service.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/enums.dart';
import 'package:mobile/utilities/nativeAd.dart';

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
  bool isFirstSearch = true;
  Duration _timerDuration = new Duration(seconds: 15);
  double width = 0;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  Widget appBarTitle = new Text("اِستارشو");
  Icon actionIcon = new Icon(Icons.search);
  bool isVpnConnected = false;
  bool showLoadingUpAds = false;
  bool showLoadingDownAds = false;

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

  goToCoursePreview(Course course){
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CoursePreview(course);
    }));
  }

  Widget spinner(){
    return isFirstSearch ?
    Scaffold(
        body: !isTakingMuchTime ?
        Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                showLoadingUpAds ?
                  NativeAd(NativeAdLocation.LoadingUp) : SizedBox(),
                SpinKitWave(
                  type: SpinKitWaveType.center,
                  color: Color(0xFF20BFA9),
                  size: 65.0,
                ),
                showLoadingDownAds ?
                  NativeAd(NativeAdLocation.LoadingDown) : SizedBox(),
              ],
            ),
          ),
        ) :
        Center(
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container(
                  //     width: MediaQuery.of(context).size.width * 0.7,
                  //     child: Image.asset('assets/images/internetdown.png')
                  // )
                  showLoadingUpAds ?
                    NativeAd(NativeAdLocation.LoadingUp) : SizedBox(),
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
                    NativeAd(NativeAdLocation.LoadingDown) : SizedBox(),
                ]
            ),
          ),
        )
    ) :
    (!isTakingMuchTime ?
    Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            showLoadingUpAds ?
            NativeAd(NativeAdLocation.LoadingUp) : SizedBox(),
            SpinKitWave(
              type: SpinKitWaveType.center,
              color: Color(0xFF20BFA9),
              size: 65.0,
            ),
            showLoadingDownAds ?
            NativeAd(NativeAdLocation.LoadingDown) : SizedBox(),
          ],
        ),
      ),
    ) :
      Center(
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Image.asset('assets/images/internetdown.png')
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(!isVpnConnected ?
                    'لطفا اتصال اینترنت خود را بررسی کنید' :
                    'لطفا جهت برخورداری از سرعت بیشتر، فیلتر شکن خود را قطع کنید',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
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
        ),
      ));
  }

  setTimerState() {
    setState(() {
      isTakingMuchTime = true;
    });
    // checkVpnConnection();
  }

  Widget searchResult(){
    return isSearching ?
    spinner() :
    (coursesList.length == 0 ?
      Center(
      child: Text(
        'دوره ای پیدا نشد',
        style: TextStyle(fontSize: 30),
      ),
    ) :
      ListView.builder(
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
        })
    );
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
    return FutureBuilder(
      future: coursesFuture,
      builder: (context, data){
        if(data.hasData)
          return Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: appBarTitle,
                actions: <Widget>[
                  new IconButton(icon: actionIcon,onPressed:(){
                    setState(() {
                      if (this.actionIcon.icon == Icons.search) {
                        this.actionIcon = new Icon(Icons.close, color: Colors.white,);
                        this.appBarTitle = new TextField(
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) async{
                            isFirstSearch = false;
                            setState(() {
                              isSearching = true;
                            });
                            coursesList = await getCourses(value);
                            setState(() {
                              isSearching = false;
                            });
                          },
                          controller: searchController,
                          style: new TextStyle(
                            color: Colors.white,

                          ),
                          decoration: new InputDecoration(
                            prefixIcon: InkWell(
                              onTap: () async{
                                isFirstSearch = false;
                                setState(() {
                                  isSearching = true;
                                });
                                coursesList = await getCourses(searchController.text);
                                setState(() {
                                  isSearching = false;
                                });
                              },
                              child: Icon(Icons.search,
                                  size: 25, color: Colors.white),
                            ),
                            hintText: "جستجو...",
                            hintStyle: new TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      else {
                        _handleSearchEnd();
                      }
                    });
                  } ,
                  ),
                ]
            ),
            body: searchResult(),
          );
        else
          return spinner();
      });
  }
}


//Former Search Widget
// Padding(
// padding: const EdgeInsets.only(top: 8.0, bottom: 0.8),
// child: Row(
// children: [
// Padding(
// padding: const EdgeInsets.only(left: 5, right: 5),
// child: Container(
// width: MediaQuery.of(context).size.width - 10,
// child: TextField(
// textInputAction: TextInputAction.search,
// onSubmitted: (value) async{
// isFirstSearch = false;
// setState(() {
// isSearching = true;
// });
// coursesList = await getCourses(value);
// setState(() {
// isSearching = false;
// });
// },
// style: TextStyle(color: Colors.white),
// keyboardType: TextInputType.text,
// decoration: InputDecoration(
// prefixIcon: InkWell(
// onTap: () async {
// isFirstSearch = false;
// setState(() {
// isSearching = true;
// });
// coursesList = await getCourses(searchController.text);
// setState(() {
// isSearching = false;
// });
// },
// child: Icon(Icons.search,
// size: 25, color: Colors.white),
// ),
// contentPadding: EdgeInsets.symmetric(horizontal: 10),
// border: OutlineInputBorder(),
// enabledBorder: OutlineInputBorder(
// borderSide: BorderSide(
// color: Colors.white, width: 2.0),
// ),
// focusedBorder: OutlineInputBorder(
// borderSide: BorderSide(
// color: Colors.white, width: 2.0),
// ),
// labelText: 'جستجو',floatingLabelBehavior: FloatingLabelBehavior.never,
// labelStyle: TextStyle(
// color: Colors.white,
// ),
// ),
// controller: searchController,
// ),
// ),
// ),
// ],
// ),
// ),
