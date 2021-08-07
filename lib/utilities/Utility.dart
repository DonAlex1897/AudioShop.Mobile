import 'package:flutter/material.dart';
import 'package:mobile/models/course.dart';
import 'package:mobile/models/course_episode.dart';
import 'package:mobile/screens/advertisement_page.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/utilities/ads_pop_up.dart';

class Utility{
  static void showAdsAlertDialog(
      BuildContext context,
      NavigatedPage navigatedPage,
      [
        Course course,
        dynamic courseCover,
        String noPictureAsset,
        CourseEpisode courseEpisode,
        String courseCoverURL
      ]){
    showDialog(
        context: context,
        builder: (BuildContext newContext){
          return Dialog(
            insetPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
            child: Container(
              width: MediaQuery.of(newContext).size.width * 0.9,
              child: AdsPopUp(
                navigatedPage: navigatedPage,
                course: course,
                courseCover: courseCover,
                noPictureAsset: noPictureAsset,
                episodeDetails: courseEpisode,
                courseCoverUrl: courseCoverURL,
              ),
            ),
          );
        });
  }
}