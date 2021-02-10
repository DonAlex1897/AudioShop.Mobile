import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile/models/course_episode.dart';

class CourseEpisodeData{
  final String baseUrl = 'http://10.0.2.2:5000/';

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
}