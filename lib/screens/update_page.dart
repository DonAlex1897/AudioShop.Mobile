import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/screens/home_page.dart';
import 'package:mobile/services/global_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatefulWidget {
  UpdatePage(this.lastAvailableVersion, this.updateStatus, this.currentVersion);
  final String lastAvailableVersion;
  final UpdateStatus updateStatus;
  final String currentVersion;

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  int downloadProgress = 0;
  String taskId = '';
  String filePath = '';
  String downloadButtonText = 'به روز رسانی';
  DownloadTaskStatus downloadTaskStatus;
  bool isDownloading = false;

  Future downloadFile() async{
    GlobalService globalService = GlobalService();
    String downloadUrl = await globalService.getDownloadUrl();
    final permissionStatus = await Permission.storage.request();
    if(permissionStatus.isGranted){
      final baseStorage = await pathProvider.getExternalStorageDirectory();
      String randomString = getRandString(2);
      filePath = baseStorage.path + 'StarShow$randomString.apk';
      taskId = await FlutterDownloader.enqueue(
          url: downloadUrl,
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
    ReceivePort receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'downloadingFile');
    receivePort.listen((dynamic data) {
      // String id = data[0];
      // DownloadTaskStatus status = data[1];
      int progress = data;
      setState(() {
        // taskId = id;
        // downloadTaskStatus = status;
        downloadProgress = progress;
        if(downloadProgress == 100)
          downloadButtonText = 'نصب';
        else if(downloadProgress != 0)
          downloadButtonText = '$downloadProgress %';
      });
    });
    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloadingFile');
    super.dispose();
  }

  static downloadCallback(id, status, progress){
    SendPort sendPort = IsolateNameServer.lookupPortByName('downloadingFile');
    sendPort.send(progress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 75),
              child: Image.asset('assets/images/update.png'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30,horizontal: 65),
              child: Text(
                ' لطفا جهت عملکرد بهتر نرم افزار، آخرین آپدیت را نصب '
                  'کنید.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  color: Color(0xFF20BFA9),
                  child: Padding(
                    padding: const EdgeInsets.only(left:15, right: 15),
                    child: TextButton(
                      onPressed: () async {
                        if(downloadProgress == 0 && !isDownloading){
                          // setState(() {
                          //   downloadButtonText = 'در حال به روز رسانی';
                          //   downloadProgress++;
                          // });
                          isDownloading = true;
                          await downloadFile();
                          isDownloading = false;
                        }
                        else if (downloadProgress == 100){
                          await FlutterDownloader.open(taskId: taskId);
                          // final _result = await OpenFile.open(filePath);
                          // print(_result.message);
                          // IsolateNameServer.removePortNameMapping('downloadingFile');
                        }
                        // if (await canLaunch(downloadUrl)){
                        // GlobalService globalService = GlobalService();
                        // var downloadUrl = await globalService.getDownloadUrl();
                        //   try{
                        //     await launch(downloadUrl);
                        //   }
                        //   catch(e){
                        //     Fluttertoast.showToast(msg: 'مشکل در دانلود فایل.'
                        //         'لطفا اتصال اینترنت خود را بررسی کنید');
                        //     print(e.toString());
                        //   }
                        //   finally{
                        //     SystemNavigator.pop();
                        //   }
                        // }
                        // else
                        //   Fluttertoast.showToast(msg: 'مشکل در دانلود فایل.'
                        //       'لطفا اتصال اینترنت خود را بررسی کنید');
                      },
                      child: Text(
                        downloadButtonText,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                widget.updateStatus == UpdateStatus.UpdateAvailable ?
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left:15, right: 15),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context){
                                return HomePage(widget.currentVersion);
                              })
                          );
                        },
                        child: Text(
                          'بعدا',
                          style: TextStyle(color: Color(0xFF20BFA9)),
                        ),
                      ),
                    ),
                  ) :
                  SizedBox(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
