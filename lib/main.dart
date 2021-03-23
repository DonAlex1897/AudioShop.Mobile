import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/screens/home_page.dart';
import 'package:mobile/screens/intro_page.dart';
import 'package:mobile/screens/update_page.dart';
import 'package:mobile/services/global_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:mobile/store/course_store.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var secureStorage = FlutterSecureStorage();
  String isFirstTime = await secureStorage.read(key: 'isFirstTime');
  final PackageInfo info = await PackageInfo.fromPlatform();
  String currentVersion = info.version;
  GlobalService globalService = GlobalService();
  String availableVersion = await globalService.getLatestVersionAvailable();

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

  Widget homeWidget(){
    UpdateStatus updateStatus = getUpdateStatus();
    if(availableVersion != null && updateStatus != UpdateStatus.UpToDate)
      return UpdatePage(availableVersion, updateStatus);
    else if(isFirstTime == null || isFirstTime.toLowerCase() == 'true'){
      return IntroPage();
    }
    return HomePage.basic();
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => CourseStore(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('fa', ''),
        ],
        theme: ThemeData(
          fontFamily: 'IranSans',
          primaryColor: Color(0xFF202028),
          scaffoldBackgroundColor: Color(0xFF34333A),
          accentColor: Color(0xFF20BFA9),
          //cardColor: Color(0xFF403F44),
          textTheme: TextTheme(
            bodyText2: TextStyle(color: Colors.white),
            bodyText1: TextStyle(color: Colors.white),
          ),
        ),
        home: homeWidget(), //HomePage.basic(),
      ),
    ),
  );
}
