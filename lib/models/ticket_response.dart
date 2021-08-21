import 'dart:convert';

class TicketResponse{
   int id;
   int ticketId;
   String body;
   DateTime createdAt;
   bool issuedByAdmin;


   TicketResponse({
      this.id,
      this.createdAt,
      this.ticketId,
      this.body,
      this.issuedByAdmin
   });

   TicketResponse.fromJson(Map<String, dynamic> json)
       : ticketId = json['ticketId'],
         id = json['id'],
         createdAt = DateTime.parse(json['createdAt']),
         body = json['body'],
         issuedByAdmin = json['issuedByAdmin'];

   String toJson() {
      if(id != null){
         return jsonEncode({
            'id': id,
            'ticketId': ticketId,
            'title': DateTime.now().toString(),
            'body': body,
            'issuedByAdmin': false
         });
      }
      else{
         return jsonEncode({
            'ticketId': ticketId,
            'title': DateTime.now().toString(),
            'body': body,
            'issuedByAdmin': false
         });
      }
   }
}