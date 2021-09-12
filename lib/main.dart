import 'dart:math';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/models/message.dart' as message;
import 'package:mobile/screens/start_page.dart';
import 'package:mobile/services/message_service.dart';
import 'package:mobile/store/course_store.dart';
import 'package:mobile/utilities/Utility.dart';
import 'package:provider/provider.dart';
// import 'package:workmanager/workmanager.dart';

FlutterSecureStorage secureStorage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  // await Workmanager().initialize(callbackDispatcher);
  // await Workmanager().registerPeriodicTask("messageBoxWorker", "messageBoxTask",
  //   existingWorkPolicy: ExistingWorkPolicy.replace,
  //   frequency: Duration(minutes: 60),
  // );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xFF202028),
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (context) => CourseStore(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('fa', ''),
        ],
        theme: ThemeData(
          fontFamily: 'IranSans',
          primaryColor: Color(0xFF202028),
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Color(0xFF34333A),
          accentColor: Color(0xFF20BFA9),
          //cardColor: Color(0xFF403F44),
          textTheme: TextTheme(
            bodyText2: TextStyle(color: Colors.white),
            bodyText1: TextStyle(color: Colors.white),
          ),
        ),
        home: StartPage(), //HomePage.basic(),
      ),
    ),
  );

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  // var rng = new Random();
  // int randomNumber = rng.nextInt(100) + 121;
  // showNotification(randomNumber, 'نوتیفیکیشن تست بک گراند', 'بک گراند');
  MessageService messageService = MessageService();
  secureStorage = FlutterSecureStorage();
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
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  // Do your work here...
  BackgroundFetch.finish(taskId);
}
// void callbackDispatcher(){
//   Workmanager().executeTask((task, inputData) async {
//     MessageService messageService = MessageService();
//     Utility.popularMessages = await messageService.getPopularMessages();
//     secureStorage = FlutterSecureStorage();
//     String token  = await secureStorage.read(key: 'token');
//     if(token != null || token != ""){
//       Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
//       String userId = decodedToken['nameid'];
//       List<message.Message> messages = await messageService.getPersonalMessages(userId);
//       List<message.Message> newMessages = messages.where((element) => !element.isSeen).toList();
//
//       int newMessageCount = newMessages != null ? newMessages.length : 0;
//       if(newMessageCount > 0){
//         for(var userMessage in newMessages){
//           int id = userMessage.id;
//           String title = userMessage.title;
//           String body = userMessage.body;
//           showNotification(id, body, title);
//         }
//       }
//     }
//     return Future.value(true);
//   });
// }

void showNotification(int id, String body, String title) async {
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var android = AndroidNotificationDetails(
      'channelId', 'channelName', 'channelDescription');
  var iOS = IOSNotificationDetails();
  var platform = NotificationDetails(android: android, iOS: iOS);
  await localNotificationsPlugin.show(id, title, body, platform);
}
