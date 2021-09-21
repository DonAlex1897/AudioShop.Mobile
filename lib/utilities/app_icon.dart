import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          // decoration: BoxDecoration(
          //   shape: BoxShape.circle,
          //   border: Border.all(
          //     color: Colors.white,
          //     width: 2,
          //   ),
          // ),
          child: Stack(
            children:[
              Positioned(
                top: width * 0.1,
                right: width * 0.29,
                child: Container(
                  width: width * 0.35,
                  height: width * 0.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage('assets/images/appMainIcon.png'),
                        fit: BoxFit.fill),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: width * 0.55,
                  height: width * 0.55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage('assets/images/circle2.png'),
                        fit: BoxFit.fill),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
