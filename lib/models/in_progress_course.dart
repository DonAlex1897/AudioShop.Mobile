class InProgressCourse{
  int courseId;
  int lastFinishedEpisodeSortNumber;
  int waitingTimeBetweenEpisodes;
  DateTime lastFinishedEpisodeTime;

  InProgressCourse({this.courseId, this.lastFinishedEpisodeSortNumber, this.waitingTimeBetweenEpisodes, this.lastFinishedEpisodeTime});
}