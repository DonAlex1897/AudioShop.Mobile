import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/services/course_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/store/course_store.dart';
import 'package:mobile/utilities/banner_ads.dart';
import 'package:mobile/utilities/course_card.dart';
import 'package:mobile/utilities/horizontal_scrollabe_menu.dart';
import 'package:mobile/utilities/native_ads.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  final CourseType courseType;
  CategoryPage(this.courseType);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  CourseStore courseStore;
  CourseData courseData;
  double width;
  List<String> horizontalScrollableButtonNameList = [];
  List<VoidCallback> horizontalScrollableButtonFunctionList = [];
  Future<List<Category>> categoriesFuture;
  List<Category> categoriesList = [];
  Future<dynamic> courses;
  List<Course> courseList = [];
  List<File> newCoursesPicFiles = [];
  Future<List<Course>> topClickedCoursesFuture;
  List<Course> topClickedCourses = [];
  List<File> topClickedCoursesPicFiles = [];
  Future<List<Course>> featuredCoursesFuture;
  List<Course> featuredCourses = [];
  List<File> featuredCoursesPicFiles = [];
  Future<List<Course>> topSellerCoursesFuture;
  List<Course> topSellerCourses = [];
  List<File> topSellerCoursesPicFiles = [];
  Future<List<Course>> categoryCoursesFuture;
  List<Course> categoryCourses = [];
  List<File> categoryCoursesPicFiles = [];
  bool isFirstLoad = true;

  @override
  void initState() {
    courseData = CourseData();
    categoriesFuture = getCategories();
    courses = getCourses();
    topClickedCoursesFuture = getTopClickedCoursesFuture();
    topSellerCoursesFuture = getTopSellerCoursesFuture();
    featuredCoursesFuture = getFeaturedCoursesFuture();
    super.initState();
  }

  Future<List<Category>> getCategories() async {
    categoriesList = await courseData.getCategories();
    for(var item in categoriesList){
      horizontalScrollableButtonNameList.add(item.title);
      horizontalScrollableButtonFunctionList
          .add(horizontalScrollFunction(item.id, item.title));
    }
    return categoriesList;
  }

  VoidCallback horizontalScrollFunction(int categoryId, String categoryTitle){
    return (){
      setState(() {
        isFirstLoad = false;
      });
      categoryCoursesFuture = getCategoryCourses(categoryTitle);
    };
  }

  Future<List<Course>> getCategoryCourses(String categoryTitle) async {
    categoryCourses = await courseData.getCategoryCourses(widget.courseType, categoryTitle);
    for(var item in categoryCourses){
      File picFile = await DefaultCacheManager()
          .getSingleFile(item.photoAddress);
      categoryCoursesPicFiles.add(picFile);
    }
    setState(() { });
    return categoryCourses;
  }

  Future<List<Course>> getCourses() async {
    courseList = await courseData.getCourses(widget.courseType);
    for(var item in courseList){
      File picFile = await DefaultCacheManager()
          .getSingleFile(item.photoAddress);
      newCoursesPicFiles.add(picFile);
    }
    setState(() { });
    return courseList;
  }

  Future<List<Course>> getTopClickedCoursesFuture() async {
    topClickedCourses = await courseData.getTopClickedCourses(widget.courseType);
    for(var item in topClickedCourses){
      File picFile = await DefaultCacheManager()
          .getSingleFile(item.photoAddress);
      topClickedCoursesPicFiles.add(picFile);
    }
    setState(() { });
    return topClickedCourses;
  }

  Future<List<Course>> getTopSellerCoursesFuture() async {
    topSellerCourses = await courseData.getTopSellerCourses(widget.courseType);
    for(var item in topSellerCourses){
      File picFile = await DefaultCacheManager()
          .getSingleFile(item.photoAddress);
      topSellerCoursesPicFiles.add(picFile);
    }
    setState(() { });
    return topSellerCourses;
  }

  Future<List<Course>> getFeaturedCoursesFuture() async {
    featuredCourses = await courseData.getFeaturedCourses(widget.courseType);
    for(var item in featuredCourses){
      File picFile = await DefaultCacheManager()
          .getSingleFile(item.photoAddress);
      featuredCoursesPicFiles.add(picFile);
    }
    setState(() { });
    return featuredCourses;
  }

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[//CourseCard(coursesFuture, courses, picFiles),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10,10,10,0),
                  child: FutureBuilder(
                      future: categoriesFuture,
                      builder: (context, data){
                        if(data.hasData){
                          return HorizontalScrollableMenu(
                            horizontalScrollableButtonNameList,
                            horizontalScrollableButtonFunctionList,
                          );
                        }
                        else{
                          return SpinKitWave(
                            type: SpinKitWaveType.center,
                            color: Color(0xFF20BFA9),
                            size: 25.0,
                          );
                        }
                      }
                  ),
                ),
                isFirstLoad ? Center(
                  child: SizedBox(
                    height: 25,
                    child: Text(
                      'لطفا دسته بندی مورد نظرتان را انتخاب کنید',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ):
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: width * 2,
                      height: 250,
                      child: CourseCard(categoryCoursesFuture, categoryCourses, categoryCoursesPicFiles)),
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Divider(color: Colors.grey,),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40, right:10),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 25,
                        child: Text(widget.courseType == CourseType.Course ?
                        'جدیدترین دوره ها' : 'جدیدترین کتاب های صوتی',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: width * 2,
                      height: 250,
                      child: CourseCard(topClickedCoursesFuture, topClickedCourses, topClickedCoursesPicFiles)),
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Divider(color: Colors.grey,),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40, right:10),
                  child: SizedBox(
                    height: 25,
                    child: Text(widget.courseType == CourseType.Course ?
                    'پر بازدیدترین دوره ها' : 'پر بازدیدترین کتاب های صوتی',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: width * 2,
                    height: 250,
                    child: CourseCard(courses, courseList, newCoursesPicFiles),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Divider(color: Colors.grey,),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40, right:10),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 25,
                        child: Text(widget.courseType == CourseType.Course ?
                          'پر فروش ترین دوره ها' : 'پر فروش ترین کتاب های صوتی',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: width * 2,
                      height: 250,
                      child: CourseCard(topSellerCoursesFuture, topSellerCourses, topSellerCoursesPicFiles)),
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Divider(color: Colors.grey,),
                  ),
                ),
                courseStore.isAdsEnabled &&
                    courseStore.homePageNative && courseStore.homePageNativeAds != null &&
                    courseStore.homePageNativeAds.isEnabled ?
                NativeAds(courseStore.homePageNativeAds) : SizedBox(),
              ],
            ),
          ),
        ),
    );
  }

}
