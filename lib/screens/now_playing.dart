import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/models/episode_audios.dart';
import 'package:mobile/services/course_episode_service.dart';
import 'package:mobile/store/course_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class NowPlaying extends StatefulWidget {
  NowPlaying(this.episodeDetails, this.courseCoverUrl);
  final CourseEpisode episodeDetails;
  final String courseCoverUrl;

  @override
  _NowPlayingState createState() => _NowPlayingState();
}

List<AudioInfo> decryptedAudioFiles = [];
List<dynamic> encryptedAudioFiles = List<dynamic>();
List<dynamic> decryptedAudioPaths = List<dynamic>();
CourseStore courseStore;
Future<dynamic> firstDecryptedFileFuture;
Future<List<AudioInfo>> audioFilesList;
dynamic firstDecryptedFilePath;
int countOfFiles = 0;
int currentPlayingFileIndex = 0;
String appCacheDirectory;
List<EpisodeAudios> episodeAudios;
// AudioPlayer _player;
const platform = const MethodChannel("audioshoppp.ir.mobile/nowplaying");

FutureOr<List<dynamic>> decryptAllFiles(List<dynamic> encryptedAudios) async{
  List<dynamic> result = List<dynamic>();
  // for(int i = 0; i < encryptedAudios.length; i++)
  // {
  //   countOfFiles++;
  //   dynamic tempDecryptedAudioPath = await crypt
  //       .decryptFileSync(encryptedAudios[i].path);
  //   decryptedAudioPaths.add(tempDecryptedAudioPath);
  // }
  // result.add(countOfFiles);
  // result.add(decryptedAudioPaths);
  return result;
}

Future<dynamic> decryptFileInJava(dynamic encryptedFilePath) async{
  dynamic decryptedFilePath = await platform
      .invokeMethod("decryptFileInJava", {'encryptedFilePath': encryptedFilePath});
  return decryptedFilePath;
}

class _NowPlayingState extends State<NowPlaying> {
  IconData playBtn = Icons.play_arrow;
  CourseEpisodeData courseEpisodeData;

  Duration position = new Duration();
  Duration musicLength = new Duration();


  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  Widget slider() {
    return Container(
        child: Slider(
            activeColor: Color(0xFF20BFA9),
            inactiveColor: Colors.grey[350],
            value: position.inMilliseconds.toDouble(),
            max: audioManagerInstance.duration.inMilliseconds.toDouble(),
            onChanged: (value) {
              seekToSec(value.toInt());
              setState(() {
                position = Duration(milliseconds: value.toInt());
              });
            }));
  }

  //let's create the seek function that will allow us to go to a certain position of the music
  void seekToSec(int milliSec) {
    Duration newPos = Duration(milliseconds: milliSec);
    // _player.seek(newPos);
    audioManagerInstance.seekTo(newPos);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    courseEpisodeData = CourseEpisodeData();
    firstDecryptedFileFuture = setAudioFile();
    //audioFilesList = downloadAndDecryptFiles(episodeAudios);
  }

  Future<dynamic> createAudioManagerList(List<EpisodeAudios> episodeAudios) async{
    dynamic firstEncryptedFile = await DefaultCacheManager()
        .getSingleFile(episodeAudios[0].audioAddress);

    dynamic decryptedFilePath = await decryptFileInJava(firstEncryptedFile.path);

    String coverUrl = (await DefaultCacheManager().getSingleFile(widget.courseCoverUrl)).path;
    List<AudioInfo> tempList = List<AudioInfo>();
    tempList.add(AudioInfo(
        "file://$decryptedFilePath",
        title: widget.episodeDetails.name,
        desc: widget.episodeDetails.description,
        coverUrl: "assets/images/dummy.jpg"));

    audioManagerInstance.audioList = tempList;

    await setAudioManager();

    return decryptedFilePath;
  }

  Future<bool> isCurrentEpisodePlaying(int episodeId) async {
    return episodeId == courseStore.playingEpisodeId;
  }

