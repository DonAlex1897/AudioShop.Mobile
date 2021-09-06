import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class PsychologicalTestsPage extends StatefulWidget {
  @override
  _PsychologicalTestsPageState createState() => _PsychologicalTestsPageState();
}

class _PsychologicalTestsPageState extends State<PsychologicalTestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // child: Center(
        //   child: Text(
        //     'این قسمت به زودی بارگذاری خواهد شد ',
        //     textAlign: TextAlign.justify,
        //     style: TextStyle(fontSize: 25),),
        // ),
        child: Column(
          children: [
            TextButton(
              onPressed: () async{
                String paymentPageUrl = 'https://www.16personalities'
                    '.com/fa/%D8%A2%D8%B2%D9%85%D9%88%D9%86-%D8%B4%D8'
                    '%AE%D8%B5%DB%8C%D8%AA';
                if (await canLaunch(paymentPageUrl)){
                  try{
                    await launch(paymentPageUrl);
                  }
                  catch(e){
                    print(e.toString());
                  }
                }
              },
              child: Card(
                color: Color(0xFF403F44),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                                'assets/images/16personalities.png'),
                          )),
                      Expanded(
                        flex: 6,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8,0,8,0),
                            child: Text(
                              'تست روانشناسی 16 شخصیت',
                              style: TextStyle(fontSize: 19),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () async{
                String paymentPageUrl = 'https://www.16personalities'
                    '.com/fa/%D8%A2%D8%B2%D9%85%D9%88%D9%86-%D8%B4%D8'
                    '%AE%D8%B5%DB%8C%D8%AA';
                if (await canLaunch(paymentPageUrl)){
                  try{
                    await launch(paymentPageUrl);
                  }
                  catch(e){
                    print(e.toString());
                  }
                }
              },
              child: Card(
                color: Color(0xFF403F44),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                                'assets/images/16personalities.png'),
                          )),
                      Expanded(
                        flex: 6,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8,0,8,0),
                            child: Text(
                              'تست روانشناسی 16 شخصیت',
                              style: TextStyle(fontSize: 19),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
