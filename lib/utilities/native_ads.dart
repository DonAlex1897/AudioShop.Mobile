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
import 'package:mobile/shared/enums.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

import 'ads_align.dart';


class NativeAds extends StatefulWidget {

  NativeAds(
      //this.details,
      this.location);
  //final details;
  final location;

  @override
  _NativeAds createState() => _NativeAds();
}

class _NativeAds extends State<NativeAds> {
  var location = NativeAdsLocation.HomePage;
  String adURL = 'https://filesamples.com/samples/video/mov/sample_640x360.mov'; //'https://file-examples-com.github.io/uploads/2018/04/file_example_MOV_480_700kB.mov'; //'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4';
  String tempURL = 'https://www.kolpaper.com/wp-content/uploads/2021/02/Juve-Stadium-Wallpaper.jpg';
  String redirectURL = 'https://www.kolpaper.com/wp-content/uploads/2021/02/Juve-Stadium-Wallpaper.jpg';//'https://www.dl.farsroid.com/ap/HiPER-Calc-Pro-8.3.8(www.farsroid.com).apk';
  int downloadProgress = 0;
  String taskId = '';
  String filePath = '';
  String downloadButtonText = 'دانلود';
  DownloadTaskStatus downloadTaskStatus;
  bool isDownloading = false;
  bool isWaitingToStartDownload = false;
  ReceivePort receivePort = ReceivePort();
  bool justPicture = false;
  double width = 0;

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
    location = widget.location;
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


  Widget advertisementContinueButton(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: width / 2,
        height: 40,
        decoration: BoxDecoration(
          //border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(20),
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

  Widget nativeAds(){
      return
        !justPicture ?
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              Container(
                color: Colors.black26,
                //height: 80,
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 50, right: 50),
                      child: Text(
                        'Tic Tac Toe Universe – دنیای دوز (ایکس او) نام یک بازی ساده، کم حجم '
                            'و در عین حال بسیار سرگرم کننده',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14
                        ),
                      ),
                    ),
                    (adURL.toLowerCase().contains('.mov') ||
                        adURL.toLowerCase().contains('.mp4')) ?
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
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
                        child: Container(
                            height: width / 2,
                            width: width,
                            child: Image.network(tempURL, fit: BoxFit.cover,)
                        ),
                      ),
                    ) :
                    Container(
                        height: width / 2,
                        width: width,
                        child: Image.network(tempURL, fit: BoxFit.cover,)
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          advertisementContinueButton(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              AdsAlign(),
            ]
          ),
        ) :
        Stack(
          children: [
            Container(
                height: 60,
                width: width,
                child: Image.network(tempURL, fit: BoxFit.cover,)
            ),
            AdsAlign(),
          ]
        );
    }


  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return nativeAds();
  }
}
