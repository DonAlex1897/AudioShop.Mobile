import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/screens/start_page.dart';
import 'package:mobile/store/course_store.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xFF202028),
    statusBarIconBrightness: Brightness.light,
  ));
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
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Color(0xFF34333A),
          accentColor: Color(0xFF20BFA9),
          //cardColor: Color(0xFF403F44),
          textTheme: TextTheme(
            bodyText2: TextStyle(color: Colors.white),
            bodyText1: TextStyle(color: Colors.white),
          ),
        ),
        home: StartPage(), //HomePage.basic(),
      ),
    ),
  );
}
