import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/models/episode_audios.dart';
import 'package:mobile/services/course_episode_service.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;

class NowPlaying extends StatefulWidget {
  NowPlaying(this.episodeDetails, this.courseCoverUrl);
  NowPlaying.noPicture(this.episodeDetails, this.noPictureAsset);

  final CourseEpisode episodeDetails;
  String courseCoverUrl;
  String noPictureAsset;

  @override
  _NowPlayingState createState() => _NowPlayingState();
}

CourseStore courseStore;
Future<dynamic> firstDecryptedFileFuture;
dynamic firstDecryptedFilePath;
List<EpisodeAudios> episodeAudios;
const platform = const MethodChannel("audioshoppp.ir.mobile/nowplaying");


Future<dynamic> decryptFileInJava(dynamic encryptedFilePath) async{
  dynamic decryptedFilePath = await platform
      .invokeMethod("decryptFileInJava", {'encryptedFilePath': encryptedFilePath});
  return decryptedFilePath;
}

class _NowPlayingState extends State<NowPlaying> {
  IconData playBtn = Icons.play_arrow;
  CourseEpisodeData courseEpisodeData;
  bool isDrivingMode = false;
  Duration position = new Duration();
  Duration musicLength = new Duration();
  bool isTakingMuchTime = false;
  Duration _timerDuration = new Duration(seconds: 5);
  var pictureFile;
  bool isVpnConnected = false;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  Widget slider() {
    return Container(
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Color(0xFF20BFA9),
            inactiveTrackColor: Color(0xFFd3fff8),
            trackShape: RoundedRectSliderTrackShape(),
            trackHeight: 2.0,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
            thumbColor: Color(0xFF169985),
            overlayColor: Color(0xFFd3fff8).withAlpha(25),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
            tickMarkShape: RoundSliderTickMarkShape(),
            activeTickMarkColor: Color(0xFF169985),
            inactiveTickMarkColor: Color(0xFFd3fff8),
            valueIndicatorShape: PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: Color(0xFF169985),
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          child: Slider(
              value: position.inMilliseconds.toDouble(),
              max: audioManagerInstance.duration.inMilliseconds.toDouble(),
              divisions: 500,
              label: "${position.inMinutes}:${position.inSeconds.remainder(60)}",
              onChanged: (value) {
                seekToSec(value.toInt());
                setState(() {
                  position = Duration(milliseconds: value.toInt());
                });
              }),
        ));
  }

  void seekToSec(int milliSec) {
    Duration newPos = Duration(milliseconds: milliSec);
    audioManagerInstance.seekTo(newPos);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies(){
    courseStore = Provider.of<CourseStore>(context);
    courseEpisodeData = CourseEpisodeData();
    firstDecryptedFileFuture = setAudioFile();
    super.didChangeDependencies();
  }

  Future<dynamic> createAudioManagerList(List<EpisodeAudios> episodeAudios) async{
    courseStore.setPlayingEpisode(widget.episodeDetails.id);
    dynamic firstEncryptedFile = await DefaultCacheManager()
        .getSingleFile(episodeAudios[0].audioAddress);

    dynamic decryptedFilePath = await decryptFileInJava(firstEncryptedFile.path);

    List<AudioInfo> tempList = List<AudioInfo>();
    tempList.add(AudioInfo(
        "file://$decryptedFilePath",
        title: widget.episodeDetails.name,
        desc: widget.episodeDetails.description,
        coverUrl: "assets/images/appMainIcon.png"));

    audioManagerInstance.audioList = tempList;

    await setAudioManager();

    return decryptedFilePath;
  }

  Future<bool> isCurrentEpisodePlaying(int episodeId) async {
    return episodeId == courseStore.playingEpisodeId;
  }

  Future<dynamic> setAudioFile() async{
    pictureFile = widget.courseCoverUrl != '' ?
      await DefaultCacheManager().getSingleFile(widget.courseCoverUrl):
      null;
    RestartableTimer(_timerDuration, setTimerState);
    try{

      if(await isCurrentEpisodePlaying(widget.episodeDetails.id) &&
          audioManagerInstance.audioList != null && audioManagerInstance.audioList.length > 0
      )
      {
        var currentPosition = audioManagerInstance.position.inMilliseconds;
        firstDecryptedFilePath = audioManagerInstance.audioList[audioManagerInstance.curIndex];
        seekToSec(currentPosition);
        setState(() {
          playBtn = Icons.pause;
        });
        await setAudioManager();
      }
      else
      {
        if(audioManagerInstance.audioList != null &&
            audioManagerInstance.audioList.length > 0){
          for(var decryptedFile in audioManagerInstance.audioList){
            var file = File(decryptedFile.url.replaceRange(0, 6, ''));
            if(await file.exists())
              file.delete();
          }
        }
        audioManagerInstance.stop();
        audioManagerInstance.audioList.clear();

        episodeAudios = await courseEpisodeData
            .getEpisodeAudios(widget.episodeDetails.id);

        firstDecryptedFilePath = await createAudioManagerList(episodeAudios);
      }

      return firstDecryptedFilePath;
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  Future downloadAndDecryptFiles(List<EpisodeAudios> episodes) async
  {
    for(int i = 1; i < episodes.length; i++)
    {
      dynamic audioFile = await DefaultCacheManager()
          .getSingleFile(episodes[i].audioAddress);

      dynamic decryptedFilePath = await decryptFileInJava(audioFile.path);

      audioManagerInstance.audioList.add(AudioInfo(
          "file://$decryptedFilePath",
          title: widget.episodeDetails.name,
          desc: widget.episodeDetails.description,
          coverUrl: 'https://star-show.ir/assets/logo.webp'));

    }
  }

  Future setAudioManager() async{

    audioManagerInstance.intercepter = true;
    audioManagerInstance.play(auto: false);

    try{
      audioManagerInstance.onEvents((events, args) {
        switch (events) {
          case AudioManagerEvents.start:
            print(
                "start load data callback, curIndex is ${AudioManager.instance.curIndex}");
            setState(() {
            });
            break;
          case AudioManagerEvents.ready:
            print("ready to play");
            setState(() {
              musicLength = audioManagerInstance.duration;
            });
            // if you need to seek times, must after AudioManagerEvents.ready event invoked
            // AudioManager.instance.seekTo(Duration(seconds: 10));
            break;
          case AudioManagerEvents.seekComplete:
            setState(() {});
            print("seek event is completed. position is [$args]/ms");
            break;
          case AudioManagerEvents.buffering:
            print("buffering $args");
            break;
          case AudioManagerEvents.playstatus:
            setState(() {});
            break;
          case AudioManagerEvents.timeupdate:
            setState(() {
              position = audioManagerInstance.position;
            });
            break;
          case AudioManagerEvents.ended:
            setState(() {
              position = musicLength;
              playBtn = Icons.play_arrow;
            });
            position = new Duration();
            musicLength = new Duration();
            if(audioManagerInstance.curIndex != audioManagerInstance.audioList.length - 1)
            {
              audioManagerInstance.next();
              audioManagerInstance.playOrPause();
              setState(() {
                playBtn = Icons.pause;
              });
            }
            else {
              setState(() {
                position = audioManagerInstance.duration;
                playBtn = Icons.play_arrow;
              });
            }
            break;
          case AudioManagerEvents.volumeChange:
            setState(() {});
            break;
          default:
            break;
        }
      });
    }
    catch(e){
      print(e.toString());
    }
  }

  Widget jumpToThePosition(IconData iconData){
    double iconSize = 25;

    return !isDrivingMode ?
     Expanded(
       child: IconButton(
        iconSize: iconSize,
        color: Colors.white,
        onPressed: () {
          int tempPosition = 0;
          if(iconData == Icons.forward_30){
            iconSize = 30;
            if(audioManagerInstance.duration.inSeconds - position.inSeconds < 30){
              tempPosition = audioManagerInstance.duration.inSeconds;
            }
            else{
              tempPosition = position.inSeconds + 30;
            }
          }
          else if(iconData == Icons.replay_30){
            iconSize = 30;
            if(position.inSeconds < 30){
              tempPosition = 0;
            }
            else{
              tempPosition = position.inSeconds - 30;
            }
          }
          else if(iconData == Icons.replay_10){
            if(position.inSeconds < 10){
              tempPosition = 0;
            }
            else{
              tempPosition = position.inSeconds - 10;
            }
          }
          else {
            if(audioManagerInstance.duration.inSeconds - position.inSeconds < 10){
              tempPosition = audioManagerInstance.duration.inSeconds;
            }
            else{
              tempPosition = position.inSeconds + 10;
            }
          }

          setState(() {
            position = new Duration(seconds: tempPosition);
            seekToSec(position.inMilliseconds);
          });
        },
        icon: Icon(
          iconData,
        ),
    ),
     ) : SizedBox();
  }

  Widget spinner(){
    return Scaffold(
        body: !isTakingMuchTime ? SpinKitWave(
          type: SpinKitWaveType.center,
          color: Color(0xFF20BFA9),
          size: 65.0,
        ) :
        Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitWave(
                  type: SpinKitWaveType.center,
                  color: Color(0xFF20BFA9),
                  size: 65.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'لطفا منتظر بمانید. '
                        'در حال بارگیری فایل دوره',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: Text(//!isVpnConnected ? '' :
                  'جهت تجربه سرعت بهتر،',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: Text(//!isVpnConnected ? '' :
                  'در صورت وصل بودن فیلترشکن، آنرا خاموش کنید',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // InkWell(
                //   onTap: (){
                //     setState(() {
                //       isTakingMuchTime = false;
                //       Navigator.pushReplacement(
                //           context,
                //           MaterialPageRoute(
                //               builder: (BuildContext context) => super.widget));
                //     });
                //   },
                //   child: Card(
                //     color: Color(0xFF20BFA9),
                //     child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Text(
                //         'تلاش مجدد',
                //         style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 18
                //         ),),
                //     ),
                //   ),
                // )
              ]
          ),
        )
    ) ;
  }

  setTimerState() {
    setState(() {
      isTakingMuchTime = true;
    });
    // checkVpnConnection();
  }

  Future checkVpnConnection() async{
    setState(() {
      isVpnConnected = false;
    });
    try {
      http.Response response = await http.get('https://api.ipregistry.co?key=tryout');
      if(response.statusCode == 200 &&
          json.decode(response.body)['location']['country']['name']
              .toString().toLowerCase() != 'iran'){
        setState(() {
          isVpnConnected = true;
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // courseStore = Provider.of<CourseStore>(context);
    CourseEpisode episode = widget.episodeDetails;
    String courseCover = widget.courseCoverUrl;

    return FutureBuilder(
      future: firstDecryptedFileFuture,
      builder: (context, data){
        if(data.hasData){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF202028),
              title: Text(
                episode.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                ),
              ),
              actions: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                    ),
                    Switch(
                      inactiveTrackColor: Colors.white30,
                      value: isDrivingMode,
                      // child: Text(
                      //   'حالت رانندگی',
                      //   style: TextStyle(
                      //       color: isDrivingMode ? Colors.white : Color(0xFF20BFA9)
                      //   ),
                      // ),
                      onChanged: (value){
                        setState(() {
                          isDrivingMode = value;
                          // isDrivingMode ?
                          //   isDrivingMode = false : isDrivingMode = true;
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
            body: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF20BFA9),
                        Colors.deepOrange[600],
                      ]),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: pictureFile != null ?
                        NetworkImage(courseCover) :
                        AssetImage(widget.noPictureAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 17.0, sigmaY: 16.0),
                      child: Container(
                        color: Colors.black12.withOpacity(0.3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  height: MediaQuery.of(context).size.width * 0.8,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: pictureFile != null ?
                                        NetworkImage(courseCover) :
                                        AssetImage(widget.noPictureAsset),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Directionality(
                                  textDirection: ui.TextDirection.rtl,
                                  child: Text(
                                    episode.name + ' - فایل ' +
                                        (audioManagerInstance.curIndex + 1)
                                            .toString() + ' از ' +
                                        (audioManagerInstance
                                          .audioList.length).toString()
                                    ,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 23.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Expanded(
                            //   flex: 1,
                            //   child: Center(
                            //     child: Text(
                            //       "بیطرف",
                            //       style: TextStyle(
                            //         color: Colors.white,
                            //         fontSize: 23.0,
                            //         fontWeight: FontWeight.w600,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding:
                                              const EdgeInsets.only(left: 14.0),
                                              child: Text(
                                                "${position.inMinutes}:${position.inSeconds.remainder(60)}",
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.only(right: 14.0),
                                              child: Text(
                                                "${audioManagerInstance.duration.inMinutes}:${audioManagerInstance.duration.inSeconds.remainder(60)}",
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        )),
                                    Expanded(
                                      flex: 1,
                                      child: slider(),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: IconButton(
                                              iconSize: !isDrivingMode ? 25 : 45,
                                              color: Colors.white,
                                              onPressed: () {
                                                position = new Duration();
                                                musicLength = new Duration();
                                                if(audioManagerInstance.curIndex != 0)
                                                {
                                                  audioManagerInstance.previous();
                                                  audioManagerInstance.playOrPause();
                                                  setState(() {
                                                    playBtn = Icons.pause;
                                                  });
                                                }
                                                else {
                                                  Fluttertoast.showToast(msg: 'اولین فایل');
                                                }
                                              },
                                              icon: Icon(
                                                Icons.skip_previous,
                                              ),
                                            ),
                                          ),
                                          jumpToThePosition(Icons.replay_10),
                                          jumpToThePosition(Icons.replay_30),
                                          Expanded(
                                            child: InkWell(
                                              // iconSize: isDrivingMode ? 65 : 35,
                                              // color: Colors.white,
                                              onTap: () async {
                                                if (!audioManagerInstance.isPlaying) {
                                                  setState(() {
                                                    playBtn = Icons.pause;
                                                  });

                                                  if(episodeAudios.length > audioManagerInstance.audioList.length)
                                                    downloadAndDecryptFiles(episodeAudios);

                                                  await AudioManager.instance.play(index: audioManagerInstance.curIndex);
                                                } else {
                                                  // _player.pause();
                                                  await AudioManager.instance.playOrPause();
                                                  setState(() {
                                                    playBtn = Icons.play_arrow;
                                                  });
                                                }
                                              },
                                              child: Icon(
                                                playBtn,
                                                size: isDrivingMode ? 65 : 45,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          jumpToThePosition(Icons.forward_30),
                                          jumpToThePosition(Icons.forward_10),
                                          Expanded(
                                            child: IconButton(
                                              iconSize: !isDrivingMode ? 25 : 45,
                                              color: Colors.white,
                                              onPressed: () {
                                                position = new Duration();
                                                musicLength = new Duration();
                                                if(audioManagerInstance.curIndex !=
                                                    audioManagerInstance.audioList.length - 1)
                                                {
                                                  audioManagerInstance.next();
                                                  audioManagerInstance.playOrPause();
                                                  setState(() {
                                                    playBtn = Icons.pause;
                                                  });
                                                }
                                                else {
                                                  Fluttertoast.showToast(msg: 'آخرین فایل');
                                                }
                                              },
                                              icon: Icon(
                                                Icons.skip_next,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(flex: 2, child: SizedBox())
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ),
          );
        }
        else{
          return spinner();
        }
      }
    );
  }
}
