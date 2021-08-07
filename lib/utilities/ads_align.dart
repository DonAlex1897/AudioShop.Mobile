import 'package:flutter/material.dart';

class AdsAlign extends StatefulWidget {
  @override
  _AdsAlignState createState() => _AdsAlignState();
}

class _AdsAlignState extends State<AdsAlign> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
          color: Colors.white,
          width: 30,
          height: 18,
          child: Padding(
            padding: const EdgeInsets.only(right:4.0),
            child: Text(
              'تبلیغ',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold
              ),),
          )),
    );
  }
}
