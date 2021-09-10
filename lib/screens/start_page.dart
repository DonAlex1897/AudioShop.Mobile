import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/screens/home_page.dart';
import 'package:mobile/screens/intro_page.dart';
import 'package:mobile/screens/update_page.dart';
import 'package:mobile/services/global_service.dart';
import 'package:mobile/services/message_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/store/course_store.dart';
import 'package:mobile/utilities/Utility.dart';
import 'package:mobile/utilities/native_ads.dart';
import 'package:package_info/package_info.dart';
import 'package:async/async.dart';
import 'package:provider/provider.dart';
import 'package:mobile/models/message.dart' as message;

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  CourseStore courseStore;
  String isFirstTime;
  PackageInfo info;
  String currentVersion;
  GlobalService globalService = GlobalService();
  String availableVersion;
  Duration _timerDuration = new Duration(seconds: 5);
  bool isTakingMuchTime = false;
  bool shouldRetry = false;

  navigateToNextPage() {
    UpdateStatus updateStatus = getUpdateStatus();
    if (availableVersion != null && updateStatus != UpdateStatus.UpToDate) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return UpdatePage(availableVersion, updateStatus, currentVersion);
      }));
      return;
    } else if (isFirstTime == null || isFirstTime.toLowerCase() == 'true') {
      // return IntroPage();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return IntroPage(currentVersion);
      }));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HomePage(currentVersion);
    }));
  }

  UpdateStatus getUpdateStatus() {
    List<String> currentVersionParts = currentVersion.split('.');
    List<String> availableVersionParts = availableVersion.split('.');
    int currentVersionMajorPart = int.parse(currentVersionParts[0]);
    int currentVersionMinorPart = int.parse(currentVersionParts[1]);
    int currentVersionPatchPart = int.parse(currentVersionParts[2]);
    int availableVersionMajorPart = int.parse(availableVersionParts[0]);
    int availableVersionMinorPart = int.parse(availableVersionParts[1]);
    int availableVersionPatchPart = int.parse(availableVersionParts[2]);

    if (availableVersionMajorPart > currentVersionMajorPart)
      return UpdateStatus.UpdateRequired;
    else if ((availableVersionMajorPart == currentVersionMajorPart &&
            availableVersionMinorPart > currentVersionMinorPart) ||
        (availableVersionMajorPart == currentVersionMajorPart &&
            availableVersionMinorPart == currentVersionMinorPart &&
            availableVersionPatchPart > currentVersionPatchPart))
      return UpdateStatus.UpdateAvailable;
    else
      return UpdateStatus.UpToDate;
  }

  @override
  void initState() {
    startApplication();
    initPlatformState();
    super.initState();
  }

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 60,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      // <-- Event handler
      MessageService messageService = MessageService();
      FlutterSecureStorage secureStorage = FlutterSecureStorage();
      String token = await secureStorage.read(key: 'token');
      if (token != null || token != "") {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userId = decodedToken['nameid'];
        List<message.Message> messages =
            await messageService.getPersonalMessages(userId);
        List<message.Message> newMessages = messages
            .where((element) => element.sendPush && !element.pushSent)
            .toList();

        List<int> messageIds = [];
        int newMessageCount = newMessages != null ? newMessages.length : 0;
        if (newMessageCount > 0) {
          for (var userMessage in newMessages) {
            int id = userMessage.id;
            messageIds.add(id);
            String title = userMessage.title;
            String body = userMessage.body;
            showNotification(id, body, title);
          }
          await messageService.setMessageAsSeen(userId, messageIds, []);
        }
      }
      print("[BackgroundFetch] Event received $taskId");
      // setState(() {
      //   _events.insert(0, new DateTime.now());
      // });
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
    print('[BackgroundFetch] configure success: $status');
    // setState(() {
    //   _status = status;
    // });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void showNotification(int id, String body, String title) async {
    FlutterLocalNotificationsPlugin localNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var android = AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
    await localNotificationsPlugin.show(id, title, body, platform);
  }

  Future startApplication() async {
    const platform = const MethodChannel("audioshoppp.ir.mobile/main");
    await platform.invokeMethod('launchBatch');
    var secureStorage = FlutterSecureStorage();
    isFirstTime = await secureStorage.read(key: 'isFirstTime');
    info = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = info.version;
    });
    RestartableTimer(_timerDuration, setTimerState);
    availableVersion = await globalService.getLatestVersionAvailable();
    courseStore.setAdsSituation();
    if (availableVersion != null)
      navigateToNextPage();
    else
      setState(() {
        shouldRetry = true;
      });
  }

  setTimerState() {
    setState(() {
      isTakingMuchTime = true;
    });
    // checkVpnConnection();
  }

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    courseStore.isAdsEnabled &&
                            courseStore.loadingUpNative &&
                            courseStore.loadingUpNativeAds != null &&
                            courseStore.loadingUpNativeAds.isEnabled
                        ? NativeAds(courseStore.loadingUpNativeAds)
                        : SizedBox(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Image.asset(
                            'assets/images/appMainIcon.png',
                            width: MediaQuery.of(context).size.width * 0.2,
                          ),
                        ),
                        Text(
                          'اِستارشو، اپلیکیشن مهارتهای ارتباطی',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'با اِستارشو، ستاره شو',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(
                          child: !isTakingMuchTime
                              ? Text('')
                              : !shouldRetry
                                  ? SpinKitWave(
                                      type: SpinKitWaveType.center,
                                      color: Color(0xFF20BFA9),
                                      size: 20.0,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isTakingMuchTime = false;
                                            shouldRetry = false;
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        super.widget));
                                          });
                                        },
                                        child: Card(
                                          color: Color(0xFF20BFA9),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              'تلاش مجدد',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                        ),
                      ],
                    ),
                    courseStore.isAdsEnabled &&
                            courseStore.loadingDownNative &&
                            courseStore.loadingDownNativeAds != null &&
                            courseStore.loadingDownNativeAds.isEnabled
                        ? NativeAds(courseStore.loadingDownNativeAds)
                        : SizedBox(),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: currentVersion != null
                    ? Text(
                        'نسخه ' + currentVersion,
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      )
                    : Text(
                        '...',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
