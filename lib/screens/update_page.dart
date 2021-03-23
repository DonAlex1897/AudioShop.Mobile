import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/screens/home_page.dart';
import 'package:mobile/services/global_service.dart';
import 'package:mobile/shared/enums.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatefulWidget {
  UpdatePage(this.lastAvailableVersion, this.updateStatus);
  final String lastAvailableVersion;
  final UpdateStatus updateStatus;

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/update.png'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 65),
              child: Text(
                ' لطفا جهت عملکرد بهتر نرم افزار، آخرین آپدیت را نصب '
                  'کنید.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    color: Color(0xFF20BFA9),
                    child: Padding(
                      padding: const EdgeInsets.only(left:15, right: 15),
                      child: TextButton(
                        onPressed: () async {
                          GlobalService globalService = GlobalService();
                          String downloadUrl = await globalService.getDownloadUrl();
                          if (await canLaunch(downloadUrl)){
                            try{
                              await launch(downloadUrl);
                            }
                            catch(e){
                              print(e.toString());
                            }
                            finally{
                              SystemNavigator.pop();
                            }
                          }
                          else
                            Fluttertoast.showToast(msg: 'مشکل در دانلود فایل.'
                                'لطفا اتصال اینترنت خود را بررسی کنید');
                        },
                        child: Text(
                          'بروز رسانی',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  widget.updateStatus == UpdateStatus.UpdateAvailable ?
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(left:15, right: 15),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context){
                                  return HomePage.basic();
                                })
                            );
                          },
                          child: Text(
                            'بعدا',
                            style: TextStyle(color: Color(0xFF20BFA9)),
                          ),
                        ),
                      ),
                    ) :
                    SizedBox(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
