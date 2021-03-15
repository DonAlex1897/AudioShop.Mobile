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
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.pink[100],
                  width: 5,
                ),
                image: DecorationImage(
                    image: AssetImage('assets/images/sybil.jpg'),
                    fit: BoxFit.fill
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text('Hey Honey. I am out. send me something on '
                  'Whatsapp so that I call you back later',
                style: TextStyle(fontFamily: 'AlexandriaFLF', fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(
              width: 150,
              child: Center(
                child: Row(
                  children: [
                    TextButton(
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
                    TextButton(
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
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
