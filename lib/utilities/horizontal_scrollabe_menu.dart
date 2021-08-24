import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HorizontalScrollableMenu extends StatefulWidget {
  final List<String> buttonNameList;
  final List<Future<void> Function()> buttonFunctionList;

  HorizontalScrollableMenu(this.buttonNameList, this.buttonFunctionList);

  @override
  _HorizontalScrollableMenuState createState() =>
      _HorizontalScrollableMenuState();
}

class _HorizontalScrollableMenuState extends State<HorizontalScrollableMenu> {
  List<Color> colorList = [
    Colors.redAccent[200],
    Colors.blueAccent[200],
    Colors.greenAccent[200],
    Colors.purpleAccent[100],
    Colors.pinkAccent[200],
    Colors.amberAccent[700],
    Colors.grey[600]
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.buttonNameList.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ArgonButton(
                height: 40,
                width: 130,
                borderRadius: 5.0,
                loader: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SpinKitRing(
                    color: Colors.white,
                    lineWidth: 4,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorList[index],
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Text(
                        widget.buttonNameList[index],
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                onTap: (startLoading, stopLoading, btnState) async {
                  startLoading();
                  await widget.buttonFunctionList[index]();
                  stopLoading();
                },
              ),
            );
          }),
    );
  }
}
