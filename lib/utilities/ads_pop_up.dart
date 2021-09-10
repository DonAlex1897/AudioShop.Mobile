import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/models/ads.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/screens/add_salesperson_coupon_code.dart';
import 'package:mobile/screens/authentication_page.dart';
import 'package:mobile/screens/course_page.dart';
import 'package:mobile/screens/course_preview.dart';
import 'package:mobile/screens/now_playing.dart';
import 'package:mobile/screens/psychological_tests_page.dart';
import 'package:mobile/screens/support_page.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/utilities/multi_manager/flick_multi_manager.dart';
import 'package:mobile/utilities/multi_manager/flick_multi_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

class AdsPopUp extends StatefulWidget {
  final NavigatedPage navigatedPage;
  final Ads ads;
  final Course course;
  final courseCover;
  final String noPictureAsset;
  final String courseCoverUrl;
  final CourseEpisode episodeDetails;
  final int videoAdsWaitingTime;

  AdsPopUp({
    Key key,
    @required this.navigatedPage,
    @required this.ads,
    this.course,
    this. courseCover,
    this.noPictureAsset,
    this.courseCoverUrl,
    this.episodeDetails,
    this.videoAdsWaitingTime
  }): super (key: key);

  @override
  _AdsPopUpState createState() => _AdsPopUpState();
}

class _AdsPopUpState extends State<AdsPopUp> {

  FlickMultiManager flickMultiManager;
  String adURL;// = 'https://filesamples.com/samples/video/mov/sample_640x360.mov'; //'https://file-examples-com.github.io/uploads/2018/04/file_example_MOV_480_700kB.mov'; //'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4';
  String redirectURL;// = 'https://www.dl.farsroid.com/ap/HiPER-Calc-Pro-8.3.8(www.farsroid.com).apk';
  String adsDescription;
  String adsTitle;
  bool isTimerActive = true;
  bool isMuted = false;
  int downloadProgress = 0;
  String taskId = '';
  String filePath = '';
  String downloadButtonText = 'دانلود';
  DownloadTaskStatus downloadTaskStatus;
  bool isDownloading = false;
  bool isWaitingToStartDownload = false;
  ReceivePort receivePort = ReceivePort();
  Timer _timer;
  int _timerDuration = 2;

  void startTimer() {
    _timerDuration = widget.videoAdsWaitingTime;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_timerDuration == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _timerDuration--;
          });
        }
      },
    );
  }
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
    adURL = widget.ads.fileAddress;
    redirectURL = widget.ads.link;
    adsDescription = widget.ads.description;
    adsTitle = widget.ads.title;
    flickMultiManager = FlickMultiManager();
    //_timer = RestartableTimer(_timerDuration, setTimerState);
    startTimer();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'downloader_send_port');
    receivePort.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState((){
        downloadProgress = progress;
        if(status == DownloadTaskStatus.complete){
          downloadButtonText = 'نصب';
          isDownloading = false;
        }
        else if(downloadProgress != 0 && status != DownloadTaskStatus.failed){
          isWaitingToStartDownload = false;
          downloadButtonText = '$downloadProgress %';
        }
        else if(status == DownloadTaskStatus.failed){
          Fluttertoast.showToast(msg: 'مشکل در برقراری ارتباط. لطفا اتصال اینترنت خود را بررسی کنید');
          isWaitingToStartDownload = false;
          downloadButtonText = 'تلاش مجدد';
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
    _timer.cancel();
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
            child: Text(_timerDuration == 0 ?
            'بستن' : _timerDuration.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          onTap:() async {
            navigateToDestination();
          },
        ),
      ),
    );
  }

  void navigateToDestination(){
    if(_timerDuration == 0){
      Navigator.pop(context);
      if(widget.navigatedPage == NavigatedPage.CoursePreview){
        print('here1');
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CoursePreview(widget.course);
        }));
      }
      else if(widget.navigatedPage == NavigatedPage.CoursePage){
        print('here2');
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CoursePage(widget.course, widget.courseCover);
        }));
      }
      else if(widget.navigatedPage == NavigatedPage.SignInLibrary){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return AuthenticationPage(FormName.SignIn);
            })
        );
      }
      else if (widget.navigatedPage == NavigatedPage.SignUpLibrary ||
          widget.navigatedPage == NavigatedPage.SignUpPurchase){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return AuthenticationPage(FormName.SignUp);
            })
        );
      }
      else if (widget.navigatedPage == NavigatedPage.RegisterPhoneNumber){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return AuthenticationPage(FormName.RegisterPhoneNumber);
            })
        );
      }
      else if (widget.navigatedPage == NavigatedPage.PlayEpisode){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return NowPlaying(widget.episodeDetails, widget.courseCoverUrl);
            })
        );
      }
      else if (widget.navigatedPage == NavigatedPage.AddSalesPersonCouponCode){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return AddSalesPersonCouponCode();
            })
        );
      }
      else if (widget.navigatedPage == NavigatedPage.SupportPage){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return SupportPage();
            })
        );
      }
      else if (widget.navigatedPage == NavigatedPage.PsychologicalTests){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return PsychologicalTestsPage();
            })
        );
      }
    }
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
            child: Text(_timerDuration == 0 ?
            'بستن' : _timerDuration.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          onTap:() async {
            navigateToDestination();
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
            child:
            redirectURL.toLowerCase().contains('.apk') ?
            (!isWaitingToStartDownload ?
            Text(
              downloadButtonText,
              style: TextStyle(color: Colors.white),
            ) :
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SpinKitRing(
                  lineWidth: 3,
                  color: Colors.white
              ),
            )
            ) :
            Text(
              'نمایش',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap:() async {
            if(redirectURL.toLowerCase().contains('.apk')){
              if(downloadProgress == 0 && !isDownloading){
                setState(() {
                  isWaitingToStartDownload = true;
                });
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
        ),
      ),
    );
  }

  Widget advertisement(){
    if(adURL.toLowerCase().contains('.mov') ||
        adURL.toLowerCase().contains('.mp4')){
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                InkWell(
                  onTap: () async {
                    if(redirectURL.toLowerCase().contains('.apk')){
                      if(downloadProgress == 0 && !isDownloading){
                        setState(() {
                          isWaitingToStartDownload = true;
                        });
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
                  child: IgnorePointer(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: FlickMultiPlayer(
                          advertisementURL: adURL,
                          flickMultiManager: flickMultiManager,
                          image: 'assets/images/appMainIcon.png',
                          redirectURL: redirectURL,
                          isAPK: redirectURL.toLowerCase().contains('.apk'),
                        )
                    ),
                  ),
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
                        isMuted?
                        Icons.volume_off_sharp : Icons.volume_up,
                        color: Colors.white,
                      ),
                    )
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15,left: 50, right: 50),
              child: Text(
                adsTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15,left: 50, right: 50, bottom: 10),
              child: Text(
                adsDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  advertisementContinueButton(),
                  videoAdvertisementSkipButton(),
                ],
              ),
            )
          ],
        ),
      );
    }
    else{
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                    child: Image.network(adURL, fit: BoxFit.cover,)
                )
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15,left: 50, right: 50),
              child: Text(
                adsTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(adsDescription),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  advertisementContinueButton(),
                  imageAdvertisementSkipButton(),
                ],
              ),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(flickMultiManager),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && this.mounted) {
          flickMultiManager.pause();
        }
      },
      child: advertisement(),
    );
  }
}
