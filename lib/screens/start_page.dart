import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/screens/home_page.dart';
import 'package:mobile/screens/intro_page.dart';
import 'package:mobile/screens/update_page.dart';
import 'package:mobile/services/global_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:package_info/package_info.dart';

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

  navigateToNextPage(){
    UpdateStatus updateStatus = getUpdateStatus();
    if(availableVersion != null && updateStatus != UpdateStatus.UpToDate) {
      // return UpdatePage(availableVersion, updateStatus);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return UpdatePage(availableVersion, updateStatus, currentVersion);
      }));
    }
    else if(isFirstTime == null || isFirstTime.toLowerCase() == 'true'){
      // return IntroPage();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return IntroPage(currentVersion);
      }));
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HomePage(currentVersion);
    }));
    // return HomePage.basic();
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
    const platform = const MethodChannel("audioshoppp.ir.mobile/main");
    await platform.invokeMethod('launchBatch');
    var secureStorage = FlutterSecureStorage();
    isFirstTime = await secureStorage.read(key: 'isFirstTime');
    info = await PackageInfo.fromPlatform();
    currentVersion = info.version;
    availableVersion = await globalService.getLatestVersionAvailable();

    navigateToNextPage();
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
                      'اِستارشو',
                      style: TextStyle(fontSize: 18),
                    )
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
