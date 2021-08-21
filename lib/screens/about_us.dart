import 'package:flutter/material.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  CourseStore courseStore;
  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(Icons.arrow_back_ios),
            title: Text('درباره اِستارشو'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: MediaQuery.of(context).size.width * 0.15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage('assets/images/appMainIcon.png'),
                              fit: BoxFit.fill
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                      courseStore.aboutUs
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
