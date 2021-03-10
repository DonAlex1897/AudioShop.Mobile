import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/services/global_service.dart';

class UpdatePage extends StatefulWidget {
  UpdatePage(this.lastAvailableVersion);
  final int lastAvailableVersion;

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('لطفا جهت عملکرد بهتر نرم افزار، آخرین آپدیت را نصب'
                'کنید.'),
            TextButton(
                onPressed: () async {
                  GlobalService globalService = GlobalService();
                  bool isDownloading = await globalService.downloadLastVersion();
                  if(isDownloading){
                    Fluttertoast.showToast(msg: 'در حال دانلود فایل');
                    SystemNavigator.pop();
                  }
                  else
                    Fluttertoast.showToast(msg: 'مشکل در دانلود فایل.'
                          'لطفا اتصال اینترنت خود را بررسی کنید');
                },
                child: Text('بروز رسانی'))
          ],
        ),
      ),
    );
  }
}
