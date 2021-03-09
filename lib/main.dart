import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/screens/home_page.dart';
import 'package:mobile/screens/intro_page.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var secureStorage = FlutterSecureStorage();
  String isFirstTime = await secureStorage.read(key: 'isFirstTime');
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
        home: (isFirstTime == null || isFirstTime.toLowerCase() == 'false') ?
          IntroPage() : HomePage.basic()
        , //HomePage.basic(),
      ),
    ),
  );
}
