import 'dart:convert';
import 'package:mobile/models/ticket.dart';
import 'package:mobile/models/ticket_response.dart';
import 'package:mobile/shared/global_variables.dart';
import 'package:http/http.dart' as http;

class TicketService{
  String baseUrl = GlobalVariables.baseUrl + 'api/tickets';

  Future<List<Ticket>> getUserTickets(String userId, String token) async {
    try{
      String url = baseUrl + '/user/$userId';
      http.Response response = await http.get(Uri.encodeFull(url),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          });

      if(response.statusCode == 200){
        String data = response.body;
        var ticketMap = jsonDecode(data);
        List<Ticket> ticketList = [];
        for(var ticket in ticketMap){
          ticketList.add(Ticket.fromJson(ticket));
        }
        return ticketList;
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

  Future<List<TicketResponse>> getTicketResponses(int ticketId, String token) async {
    try{
      String url = baseUrl + '/' + ticketId.toString();
      http.Response response = await http.get(Uri.encodeFull(url),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          });

      if(response.statusCode == 200){
        String data = response.body;
        var ticketResponseMap = jsonDecode(data);
        List<TicketResponse> ticketResponseList = [];
        for(var ticketResponse in ticketResponseMap['ticketResponses']){
          ticketResponseList.add(TicketResponse.fromJson(ticketResponse));
        }
        return ticketResponseList;
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

  Future<Ticket> sendTicket(Ticket ticket, String token) async {
    try{
      String url = baseUrl;
      var body = ticket.toJson();

      http.Response response = await http.post(Uri.encodeFull(url),
          body: body,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          });

      if(response.statusCode == 200){
        String data = response.body;
        var ticketMap = jsonDecode(data);
        Ticket ticket = Ticket.fromJson(ticketMap);
        return ticket;
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

  Future<TicketResponse> sendTicketResponse(TicketResponse ticketResponse, String token) async {
    try{
      String url = baseUrl + '/response';
      var body = ticketResponse.toJson();

      http.Response response = await http.post(Uri.encodeFull(url),
          body: body,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          });

      if(response.statusCode == 200){
        String data = response.body;
        var ticketResponseMap = jsonDecode(data);
        TicketResponse ticketResponse = TicketResponse.fromJson(ticketResponseMap);
        return ticketResponse;
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

  Future<Ticket> finishTicket(int ticketId, String token) async {
    try{
      String url = baseUrl + '/' + ticketId.toString();
      http.Response response = await http.put(Uri.encodeFull(url),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer $token",
          });

      if(response.statusCode == 200){
        String data = response.body;
        var ticketMap = jsonDecode(data);
        Ticket ticket = Ticket.fromJson(ticketMap);

        return ticket;
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