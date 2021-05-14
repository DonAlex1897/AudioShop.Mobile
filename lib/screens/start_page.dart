import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/screens/home_page.dart';
import 'package:mobile/screens/intro_page.dart';
import 'package:mobile/screens/update_page.dart';
import 'package:mobile/services/global_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:package_info/package_info.dart';
import 'package:async/async.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  String isFirstTime;
  PackageInfo info;
  String currentVersion;
  GlobalService globalService = GlobalService();
  String availableVersion;
  Duration _timerDuration = new Duration(seconds: 5);
  bool isTakingMuchTime = false;
  bool shouldRetry = false;

  navigateToNextPage(){
    UpdateStatus updateStatus = getUpdateStatus();
    if(availableVersion != null && updateStatus != UpdateStatus.UpToDate) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return UpdatePage(availableVersion, updateStatus, currentVersion);
      }));
      return;
    }
    else if(isFirstTime == null || isFirstTime.toLowerCase() == 'true'){
      // return IntroPage();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return IntroPage(currentVersion);
      }));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HomePage(currentVersion);
    }));
  }

  UpdateStatus getUpdateStatus(){
    List<String> currentVersionParts = currentVersion.split('.');
    List<String> availableVersionParts = availableVersion.split('.');
    int currentVersionMajorPart = int.parse(currentVersionParts[0]);
    int currentVersionMinorPart = int.parse(currentVersionParts[1]);
    int currentVersionPatchPart = int.parse(currentVersionParts[2]);
    int availableVersionMajorPart = int.parse(availableVersionParts[0]);
    int availableVersionMinorPart = int.parse(availableVersionParts[1]);
    int availableVersionPatchPart = int.parse(availableVersionParts[2]);

    if(availableVersionMajorPart > currentVersionMajorPart)
      return UpdateStatus.UpdateRequired;
    else if (
    (availableVersionMajorPart == currentVersionMajorPart &&
        availableVersionMinorPart > currentVersionMinorPart) ||
        (availableVersionMajorPart == currentVersionMajorPart &&
            availableVersionMinorPart == currentVersionMinorPart &&
            availableVersionPatchPart > currentVersionPatchPart)
    )
      return UpdateStatus.UpdateAvailable;
    else
      return UpdateStatus.UpToDate;
  }

  @override
  void initState() {
    super.initState();
    startApplication();
  }

  Future startApplication() async {
    // try {
    //   http.Response response = await http.get('https://api.ipregistry.co?key=tryout');
    //   if(response.statusCode == 200 &&
    //      json.decode(response.body)['location']['country']['name']
    //          .toString().toLowerCase() != 'iran'){
    //     Widget cancelB = TextButton(
    //       child: Text('باشه', style: TextStyle(color: Colors.white),),
    //       onPressed: () {
    //         Navigator.of(context).pop();
    //       },
    //     );
    //     Widget continueB = TextButton(
    //       child: Text('بعدا', style: TextStyle(color: Colors.white),),
    //       onPressed: () {
    //         Navigator.of(context).pop();
    //       },
    //     );
    //     AlertDialog alert = AlertDialog(
    //       title: Text('توجه'),
    //       content: Text('لطفا جهت برخورداری از سرعت بیشتر،'
    //           ' فیلترشکن خود را خاموش کنید.'),
    //       actions: [cancelB, continueB],
    //     );
    //     await showDialog(
    //       context: context,
    //       builder: (BuildContext context) {
    //         return alert;
    //       },
    //     );
    //   }
    // } catch (err) {
    //     print(err.toString());
    // }

    const platform = const MethodChannel("audioshoppp.ir.mobile/main");
    await platform.invokeMethod('launchBatch');
    var secureStorage = FlutterSecureStorage();
    isFirstTime = await secureStorage.read(key: 'isFirstTime');
    info = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = info.version;
    });
    RestartableTimer(_timerDuration, setTimerState);
    availableVersion = await globalService.getLatestVersionAvailable();

    if(availableVersion != null)
      navigateToNextPage();
    else
      setState(() {
        shouldRetry = true;
      });
  }
  setTimerState() {
    setState(() {
      isTakingMuchTime = true;
    });
    // checkVpnConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Image.asset(
                        'assets/images/appMainIcon.png',
                        width: MediaQuery.of(context).size.width * 0.2,
                      ),
                    ),
                    Text(
                      'اِستارشو، اپلیکیشن مهارتهای ارتباطی',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'با اِستارشو، ستاره شو',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      child: !isTakingMuchTime ?
                        Text('') :
                        !shouldRetry ?
                          SpinKitWave(
                            type: SpinKitWaveType.center,
                            color: Color(0xFF20BFA9),
                            size: 20.0,
                          ) :
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                            onTap: (){
                              setState(() {
                                isTakingMuchTime = false;
                                shouldRetry = false;
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) => super.widget));
                              });
                            },
                            child: Card(
                              color: Color(0xFF20BFA9),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'تلاش مجدد',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14
                                  ),),
                              ),
                            ),
                        ),
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: currentVersion != null ?
                  Text(
                    'نسخه ' + currentVersion,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70
                    ),
                  ) :
                  Text(
                    '...',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70
                    ),
                  )
                ,
              )
            ],
          ),
        ),
      ),
    );
  }
}
