import 'package:flutter/material.dart';
import 'package:mobile/utilities/multi_manager/flick_multi_manager.dart';
import 'package:mobile/utilities/multi_manager/flick_multi_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:async/async.dart';

class AdvertisementPage extends StatefulWidget {
  @override
  _AdvertisementPageState createState() => _AdvertisementPageState();
}

class _AdvertisementPageState extends State<AdvertisementPage> {

  FlickMultiManager flickMultiManager;
  String tempURL = 'https://file-examples-com.github.io/uploads/2018/04/file_example_MOV_480_700kB.mov';
  // String tempURL = 'https://www.kolpaper.com/wp-content/uploads/2021/02/Juve-Stadium-Wallpaper.jpg';
  Duration _timerDuration = new Duration(seconds: 5);
  RestartableTimer _timer;
  bool isTimerActive = true;

  @override
  void initState() {
    super.initState();
    flickMultiManager = FlickMultiManager();
    _timer = RestartableTimer(_timerDuration, setTimerState);
  }

  void setTimerState() {
    setState(() {
      isTimerActive = false;
    });
  }

  Widget imageAdvertisementSkipButton(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(5),
          //color: Color(0xFF20BFA9)
        ),
        child: InkWell(
          child: Center(
            child: Text(
              'بستن',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          onTap:() async {
          },
        ),
      ),
    );
  }

  Widget videoAdvertisementSkipButton(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(5),
          //color: Color(0xFF20BFA9)
        ),
        child: InkWell(
          child: Center(
            child: Text(!isTimerActive?
              'بستن' : _timer.tick.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          onTap:() async {
          },
        ),
      ),
    );
  }

  Widget advertisementContinueButton(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          //border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(5),
          color: Color(0xFF20BFA9)
        ),
        child: InkWell(
          child: Center(
            child: Text(
              'نمایش',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap:() async {
          },
        ),
      ),
    );
  }

  Widget advertisement(){
    if(tempURL.toLowerCase().contains('.mov') ||
       tempURL.toLowerCase().contains('.mp4')){
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
              height: MediaQuery.of(context).size.width,
              child: ClipRRect(
                child: FlickMultiPlayer(
                  advertisementURL: tempURL,
                  flickMultiManager: flickMultiManager,
                  image: 'assets/images/appMainIcon.png',
                ),
              )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              advertisementContinueButton(),
              videoAdvertisementSkipButton(),
            ],
          )
        ],
      );
    }
    else{
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                child: Image.network(tempURL)
              )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              advertisementContinueButton(),
              imageAdvertisementSkipButton(),
            ],
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: VisibilityDetector(
          key: ObjectKey(flickMultiManager),
          onVisibilityChanged: (visibility) {
            if (visibility.visibleFraction == 0 && this.mounted) {
              flickMultiManager.pause();
            }
          },
          child: advertisement(),
        ),
      ),
    );
  }
}
