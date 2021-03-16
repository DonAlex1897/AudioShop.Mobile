import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/support.png'),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text('در صورت بروز هر گونه مشکل یا برای پرسیدن '
                  'سوالات خود، می توانید از طریق واتسپ و تلگرام با'
                  'کارشناسان ما در ارتباط باشید',
                style: TextStyle(fontFamily: 'AlexandriaFLF', fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 58.0, right: 58.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async{
                        FlutterOpenWhatsapp
                            .sendSingleMessage(
                              "+989012416905",
                              "سلام. در مورد اپلیکیشن مهارت های ارتباطی"
                                  " سوال داشتم ازتون.");
                        // String chatUrl = 'https://api.whatsapp.com/send/?phone=989012416905&text&app_absent=0';
                        // if (await canLaunch(chatUrl)){
                        //   try{
                        //     await launch(chatUrl);
                        //   }
                        //   catch(e){
                        //     print(e.toString());
                        //   }
                        //   finally{
                        //     SystemNavigator.pop();
                        //   }
                        // }
                      },
                      child: Image.asset('assets/images/whatsapp.png'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () async{
                        // FlutterOpenWhatsapp
                        //     .sendSingleMessage(
                        //     "+989012416905",
                        //     "سلام. در مورد اپلیکیشن مهارت های ارتباطی"
                        //         " سوال داشتم ازتون.");
                        String chatUrl = 'https://telegram.me/samiehn';
                        if (await canLaunch(chatUrl)){
                          try{
                            await launch(chatUrl);
                          }
                          catch(e){
                            print(e.toString());
                          }
                        }
                      },
                      child: Image.asset('assets/images/telegram.png'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
