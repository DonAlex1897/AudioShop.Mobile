import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ads_align.dart';

class BannerAds extends StatefulWidget {
  @override
  _BannerAdsState createState() => _BannerAdsState();
}

class _BannerAdsState extends State<BannerAds> {
  bool justPicture = false;
  double width = 0;
  String adURL = 'https://filesamples.com/samples/video/mov/sample_640x360.mov'; //'https://file-examples-com.github.io/uploads/2018/04/file_example_MOV_480_700kB.mov'; //'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4';
  String tempURL = 'https://www.kolpaper.com/wp-content/uploads/2021/02/Juve-Stadium-Wallpaper.jpg';
  String redirectURL = 'https://www.kolpaper.com/wp-content/uploads/2021/02/Juve-Stadium-Wallpaper.jpg';//'https://www.dl.farsroid.com/ap/HiPER-Calc-Pro-8.3.8(www.farsroid.com).apk';


  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return !justPicture ?
    Stack(
        children: [
          Container(
            color: Colors.black26,
            height: 80,
            width: width,
            child: InkWell(
              onTap: () async {
                try{
                  await launch(redirectURL);
                }
                catch(e){
                  print(e.toString());
                }
              },
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'میخوای یاد بگیری چجوری توی سریع ترین زمان ممکن '
                          'کسب درآمد کنی؟ کانال استارشو رو دنبال کن.' ,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 14
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF20BFA9),
                          image: DecorationImage(
                            image: NetworkImage(tempURL),
                            fit: BoxFit.cover,
                          )
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          AdsAlign(),
        ]
    ) :
    Stack(
        children: [
          Container(
              height: 60,
              width: width,
              child: Image.network(tempURL, fit: BoxFit.cover,)
          ),
          AdsAlign(),
        ]
    );
  }
}
