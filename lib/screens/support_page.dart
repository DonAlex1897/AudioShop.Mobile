import 'package:flutter/material.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  CourseStore courseStore;

  @override
  Widget build(BuildContext context) {
    courseStore = Provider.of<CourseStore>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(58, 20, 58, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/support.png'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text('در صورت بروز هر گونه مشکل یا برای پرسیدن '
                      'سوالات خود، می توانید از طریق راه های ارتباطی زیر، با'
                      'کارشناسان ما در تماس باشید',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.justify,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.white60)
                    ),
                    child: TextButton(
                      onPressed: () async{
                        String chatUrl = 'https://api.whatsapp.com/send/?phone=989108860897&text&app_absent=0';
                        // if (await canLaunch(chatUrl)){
                          try{
                            await launch(chatUrl);
                          }
                          catch(e){
                            print(e.toString());
                          }
                        }
                      ,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              'واتسپ اِستارشو',
                              style: TextStyle(fontSize: 22, color: Colors.white),)
                          ),
                          Expanded(
                            flex: 1,
                            child: Image.asset('assets/images/whatsapp.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.white60)
                    ),
                    child: TextButton(
                      onPressed: () async{
                        String chatUrl = 'https://telegram.me/StarShow_ir';
                        //if (await canLaunch(chatUrl)){
                          try{
                            await launch(chatUrl);
                          }
                          catch(e){
                            print(e.toString());
                          }
                        }
                      ,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 5,
                              child: Text(
                                'تلگرام اِستارشو',
                                style: TextStyle(fontSize: 22, color: Colors.white),)
                          ),
                          Expanded(
                            flex: 1,
                            child: Image.asset('assets/images/telegram.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.white60)
                    ),
                    child: TextButton(
                      onPressed: () async{
                        String chatUrl = 'https://instagram.com/starshow_ir?utm_medium=copy_link';
                        //if (await canLaunch(chatUrl)){
                          try{
                            await launch(chatUrl);
                          }
                          catch(e){
                            print(e.toString());
                          }
                        //}
                      },
                      child: Row(
                        children: [
                          Expanded(
                              flex: 5,
                              child: Text(
                                'اینستاگرام اِستارشو',
                                style: TextStyle(fontSize: 22, color: Colors.white),)
                          ),
                          Expanded(
                            flex: 1,
                            child: Image.asset('assets/images/instagram.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.white60)
                    ),
                    child: TextButton(
                      onPressed: () async{
                        String chatUrl = 'tel://${courseStore.supportPhoneNumber}';
                        //if (await canLaunch(chatUrl)){
                          try{
                            await launch(chatUrl);
                          }
                          catch(e){
                            print(e.toString());
                          }
                        //}
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تلفن تماس اِستارشو',
                                    style: TextStyle(fontSize: 16, color: Colors.white),),
                                  Text(
                                    courseStore.supportPhoneNumber,
                                    style: TextStyle(fontSize: 16, color: Colors.white),),
                                ],
                              )
                          ),
                          Expanded(
                            flex: 1,
                            child: Image.asset('assets/images/phone.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
