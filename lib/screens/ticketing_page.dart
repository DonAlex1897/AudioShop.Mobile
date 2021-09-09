import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/models/ticket.dart';
import 'package:mobile/screens/new_ticket_page.dart';
import 'package:mobile/screens/ticket_responses_page.dart';
import 'package:mobile/services/ticket_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shamsi_date/extensions.dart';
import 'dart:ui' as ui;

class TicketingPage extends StatefulWidget {
  final String userId;
  final String token;
  TicketingPage(this.userId, this.token);

  @override
  _TicketingPageState createState() => _TicketingPageState();
}

class _TicketingPageState extends State<TicketingPage> {
  Future<List<Ticket>> ticketsFuture;
  List<Ticket> ticketsList = [];

  @override
  void initState() {
    ticketsFuture = getTickets();
    super.initState();
  }

  Future<List<Ticket>> getTickets() async {
    TicketService ticketService = TicketService();
    ticketsList = await ticketService.getUserTickets(widget.userId, widget.token);
    if(ticketsList == null)
      return [];
    return ticketsList;
  }

  Widget statusWidget(TicketStatus status){
    Widget statusIcon;
    switch(status){
      case TicketStatus.Pending:
        statusIcon = Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white30,
            ),
            width: 70,
            height: 18,
            child: Center(
              child: Text(
                'در انتظار بررسی',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
        break;
      case TicketStatus.AdminAnswered:
        statusIcon = Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.redAccent,
            ),
            width: 70,
            height: 18,
            child: Center(
              child: Text(
                'پاسخ ادمین',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
        break;
      case TicketStatus.MemberAnswered:
        statusIcon = Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white30,
            ),
            width: 70,
            height: 18,
            child: Center(
              child: Text(
                'در انتظار پاسخ',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
        break;
      case TicketStatus.Finished:
        statusIcon = Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color(0xFF20BFA9),
            ),
            width: 70,
            height: 20,
            child: Center(
              child: Text(
                'بسته شده',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
        break;
    }
    return statusIcon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تیکت های من'),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context){
                return NewTicketPage();
              })
          ).then((value) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => super.widget));
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Color(0xFF20BFA9),
      ),
      body: FutureBuilder(
        future: ticketsFuture,
        builder: (context, data){
          if(data.hasData){
            if(ticketsList != null){
              return ListView.builder(
                  itemCount: ticketsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black12,
                        ),
                        child: ExpandablePanel(
                          theme: const ExpandableThemeData(
                            // headerAlignment: ExpandablePanelHeaderAlignment.center,
                            tapBodyToExpand: true,
                            tapBodyToCollapse: true,
                            hasIcon: true,
                            iconColor: Colors.white,
                          ),
                          header: Padding(
                            padding: const EdgeInsets.only(right: 15, top: 8),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      ticketsList[index].title,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    statusWidget(ticketsList[index].ticketStatus)
                                  ],
                                ),
                                Directionality(
                                  textDirection: ui.TextDirection.ltr,
                                  child: Text(
                                    ticketsList[index].createdAt.toJalali()
                                        .toString().substring(7).split(')')[0] +
                                        '  ' + ticketsList[index].createdAt
                                        .toString().split(' ')[1].substring(0,5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          collapsed: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                ticketsList[index].description,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          expanded: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    ticketsList[index].description,
                                    softWrap: true,
                                    maxLines: 20,
                                  ),
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
                                        onPressed: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            return TicketResponsePage(
                                              ticketsList[index].title,
                                              widget.token,
                                              ticketsList[index].id,
                                              ticketsList[index].ticketStatus,
                                            );
                                          })).then((value) {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext context) => super.widget));
                                          });
                                        },
                                        child:
                                        Text(
                                            'مشاهده',
                                            style: TextStyle(color: Colors.white,)
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            }
            else{
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/noMessage.png',
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                    Text(
                      'هیچ تیکتی ثبت نکرده اید',
                      style: TextStyle(color: Colors.white, fontSize: 19),
                    )
                  ],
                ),
              );
            }
          }
          else
            return SpinKitWave(
              type: SpinKitWaveType.center,
              color: Color(0xFF20BFA9),
              size: 25.0,
            );
        }
      ),
    );
  }
}
