import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:provider/provider.dart';
import './multi_manager/flick_multi_manager.dart';

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
                // if(widget.isAPK){
                //   if(downloadProgress == 0 &&
                //       !isDownloading &&
                //       !isWaitingToStartDownload){
                //     isWaitingToStartDownload = true;
                //     isDownloading = true;
                //     await downloadFile();
                //   }
                //   else if (downloadProgress == 100){
                //     await FlutterDownloader.open(taskId: taskId);
                //   }
                // }
                // else{
                //   try{
                //     await launch(widget.redirectUrl);
                //   }
                //   catch(e){
                //     print(e.toString());
                //   }
                // }
              },
              child: FlickSeekVideoAction(
                child: Center(child: FlickVideoBuffer()),
              ),
            ),
          ),
          // FlickAutoHideChild(
          //   autoHide: true,
          //   showIfVideoNotInitialized: false,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: <Widget>[
          //       Container(
          //         padding: EdgeInsets.all(2),
          //         decoration: BoxDecoration(
          //           color: Colors.black38,
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //         child: FlickSoundToggle(
          //           toggleMute: () => widget.flickMultiManager?.toggleMute(),
          //           color: Colors.white,
          //         ),
          //       ),
          //       // FlickFullScreenToggle(),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
