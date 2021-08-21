import 'dart:convert';

import 'package:mobile/shared/enums.dart';

class Ticket{
   int id;
   String userId;
   String userName;
   String title;
   String description;
   DateTime createdAt;
   TicketStatus ticketStatus;


   Ticket({this.id, this.title, this.userId, this.userName,
      this.description, this.createdAt, this.ticketStatus});

   Ticket.fromJson(Map<String, dynamic> json)
       : userId = json['userId'],
         id = json['id'],
         title = json['title'],
         userName = json['userName'],
         description = json['description'],
         ticketStatus = TicketStatus.values[json['ticketStatus']],
         createdAt = DateTime.parse(json['createdAt']);

   String toJson() {
      if(id != null){
         return jsonEncode({
            'id': id,
            'userId': userId,
            'title': title,
            'userName': userName,
            'description': description,
            'createdAt': DateTime.now().toString()
         });
      }
      else{
         return jsonEncode({
            'userId': userId,
            'title': title,
            'userName': userName,
            'description': description,
            'createdAt': DateTime.now().toString()
         });
      }
   }
}