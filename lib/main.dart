import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/screens/home_page.dart';
import 'package:mobile/screens/intro_page.dart';
import 'package:mobile/screens/update_page.dart';
import 'package:mobile/services/global_service.dart';
import 'package:mobile/store/course_store.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var secureStorage = FlutterSecureStorage();
  String isFirstTime = await secureStorage.read(key: 'isFirstTime');
  final PackageInfo info = await PackageInfo.fromPlatform();
  bool isUpdateAvailable = false;
  String currentVersion = info.version;
  GlobalService globalService = GlobalService();
  int availableVersion = await globalService.getLatestVersionAvailable();
  if(availableVersion > int.parse(currentVersion.replaceAll(new RegExp(r'[^0-9]'),'')))
    isUpdateAvailable = true;

  Widget homeWidget(){
    if(isUpdateAvailable)
      return UpdatePage(availableVersion);
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
