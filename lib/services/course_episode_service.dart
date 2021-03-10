import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/models/episode_audios.dart';

class CourseEpisodeData{
  String baseUrl = 'https://95.216.229.251/';
  String audioUrl = 'https://95.216.229.251/files/';

  CourseEpisodeData();

  Future<List<CourseEpisode>> getCourseEpisodes(int courseId) async{
    try{
      String episodesUrl = baseUrl + 'api/courses/' + courseId.toString() + '/episodes';
      http.Response response = await http.get(episodesUrl);
      if(response.statusCode == 200){
        String data = response.body;
        var courseEpisodeMap = jsonDecode(data);
        List<CourseEpisode> courseEpisodesList = List<CourseEpisode>();
        for(var courseEpisode in courseEpisodeMap){
          courseEpisodesList.add(CourseEpisode.fromJson(courseEpisode));
        }
        return courseEpisodesList;
      }
      else{
        print(response.statusCode);
        return null;
      }
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }


  Future<List<EpisodeAudios>> getEpisodeAudios(int episodeId) async{
    try{
      String episodeAudiosUrl = baseUrl + 'api/courses/episodes/' +episodeId.toString();
      http.Response response = await http.get(episodeAudiosUrl);
      if(response.statusCode == 200){
        String data = response.body;
        var episodeAudiosMap = jsonDecode(data);
        List<EpisodeAudios> episodeAudiosList = List<EpisodeAudios>();
        for(var map in episodeAudiosMap['audios']){
          episodeAudiosList.add(EpisodeAudios.fromJson(map, audioUrl, episodeAudiosMap['courseId']));
        }
        return episodeAudiosList;
      }
      else{
        print(response.statusCode);
        return null;
      }
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }
}