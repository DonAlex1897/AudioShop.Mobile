import 'dart:ui';

import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/message.dart';
import 'package:mobile/services/message_service.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shamsi_date/extensions.dart';
import 'dart:ui' as ui;


class MessagesPage extends StatefulWidget {
  final List<Message> messages;
  MessagesPage(this.messages);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  CourseStore courseStore;
  List<Message> privateMessages = [];
  List<Message> publicMessages = [];

  @override
  void initState() {
    createMessageLists();
    super.initState();
  }

  createMessageLists(){
    setState(() {
      privateMessages = widget.messages
          .where((element) => element.messageType == 1 ||
          element.messageType == 2 || element.messageType == 3 ||
          element.messageType == 4).toList();
      publicMessages = widget.messages
          .where((element) => element.messageType == 0).toList();
    });
  }

  Widget privateMessagesTab(){
    return privateMessages.length > 0 ?
      ListView.builder(
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
                  header: InkWell(
                    onTap: () async{
                      MessageService messageService = MessageService();
                      messageService.setMessageAsSeen(
                          privateMessages[index].id,
                          courseStore.userId);
                    },
                    child: Padding(
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
                              privateMessages[index].isSeen ? SizedBox():
                              Padding(
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
                                  privateMessages[index].createdAt.toJalali()
                                      .toString().substring(7).split(')')[0] +
                                      '  ' + privateMessages[index].createdAt
                                      .toString().split(' ')[1].substring(0,5),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  collapsed: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      privateMessages[index].body,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  expanded: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        privateMessages[index].body,
                        softWrap: true,
                        maxLines: 20,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }) :
      SizedBox();
  }

  Widget publicMessagesTab(){
    return publicMessages.length > 0 ?
    ListView.builder(
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
                header: InkWell(
                  onTap: () async{
                    MessageService messageService = MessageService();
                    messageService.setMessageAsSeen(
                        publicMessages[index].id,
                        courseStore.userId);
                  },
                  child: Padding(
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
                            publicMessages[index].isSeen ? SizedBox():
                            Padding(
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
                                publicMessages[index].createdAt.toJalali()
                                    .toString().substring(7).split(')')[0] +
                                    '  ' + publicMessages[index].createdAt
                                    .toString().split(' ')[1].substring(0,5),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                collapsed: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    publicMessages[index].body,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                expanded: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      publicMessages[index].body,
                      softWrap: true,
                      maxLines: 20,
                    ),
                  ),
                ),
              ),
            ),
          );
        }) :
    SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: Container(),
            bottom: TabBar(
              tabs: [
                Tab(text: 'پیام های عمومی',),
                Tab(text: 'پیام های شخصی',)
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
