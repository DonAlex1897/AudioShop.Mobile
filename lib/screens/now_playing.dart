import 'dart:ui' as ui;
import 'package:aes_crypt/aes_crypt.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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

class _NowPlayingState extends State<NowPlaying> {
  //we will need some variables
  bool playing = false; // at the begining we are not playing any song
  IconData playBtn = Icons.play_arrow; // the main state of the play button icon
  var crypt;
  var audioFile;
  var decFilepath;
  CourseStore courseStore;

  //Now let's start by creating our music player
  //first let's declare some object
  AudioPlayer _player;
  AudioCache cache;

  Duration position = new Duration();
  Duration musicLength = new Duration();
  AudioPlayerState playerState;


  //we will create a custom slider

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
    crypt.setPassword('1qaz2wsX');
    crypt.setOverwriteMode(AesCryptOwMode.on);

    setAudioFile();
  }

  Future setAudioFile() async{
    audioFile = await DefaultCacheManager().getSingleFile(widget.episodeDetails.fileUrl);
    if(courseStore != null &&
        courseStore.playingFile != null &&
        courseStore.playingFile.path == audioFile.path){
      _player = courseStore.player;
      playBtn = Icons.pause;
    }
    else{
      if(courseStore != null && courseStore.player != null)
        courseStore.player.stop();
      _player = AudioPlayer();
      courseStore.setPlayingFile(audioFile, _player);
      playBtn = Icons.play_arrow;
    }

    //now let's handle the audioplayer time
    //this function will allow you to get the music duration
    _player.onDurationChanged.listen((d) {
      setState(() {
        musicLength = d;
      });
    });



    //this function will allow us to move the cursor of the slider while we are playing the song
    _player.onAudioPositionChanged.listen((p) {
      setState(() {
        position = p;
      });
    }) ;

    _player.onPlayerCompletion.listen((event) {
      setState(() {
        position = musicLength;
        playBtn = Icons.play_arrow;
        playing = false;
      });
    });

    _player.onPlayerStateChanged.listen((AudioPlayerState s) {
      setState(() {
        playerState = s;
        if(playerState == AudioPlayerState.COMPLETED){
          courseStore.playingFile(null, null);
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

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);
    CourseEpisode episode = widget.episodeDetails;
    String courseCover = widget.courseCoverUrl;

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
      //let's start by creating the main UI of the app
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
                                          if(/*decFilepath == null*/audioFile == null){
                                            audioFile = await DefaultCacheManager().getSingleFile(widget.episodeDetails.fileUrl);

                                            courseStore.setPlayingFile(audioFile, _player);
                                            // try {
                                            //   // Decrypts the file which has been just encrypted.
                                            //   // It returns a path to decrypted file.
                                            //   decFilepath = crypt.decryptFileSync(audioFile.path);
                                            //   print('The decryption has been completed successfully.');
                                            //   print('Decrypted file 1: $decFilepath');
                                            // } on AesCryptException catch (e) {
                                            //   // It goes here if the file naming mode set as AesCryptFnMode.warn
                                            //   // and decrypted file already exists.
                                            //   if (e.type == AesCryptExceptionType.destFileExists) {
                                            //     print('The decryption has been completed unsuccessfully.');
                                            //     print(e.message);
                                            //   }
                                            // }
                                          }
                                          //now let's play the song
                                          _player.play(audioFile.path, isLocal: true);
                                          // setState(() {
                                          //   playBtn = Icons.pause;
                                          //   playing = true;
                                          // });
                                        } else {
                                          _player.pause();
                                          // setState(() {
                                          //   playBtn = Icons.play_arrow;
                                          //   playing = false;
                                          // });
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
}
