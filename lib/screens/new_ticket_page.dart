import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/ticket.dart';
import 'package:mobile/services/ticket_service.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';

class NewTicketPage extends StatefulWidget {
  @override
  _NewTicketPageState createState() => _NewTicketPageState();
}

class _NewTicketPageState extends State<NewTicketPage> {
  CourseStore courseStore;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.arrow_back_ios),
          title: Text('ثبت تیکت جدید'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
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
                      labelText: 'عنوان',
                      hintStyle: TextStyle(
                        color: Colors.white60,
                      ),
                      icon: Icon(
                        Icons.title,
                        size: 22,
                      ),
                    ),
                    controller: titleController,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  height: 300,
                  child: TextField(
                    maxLines: 100,
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
                      labelText: 'توضیحات',
                      hintStyle: TextStyle(
                        color: Colors.white60,
                      ),
                      icon: Icon(
                        Icons.description,
                        size: 22,
                      ),
                    ),
                    controller: descriptionController,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,44,8),
                child: ArgonButton(
                  height: 50,
                  width: 400,
                  borderRadius: 5.0,
                  color: Color(0xFF20BFA9),
                  child: Text(
                    "ثبت تیکت",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700
                    ),
                  ),
                  loader: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SpinKitRing(
                      color: Colors.white,
                      lineWidth: 4,
                    ),
                  ),
                  onTap:(startLoading, stopLoading, btnState) async {
                    startLoading();
                    TicketService ticketService = TicketService();

                    Ticket ticket = await ticketService.sendTicket(
                        Ticket(
                          userId: courseStore.userId,
                          userName: courseStore.userName,
                          title: titleController.text,
                          description: descriptionController.text,
                        ), courseStore.token);

                    if (ticket == null){
                      AlertDialog alert = AlertDialog(
                        title: Text('توجه'),
                        content: Text('ثبت تیکت با مشکل مواجه شد. لطفا مجددا تلاش کنید'),
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
                    else {
                      AlertDialog alert = AlertDialog(
                        title: Text('توجه'),
                        content: Text('پیام شما دریافت شد در اسرع وقت بررسی '
                            'و پاسخ داده خواهد شد.در صورت عدم دریافت'
                            ' پاسخ تا 72 ساعت لطفا از طریق قسمت '
                            'تماس با ما پیگیری فرمایید.'),
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
                      Navigator.of(context).pop();
                    }
                    stopLoading();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
