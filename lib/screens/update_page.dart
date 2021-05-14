import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  bool isWaitingToStartDownload = false;
  ReceivePort receivePort = ReceivePort();

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
    super.initState();
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
    super.dispose();
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
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
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0xFF20BFA9),
                  ),
                  height: 55,
                  child: Padding(
                    padding: const EdgeInsets.only(left:15, right: 15),
                    child: TextButton(
                      onPressed: () async {
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
                      },
                      child: !isWaitingToStartDownload ?
                        Text(
                          downloadButtonText,
                          style: TextStyle(color: Colors.white),
                        ) :
                        SpinKitRing(
                            lineWidth: 5,
                            color: Colors.white
                        ),
                    ),
                  ),
                ),
                widget.updateStatus == UpdateStatus.UpdateAvailable ?
                  Padding(
                    padding: const EdgeInsets.only(right:8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white
                      ),
                      height: 55,
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
