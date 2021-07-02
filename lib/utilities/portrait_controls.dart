import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import './multi_manager/flick_multi_manager.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

class FeedPlayerPortraitControls extends StatefulWidget {
  const FeedPlayerPortraitControls(
      {Key key, this.flickMultiManager, this.flickManager, this.redirectUrl, this.isAPK})
      : super(key: key);

  final FlickMultiManager flickMultiManager;
  final FlickManager flickManager;
  final String redirectUrl;
  final bool isAPK;

  @override
  _FeedPlayerPortraitControls createState() => _FeedPlayerPortraitControls();
}

class _FeedPlayerPortraitControls extends State<FeedPlayerPortraitControls> {

  int downloadProgress = 0;
  String taskId = '';
  String filePath = '';
  String downloadButtonText = 'به روز رسانی';
  DownloadTaskStatus downloadTaskStatus;
  bool isDownloading = false;
  bool isWaitingToStartDownload = false;
  ReceivePort receivePort = ReceivePort();

  Future downloadFile() async{
    final permissionStatus = await Permission.storage.request();
    if(permissionStatus.isGranted){
      final baseStorage = await pathProvider.getExternalStorageDirectory();
      String randomString = getRandString(2);
      filePath = baseStorage.path + 'StarShow$randomString.apk';
      taskId = await FlutterDownloader.enqueue(
        url: widget.redirectUrl,
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
          isDownloading = false;
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

  @override
  Widget build(BuildContext context) {
    FlickDisplayManager displayManager =
        Provider.of<FlickDisplayManager>(context);
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FlickAutoHideChild(
            showIfVideoNotInitialized: false,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FlickLeftDuration(),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: ()async{
                if(widget.isAPK){
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
                try{
                  await launch(widget.redirectUrl);
                }
                catch(e){
                  print(e.toString());
                }
              },
              child: FlickSeekVideoAction(
                child: Center(child: FlickVideoBuffer()),
              ),
            ),
          ),
          FlickAutoHideChild(
            autoHide: true,
            showIfVideoNotInitialized: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FlickSoundToggle(
                    toggleMute: () => widget.flickMultiManager?.toggleMute(),
                    color: Colors.white,
                  ),
                ),
                // FlickFullScreenToggle(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
