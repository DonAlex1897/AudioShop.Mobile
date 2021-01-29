import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:aes_crypt/aes_crypt.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';

class NowPlaying extends StatefulWidget {
  NowPlaying(this.episodeDetails, this.courseCoverUrl);
  final CourseEpisode episodeDetails;
  final String courseCoverUrl;

  @override
  _NowPlayingState createState() => _NowPlayingState();
}

var crypt;
List<dynamic> encryptedAudioFiles = List<dynamic>();
List<dynamic> decryptedAudioPaths = List<dynamic>();
CourseStore courseStore;
Future<dynamic> firstDecryptedFileFuture;
dynamic firstDecryptedFilePath;
int countOfFiles = 0;
int currentPlayingFileIndex = 0;
AudioPlayer _player;

FutureOr<List<dynamic>> decryptAllFiles(List<dynamic> encryptedAudios) async{
  List<dynamic> result = List<dynamic>();
  if(crypt == null){
    crypt = AesCrypt();
    crypt.setPassword('1qaz2wsX1qaz2wsX1qaz2wsX1qaz2wsX');
    crypt.setOverwriteMode(AesCryptOwMode.on);
  }
  for(int i = 0; i < encryptedAudios.length; i++)
  {
    countOfFiles++;
    dynamic tempDecryptedAudioPath = await crypt
        .decryptFileSync(encryptedAudios[i].path);
    decryptedAudioPaths.add(tempDecryptedAudioPath);
  }
  result.add(countOfFiles);
  result.add(decryptedAudioPaths);
  return result;
}

class _NowPlayingState extends State<NowPlaying> {
  IconData playBtn = Icons.play_arrow;

  AudioCache cache;

