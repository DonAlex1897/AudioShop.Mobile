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
   int messageType;
   bool isSeen;

   Message({this.id, this.title, this.body, this.link, this.courseId, this.userId,
     this.clockRangeBegin, this.clockRangeEnd, this.isRepeatable, this.createdAt,
     this.sendPush, this.messageType, this.isSeen});

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
         sendPush = json['sendPush'],
         messageType = json['messageType'],
         isSeen = json['isSeen'],
         clockRangeEnd = json['clockRangeEnd'];
}