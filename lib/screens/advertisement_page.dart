import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/utilities/multi_manager/flick_multi_manager.dart';
import 'package:mobile/utilities/multi_manager/flick_multi_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:async/async.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

import 'course_preview.dart';

class AdvertisementPage extends StatefulWidget {

  AdvertisementPage(this.navigatedPage, this.details);
  final navigatedPage;
  final details;

  @override
  _AdvertisementPageState createState() => _AdvertisementPageState();
}

class _AdvertisementPageState extends State<AdvertisementPage> {

  FlickMultiManager flickMultiManager;
  String tempURL = 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4'; //'https://file-examples-com.github.io/uploads/2018/04/file_example_MOV_480_700kB.mov';
  // String tempURL = 'https://www.kolpaper.com/wp-content/uploads/2021/02/Juve-Stadium-Wallpaper.jpg';
  String redirectURL = 'https://www.dl.farsroid.com/ap/HiPER-Calc-Pro-8.3.8(www.farsroid.com).apk';
  Duration _timerDuration = new Duration(seconds: 5);
  RestartableTimer _timer;
  bool isTimerActive = true;
  bool isMuted = false;


  int downloadProgress = 0;
  String taskId = '';
  String filePath = '';
  String downloadButtonText = 'به روز رسانی';
  DownloadTaskStatus downloadTaskStatus;
  bool isDownloading = false;
  bool isWaitingToStartDownload = false;
  ReceivePort receivePort = ReceivePort();
  bool isAPK = true;

  Future downloadFile() async{
    final permissionStatus = await Permission.storage.request();
    if(permissionStatus.isGranted){
      final baseStorage = await pathProvider.getExternalStorageDirectory();
      String randomString = getRandString(2);
      filePath = baseStorage.path + 'StarShow$randomString.apk';
      taskId = await FlutterDownloader.enqueue(
        url: redirectURL,
        savedDir: baseStorage.path,
        fileName: 'StarShow$randomString.apk',
        showNotification: true,
        openFileFromNotification: true,
      );
      // SystemNavigator.pop();
    }
    else{
      Fluttertoast.showToast(msg: 'دسترسی به حافظه دستگاه را به اپلیکیشن بدهید.');
    }
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) =>  random.nextInt(255));
    return base64UrlEncode(values);
  }

  @override
  void initState() {
    super.initState();
    flickMultiManager = FlickMultiManager();
    _timer = RestartableTimer(_timerDuration, setTimerState);
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'downloader_send_port');
    receivePort.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState((){
        downloadProgress = progress;
        if(status == DownloadTaskStatus.complete){
          isDownloading = false;
          FlutterDownloader.open(taskId: taskId);
        }
        else if(downloadProgress != 0 && status != DownloadTaskStatus.failed){
          isWaitingToStartDownload = false;
        }
        else if(status == DownloadTaskStatus.failed){
          Fluttertoast.showToast(msg: 'مشکل در برقراری ارتباط. لطفا اتصال اینترنت خود را بررسی کنید');
          isWaitingToStartDownload = false;
          isDownloading = false;
          downloadProgress = 0;
        }
      });
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
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
            if(widget.navigatedPage == NavigatedPage.CoursePreview){
              // Navigator.push(context, MaterialPageRoute(builder: (context) {
              //   return CoursePreview(widget.details);
              // }));
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => CoursePreview(widget.details)),
                  (route) => route.isFirst);
            }
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
              redirectURL.toLowerCase().contains('.apk') ?
                'نصب' : 'نمایش',
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              Container(
                  height: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    child: InkWell(
                      onTap: () async{
                        if(isAPK){
                          if(downloadProgress == 0 &&
                              !isDownloading &&
                              !isWaitingToStartDownload){
                            isWaitingToStartDownload = true;
                            isDownloading = true;
                            await downloadFile();
                          }
                          else if (downloadProgress == 100){
                            await FlutterDownloader.open(taskId: taskId);
                          }
                        }
                        else{
                          try{
                            await launch(redirectURL);
                          }
                          catch(e){
                            print(e.toString());
                          }
                        }
                      },
                      child: FlickMultiPlayer(
                        advertisementURL: tempURL,
                        flickMultiManager: flickMultiManager,
                        image: 'assets/images/appMainIcon.png',
                        redirectURL: redirectURL,
                        isAPK: true,
                      ),
                    ),
                  )
              ),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: (){
                    flickMultiManager?.toggleMute();
                    setState(() {
                      isMuted?
                          isMuted = false :
                          isMuted = true;
                    });
                  },
                  icon: Icon(
                    !isMuted?
                    Icons.volume_off_sharp : Icons.volume_up,
                    color: Colors.white,
                  ),
                )
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 28.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                advertisementContinueButton(),
                videoAdvertisementSkipButton(),
              ],
            ),
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
