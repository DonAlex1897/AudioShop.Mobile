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
      appBar: AppBar(
        leading: IconButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios)
        ),
        title: Text('تست های روانشناسی'),
      ),
      body: SafeArea(
        // child: Center(
        //   child: Text(
        //     'این قسمت به زودی بارگذاری خواهد شد ',
        //     textAlign: TextAlign.justify,
        //     style: TextStyle(fontSize: 25),),
        // ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8,0,8,0),
                  child: TextButton(
                    onPressed: () async{
                      String paymentPageUrl = 'https://bit.ly/test_afsordegii';
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
                                      'assets/images/depression.jpg'),
                                )),
                            Expanded(
                              flex: 6,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                  child: Text(
                                    'افسردگی',
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
                ),
                TextButton(
                  onPressed: () async{
                    String paymentPageUrl = 'bit.ly/jazzabiyaat';
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
                                    'assets/images/charm.jpg'),
                              )),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                child: Text(
                                  'شخصیت و جذابیت',
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
                    String paymentPageUrl = 'http://bit.ly/gorbe-shenasi';
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
                                    'assets/images/catology.jpg'),
                              )),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                child: Text(
                                  'گربه شناسی',
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
                    String paymentPageUrl = 'http://bit.ly/cinema244';
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
                                    'assets/images/cinemalogy.jpg'),
                              )),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                child: Text(
                                  'سینما شناسی',
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
                    String paymentPageUrl = 'http://bit.ly/shakhsiyaat20';
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
                                    'assets/images/mierz.png'),
                              )),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                child: Text(
                                  'شخصیت شناسی مایرز-بریگز',
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
                    String paymentPageUrl = 'http://bit.ly/net2005';
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
                                    'assets/images/netaddiction.jpg'),
                              )),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                child: Text(
                                  'اعتیاد به اینترنت',
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
                    String paymentPageUrl = 'http://bit.ly/RezayatShoghli';
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
                                    'assets/images/jobsatisfaction.jpg'),
                              )),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                child: Text(
                                  'رضایت شغلی',
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
                    String paymentPageUrl = 'http://bit.ly/sexologyTest';
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
                                    'assets/images/sexual.jpg'),
                              )),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                child: Text(
                                  'شدت و رضایت "جنسی"',
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
                    String paymentPageUrl = 'http://bit.ly/heyvan-daroon';
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
                                    'assets/images/insideanimal.jpg'),
                              )),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                child: Text(
                                  'حیوان درون',
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
                    String paymentPageUrl = 'http://bit.ly/hayajan20';
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
                                    'assets/images/exitement.jpg'),
                              )),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                child: Text(
                                  'هیجان طلبی',
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
                    String paymentPageUrl = 'http://bit.ly/sarnevesht1';
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
                                    'assets/images/destiny.jpg'),
                              )),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                child: Text(
                                  'سرنوشت',
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
                    String paymentPageUrl = 'http://bit.ly/koodak-daroon';
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
                                    'assets/images/insidechild.jpg'),
                              )),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8,0,8,0),
                                child: Text(
                                  'کودک درون',
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
        ),
      ),
    );
  }
}
