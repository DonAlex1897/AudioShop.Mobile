class Message{
   int id;
   String title;
   String body;
   String link;
   int courseId;
   String userId;
   int clockRangeBegin;
   int clockRangeEnd;
   bool isRepeatable;
   DateTime createdAt;
   bool sendPush;
   bool pushSent;
   bool sendInApp;
   bool inAppSeen;
   int messageType;

   Message({this.id, this.title, this.body, this.link, this.courseId, this.userId,
     this.clockRangeBegin, this.clockRangeEnd, this.isRepeatable, this.createdAt,
     this.sendPush, this.messageType, this.pushSent, this.inAppSeen, this.sendInApp});

   Message.fromJson(Map<String, dynamic> json)
       : userId = json['userId'],
         id = json['id'],
         title = json['title'],
         body = json['body'],
         link = json['link'],
         courseId = json['courseId'],
         clockRangeBegin = json['clockRangeBegin'],
         isRepeatable = json['isRepeatable'],
         createdAt = DateTime.parse(json['createdAt']) ,
         messageType = json['messageType'],
          sendPush = json['sendPush'],
          pushSent = json['pushSent'],
          sendInApp = json['sendInApp'],
          inAppSeen = json['inAppSeen'],
         clockRangeEnd = json['clockRangeEnd'];
}