  Future<dynamic> setAudioFile() async{

    if(courseStore != null &&
       courseStore.encryptedPlayingFiles != null &&
       await isCurrentEpisodePlaying(widget.episodeDetails.id) &&
       audioManagerInstance.audioList != null
        // && audioManagerInstance.isPlaying TODO check if this condition is necessary
    )
    {
        var currentPosition = audioManagerInstance.position.inMilliseconds;
        firstDecryptedFilePath = audioManagerInstance.audioList[audioManagerInstance.curIndex];
        seekToSec(currentPosition);
        setState(() {
          playBtn = Icons.pause;
          position = Duration(milliseconds: currentPosition);
        });
    }
    else{
      audioManagerInstance.audioList.clear();

      episodeAudios = await courseEpisodeData
          .getEpisodeAudios(widget.episodeDetails.id);

      firstDecryptedFilePath = await createAudioManagerList(episodeAudios);

      if(courseStore != null){
        for(var decryptedFile in courseStore.decryptedPlayingFiles){
          var file = File(decryptedFile);
          if(await file.exists())
            file.delete();
        }
      }
    }

    return firstDecryptedFilePath;
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
          coverUrl: "assets/images/dummy.jpg"));

    }
  }


  // void setAudioPlayerEvents()
  // {
  //   _player.onDurationChanged.listen((d) {
  //     setState(() {
  //       musicLength = d;
  //     });
  //   });
  //
  //   _player.onAudioPositionChanged.listen((p) {
  //     setState(() {
  //       if(p < musicLength)
  //         position = p;
  //       else
  //         position = musicLength;
  //     });
  //   }) ;
  //
  //   _player.onPlayerCompletion.listen((event) {
  //     setState(() {
  //       position = musicLength;
  //       playBtn = Icons.play_arrow;
  //     });
  //     if(courseStore.currentPlayingFileIndex < courseStore.countOfFilesPlaying - 1){
  //       courseStore.incrementPlayingFileIndex(1);
  //       position = new Duration();
  //       musicLength = new Duration();
  //       playNextTrack();
  //     }
  //     else{
  //       courseStore.incrementPlayingFileIndex(0);
  //     }
  //   });
  //
  //   _player.onPlayerStateChanged.listen((AudioPlayerState s) {
  //     playerState = s;
  //     setState(() {
  //       if(playerState == AudioPlayerState.COMPLETED){
  //         // courseStore.playingFile(null, null);
  //         playBtn = Icons.play_arrow;
  //       }
  //       else if(playerState == AudioPlayerState.PLAYING){
  //         playBtn = Icons.pause;
  //       }
  //       else{
  //         playBtn = Icons.play_arrow;
  //       }
  //     });
  //   });
  // }

  void setAudioList(List<dynamic> decryptedFilesPaths){
    decryptedFilesPaths.forEach((item) => audioManagerInstance.audioList.add(AudioInfo("file://$item",
        title: widget.episodeDetails.name, desc: widget.episodeDetails.description, coverUrl: widget.courseCoverUrl)));

    audioManagerInstance.audioList = decryptedAudioFiles;
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
          // audioManagerInstance.updateLrc(args["position"].toString());
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
            audioManagerInstance.next();
            setState(() {
              playBtn = Icons.pause;
            });

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



  Future decryptCachedFiles() async{
    // try {
      firstDecryptedFilePath = await decryptFileInJava(encryptedAudioFiles[currentPlayingFileIndex].path);

      await setAudioManager();

      compute(decryptAllFiles, encryptedAudioFiles).then((result) => {
        courseStore.setPlayingFile(
            encryptedAudioFiles,
            result[1],
            result[0],
            0),
        setAudioList(result[1])
      });

      // courseStore.setPlayer(_player);

      print('The decryption has been completed successfully.');
      print('Decrypted file 1: $firstDecryptedFilePath');
    // } on AesCryptException catch (e) {
    //   if (e.type == AesCryptExceptionType.destFileExists) {
    //     print('The decryption has been completed unsuccessfully.');
    //     print(e.message);
    //   }
    // }
  }

  void playNextTrack() async{
    //_player = AudioPlayer();
    // setAudioPlayerEvents();
    // courseStore.setPlayer(_player);
    var nextDecryptedFilePath = courseStore
        .decryptedPlayingFiles[courseStore.currentPlayingFileIndex];
    // _player.play(nextDecryptedFilePath, isLocal: true);
    audioManagerInstance
        .start("file://$nextDecryptedFilePath", widget.episodeDetails.name,
        desc: widget.episodeDetails.description,
        auto: true,
        cover: widget.courseCoverUrl)
        .then((err) {
      print(err);
    });
    // await AudioManager.instance.playOrPause();
  }

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);
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
                      image: NetworkImage(courseCover),
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
                              flex: 1,
                              child: Center(
                                child: Text(
                                  episode.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 23.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  height: MediaQuery.of(context).size.width * 0.8,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(courseCover),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  "بیطرف",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 23.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                // decoration: BoxDecoration(
                                //   color: Colors.white,
                                //   borderRadius: BorderRadius.only(
                                //     topLeft: Radius.circular(10.0),
                                //     topRight: Radius.circular(10.0),
                                //   ),
                                // ),
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
                                          IconButton(
                                            iconSize: 35.0,
                                            color: Colors.white,
                                            onPressed: () {
                                              int tempPosition = 0;
                                              if(position.inSeconds < 30){
                                                tempPosition = 0;
                                              }
                                              else{
                                                tempPosition = position.inSeconds - 30;
                                              }
                                              setState(() {
                                                position = new Duration(seconds: tempPosition);
                                                seekToSec(position.inMilliseconds);
                                              });
                                            },
                                            icon: Icon(
                                              Icons.replay_30,
                                            ),
                                          ),
                                          IconButton(
                                            iconSize: 45.0,
                                            color: Colors.white,
                                            onPressed: () async {
                                              if (!audioManagerInstance.isPlaying /*playerState != AudioPlayerState.PLAYING*/) {
                                                // _player.play(firstDecryptedFilePath, isLocal: true);
                                                await audioManagerInstance.playOrPause();
                                                setState(() {
                                                  playBtn = Icons.pause;
                                                });
                                                if(episodeAudios.length > audioManagerInstance.audioList.length)
                                                  await downloadAndDecryptFiles(episodeAudios);
                                              } else {
                                                // _player.pause();
                                                await AudioManager.instance.playOrPause();
                                                setState(() {
                                                  playBtn = Icons.play_arrow;
                                                });
                                              }
                                            },
                                            icon: Icon(
                                              playBtn,
                                            ),
                                          ),
                                          IconButton(
                                            iconSize: 35.0,
                                            color: Colors.white,
                                            onPressed: () {
                                              int tempPosition = position.inSeconds + 30;
                                              if(tempPosition > audioManagerInstance.duration.inSeconds){
                                                tempPosition = audioManagerInstance.duration.inSeconds;
                                              }
                                              setState(() {
                                                position = new Duration(seconds: tempPosition);
                                                seekToSec(position.inMilliseconds);
                                              });
                                            },
                                            icon: Icon(
                                              Icons.forward_30,
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
          return Container(
            color: Color(0xFF202028),
            child: SpinKitWave(
              type: SpinKitWaveType.center,
              color: Color(0xFF20BFA9),
              size: 65.0,
            ),
          );
        }
      }
    );
  }
}
