import 'dart:ui';

import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/models/message.dart';
import 'package:mobile/services/message_service.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shamsi_date/extensions.dart';
import 'dart:ui' as ui;

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  CourseStore courseStore;
  FlutterSecureStorage secureStorage = FlutterSecureStorage();
  List<Message> privateMessages = [];
  List<Message> publicMessages = [];
  List<Message> allMessages = [];
  Future<List<Message>> messagesFuture;

  @override
  void initState() {
    messagesFuture = createMessageLists();
    super.initState();
  }

  Future<List<Message>> createMessageLists() async {
    MessageService messageService = MessageService();
    String token = await secureStorage.read(key: 'token');
    if (token != null || token != "") {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['nameid'];
      allMessages = await messageService.getPersonalMessages(userId);
      if (allMessages != null) {
        setState(() {
          privateMessages = allMessages
              .where((element) =>
                  (element.messageType == 1 ||
                  element.messageType == 2 ||
                  element.messageType == 3 ||
                  element.messageType == 4) && element.sendInApp)
              .toList();
          publicMessages =
              allMessages.where((element) =>
                  element.messageType == 0 &&
                  element.sendInApp).toList();
        });
      }
    }
    return allMessages;
  }

  Widget privateMessagesTab() {
    return privateMessages.length > 0
        ? ListView.builder(
            itemCount: privateMessages.length,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            privateMessages[index].title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              privateMessages[index].inAppSeen
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Container(
                                        width: 30,
                                        height: 16,
                                        color: Colors.redAccent,
                                        child: Center(
                                          child: Text(
                                            'جدید',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                              Directionality(
                                textDirection: ui.TextDirection.ltr,
                                child: Text(
                                  privateMessages[index]
                                          .createdAt
                                          .toJalali()
                                          .toString()
                                          .substring(7)
                                          .split(')')[0] +
                                      '  ' +
                                      privateMessages[index]
                                          .createdAt
                                          .toString()
                                          .split(' ')[1]
                                          .substring(0, 5),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    collapsed: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          privateMessages[index].body,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    expanded: Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              privateMessages[index].body,
                              softWrap: true,
                              maxLines: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            })
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/noMessage.png',
                width: MediaQuery.of(context).size.width * 0.7,
              ),
              Text(
                'هیچ پیامی ندارید',
                style: TextStyle(color: Colors.white, fontSize: 19),
              )
            ],
          );
  }

  Widget publicMessagesTab() {
    return publicMessages.length > 0
        ? ListView.builder(
            itemCount: publicMessages.length,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            publicMessages[index].title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              publicMessages[index].inAppSeen
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Container(
                                        width: 30,
                                        height: 16,
                                        color: Colors.redAccent,
                                        child: Center(
                                          child: Text(
                                            'جدید',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                              Directionality(
                                textDirection: ui.TextDirection.ltr,
                                child: Text(
                                  publicMessages[index]
                                          .createdAt
                                          .toJalali()
                                          .toString()
                                          .substring(7)
                                          .split(')')[0] +
                                      '  ' +
                                      publicMessages[index]
                                          .createdAt
                                          .toString()
                                          .split(' ')[1]
                                          .substring(0, 5),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    collapsed: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          publicMessages[index].body,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    expanded: Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              publicMessages[index].body,
                              softWrap: true,
                              maxLines: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            })
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/noMessage.png',
                width: MediaQuery.of(context).size.width * 0.7,
              ),
              Text(
                'هیچ پیامی ندارید',
                style: TextStyle(color: Colors.white, fontSize: 19),
              )
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: 150,
                  height: 40,
                  decoration: BoxDecoration(
                    //border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0xFF20BFA9),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      List<int> unseenMessages = [];
                      if (allMessages != null &&
                          allMessages.length > 0 &&
                          allMessages
                                  .where((element) =>
                                      element.sendInApp && !element.inAppSeen)
                                  .length > 0) {
                        for (var item in allMessages.where(
                                (element) => element.sendInApp && !element.inAppSeen)) {
                          unseenMessages.add(item.id);
                        }
                        String token = await secureStorage.read(key: 'token');
                        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
                        String userId = decodedToken['nameid'];
                        MessageService messageService = MessageService();
                        bool isSeen = await messageService.setMessageAsSeen(
                            userId, [], unseenMessages
                        );
                        if (isSeen)
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => super.widget));
                        else {
                          Fluttertoast.showToast(
                              msg: 'اشکال در ارتباط با سرور. مجددا تلاش کنید');
                        }
                      }
                      else{
                        Fluttertoast.showToast(
                            msg: 'هیچ پیام مشاهده نشده ای ندارید');
                      }
                    },
                    child: Text('مشاهده همه پیام ها',
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ],
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios)),
            bottom: TabBar(
              tabs: [
                Tab(
                  text: 'پیام های عمومی',
                ),
                Tab(
                  text: 'پیام های شخصی',
                )
              ],
            ),
          ),
          body: TabBarView(
            children: [
              publicMessagesTab(),
              privateMessagesTab(),
            ],
          ),
        ),
      ),
    );
  }
}