  Duration position = new Duration();
  Duration musicLength = new Duration();
  AudioPlayerState playerState;

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
            value: position.inSeconds.toDouble(),
            max: musicLength.inSeconds.toDouble(),
            onChanged: (value) {
              seekToSec(value.toInt());
              setState(() {
                position = Duration(seconds: value.toInt());
              });
            }));
  }

  //let's create the seek function that will allow us to go to a certain position of the music
  void seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    _player.seek(newPos);
  }

  //Now let's initialize our player
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // cache = AudioCache(fixedPlayer: _player);
    // Creates an instance of AesCrypt class.
    crypt = AesCrypt();
    // Sets encryption password.
    crypt.setPassword('1qaz2wsX1qaz2wsX1qaz2wsX1qaz2wsX');
    crypt.setOverwriteMode(AesCryptOwMode.on);

    firstDecryptedFileFuture = setAudioFile();
  }

  Future<List<dynamic>> getEncryptedAudioFiles(String episodeUrl) async{
    List<String> fileUrls = episodeUrl.split(',');
    if(fileUrls.length > 1){
      for(int i = 1; i < fileUrls.length; i++)
        fileUrls[i] = 'https://audioshoppp.ir/' + fileUrls[i];
    }
    List<dynamic> audioFiles = List<dynamic>();
    for(String url in fileUrls){
      dynamic audioFile = await DefaultCacheManager().getSingleFile(url);
      audioFiles.add(audioFile);
    }
    countOfFiles = audioFiles.length;

    return audioFiles;
  }

  Future<bool> isCurrentEpisodePlaying(List<dynamic> encryptedFiles) async
  {
    if(courseStore.encryptedPlayingFiles.length != encryptedAudioFiles.length)
      return false;
    else
    {
      for(int i = 0; i < encryptedAudioFiles.length; i++)
      {
        if(courseStore.encryptedPlayingFiles[i].path != encryptedAudioFiles[i].path)
          return false;
      }
    }
    return true;
  }

  Future<dynamic> setAudioFile() async{
    encryptedAudioFiles = await getEncryptedAudioFiles(widget.episodeDetails.fileUrl);
    // audioFile = await DefaultCacheManager().getSingleFile(widget.episodeDetails.fileUrl);
    if(courseStore != null &&
       courseStore.encryptedPlayingFiles != null &&
        await isCurrentEpisodePlaying(encryptedAudioFiles))
    {
      _player = courseStore.player;
      currentPlayingFileIndex = courseStore.currentPlayingFileIndex;
      firstDecryptedFilePath = courseStore.decryptedPlayingFiles[currentPlayingFileIndex];
      playBtn = Icons.pause;
    }
    else{
      if(courseStore != null && courseStore.player != null){
        courseStore.player.stop();
        for(var decryptedFile in courseStore.decryptedPlayingFiles){
          var file = File(decryptedFile);
          if(await file.exists())
            file.delete();
        }
      }
      _player = AudioPlayer();
      playBtn = Icons.play_arrow;
      await decryptCachedFiles();
    }

    setAudioPlayerEvents();

    return firstDecryptedFilePath;
  }

  void setAudioPlayerEvents(){
    _player.onDurationChanged.listen((d) {
      setState(() {
        musicLength = d;
      });
    });

    _player.onAudioPositionChanged.listen((p) {
      setState(() {
        position = p;
      });
    }) ;

    _player.onPlayerCompletion.listen((event) {
      setState(() {
        position = musicLength;
        playBtn = Icons.play_arrow;
      });
      if(courseStore.currentPlayingFileIndex < courseStore.countOfFilesPlaying - 1){
        courseStore.incrementPlayingFileIndex();
        position = new Duration();
        playNextTrack();
      }
      else{
        courseStore.incrementPlayingFileIndex();
      }
    });

    _player.onPlayerStateChanged.listen((AudioPlayerState s) {
      setState(() {
        playerState = s;
        if(playerState == AudioPlayerState.COMPLETED){
          // courseStore.playingFile(null, null);
          playBtn = Icons.play_arrow;
        }
        else if(playerState == AudioPlayerState.PLAYING){
          playBtn = Icons.pause;
        }
        else{
          playBtn = Icons.play_arrow;
        }
      });
    });
  }

  Future decryptCachedFiles() async{
    try {
      firstDecryptedFilePath = await crypt
          .decryptFileSync(encryptedAudioFiles[currentPlayingFileIndex].path);

      compute(decryptAllFiles, encryptedAudioFiles).then((result) => {
        courseStore.setPlayingFile(
            encryptedAudioFiles,
            result[1],
            _player,
            result[0],
            0)
      });

      print('The decryption has been completed successfully.');
      print('Decrypted file 1: $firstDecryptedFilePath');
    } on AesCryptException catch (e) {
      if (e.type == AesCryptExceptionType.destFileExists) {
        print('The decryption has been completed unsuccessfully.');
        print(e.message);
      }
    }
  }

  void playNextTrack(){
    _player = AudioPlayer();
    setAudioPlayerEvents();
    _player.play(courseStore
        .decryptedPlayingFiles[courseStore.currentPlayingFileIndex], isLocal: true);
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
                episode.course,
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
                                              const EdgeInsets.only(right: 14.0),
                                              child: Text(
                                                "${position.inMinutes}:${position.inSeconds.remainder(60)}",
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.only(left: 14.0),
                                              child: Text(
                                                "${musicLength.inMinutes}:${musicLength.inSeconds.remainder(60)}",
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
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.skip_next,
                                            ),
                                          ),
                                          IconButton(
                                            iconSize: 45.0,
                                            color: Colors.white,
                                            onPressed: () async {
                                              if (playerState != AudioPlayerState.PLAYING) {
                                                // if(/*decFilepath == null*/audioFile == null){
                                                //   audioFile = await DefaultCacheManager().getSingleFile(widget.episodeDetails.fileUrl);
                                                //   print('The file has been downloaded successfully.');
                                                //
                                                //   await decryptCachedFile();
                                                // }
                                                _player.play(firstDecryptedFilePath, isLocal: true);
                                              } else {
                                                _player.pause();
                                              }
                                            },
                                            icon: Icon(
                                              playBtn,
                                            ),
                                          ),
                                          IconButton(
                                            iconSize: 35.0,
                                            color: Colors.white,
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.skip_previous,
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
