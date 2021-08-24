import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/models/ticket.dart';
import 'package:mobile/models/ticket_response.dart';
import 'package:mobile/services/ticket_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shamsi_date/extensions.dart';
import 'dart:ui' as ui;

class TicketResponsePage extends StatefulWidget {
  final String ticketTitle;
  final String token;
  final TicketStatus ticketStatus;
  final int ticketId;
  TicketResponsePage(this.ticketTitle, this.token, this.ticketId, this.ticketStatus);

  @override
  _TicketResponsePageState createState() => _TicketResponsePageState();
}

class _TicketResponsePageState extends State<TicketResponsePage> {
  Future<List<TicketResponse>> ticketResponseFuture;
  List<TicketResponse> ticketResponseList = [];
  TextEditingController newResponseController = TextEditingController();
  TicketStatus ticketStatus;

  @override
  void initState() {
    ticketResponseFuture = getResponses();
    ticketStatus = widget.ticketStatus;
    super.initState();
  }

  Future<List<TicketResponse>> getResponses() async {
    TicketService ticketService = TicketService();
    ticketResponseList = await ticketService
        .getTicketResponses(widget.ticketId, widget.token);
    return ticketResponseList;
  }

  Future<TicketResponse> sendResponse() async {
    TicketService ticketService = TicketService();
    return await ticketService.sendTicketResponse(
        TicketResponse(
          ticketId: widget.ticketId,
          body: newResponseController.text,
        ), widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios)
            ),
            title: Text(widget.ticketTitle),
            actions: [
              ticketStatus == TicketStatus.Finished ?
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    //border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white10,
                  ),
                  child: TextButton(
                    onPressed: () async {
                    },
                    child:
                    Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                        Text(
                            'بسته شده',
                            style: TextStyle(color: Colors.white,)
                        ),
                      ],
                    ),
                  ),
                ),
              ):
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    //border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0xFF20BFA9),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      TicketService ticketService = TicketService();
                      Ticket ticket = await ticketService
                          .finishTicket(widget.ticketId, widget.token);
                      if(ticket != null){
                        setState(() {
                          ticketStatus = TicketStatus.Finished;
                        });
                      }
                      else{

                        AlertDialog alert = AlertDialog(
                          title: Text('توجه'),
                          content: Text('خطا در ارتباط با سرور. لطفا مجددا تلاش کنید'),
                          actions: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                width: 400,
                                height: 40,
                                decoration: BoxDecoration(
                                  //border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color(0xFF20BFA9),
                                ),
                                child: TextButton(
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                  child:
                                  Text(
                                      'باشه',
                                      style: TextStyle(color: Colors.white,)
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      }
                    },
                    child:
                    Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                        Text(
                            'بستن تیکت',
                            style: TextStyle(color: Colors.white,)
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children:[
              FutureBuilder(
                future: ticketResponseFuture,
                builder: (context, data){
                  if(data.hasData){
                    return ListView.builder(
                        itemCount: ticketResponseList.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if(index <= ticketResponseList.length - 1)
                            return Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: ticketResponseList[index].issuedByAdmin ?
                                  Colors.black12 : Colors.white24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            ticketResponseList[index].issuedByAdmin ?
                                            'ادمین' : 'کاربر',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Directionality(
                                            textDirection: ui.TextDirection.ltr,
                                            child: Text(
                                              ticketResponseList[index].createdAt.toJalali()
                                                  .toString().substring(7).split(')')[0] +
                                                  '  ' + ticketResponseList[index].createdAt
                                                  .toString().split(' ')[1].substring(0,5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        ticketResponseList[index].body,
                                        softWrap: true,
                                        maxLines: 20,
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          );
                          else
                            return SizedBox(
                              height: 70,
                            );
                        });
                  }
                  else
                    return SpinKitWave(
                      type: SpinKitWaveType.center,
                      color: Color(0xFF20BFA9),
                      size: 25.0,
                    );
                }
              ),
              ticketStatus == TicketStatus.Finished ?
              SizedBox() :
              Align(
                alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.black,
                    height: 70,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Directionality(
                            textDirection: ui.TextDirection.ltr,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF20BFA9),
                                shape: BoxShape.circle
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () async {
                                    TicketResponse ticketResponse =  await sendResponse();
                                    if(ticketResponse != null){
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) => super.widget));
                                    }
                                    else{
                                      AlertDialog alert = AlertDialog(
                                        title: Text('توجه'),
                                        content: Text('ارسال پاسخ با مشکل مواجه شد. لطفا مجددا تلاش کنید'),
                                        actions: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Container(
                                              width: 400,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                //border: Border.all(color: Colors.black),
                                                borderRadius: BorderRadius.circular(5),
                                                color: Color(0xFF20BFA9),
                                              ),
                                              child: TextButton(
                                                onPressed: (){
                                                  Navigator.of(context).pop();
                                                },
                                                child:
                                                Text(
                                                    'باشه',
                                                    style: TextStyle(color: Colors.white,)
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                      await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return alert;
                                        },
                                      );
                                    }
                                  },
                                  child: const Icon(Icons.send),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              child: TextField(
                                style: TextStyle(
                                    decorationColor: Colors.black, color: Colors.white),
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  border: OutlineInputBorder(),
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  labelText: 'پیام جدید',
                                  hintStyle: TextStyle(
                                    color: Colors.white60,
                                  ),
                                ),
                                controller: newResponseController,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),)
            ],
          ),
        ));
  }
}
