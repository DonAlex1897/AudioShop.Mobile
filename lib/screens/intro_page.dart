import 'package:flutter/material.dart';
import 'package:intro_slider/dot_animation_enum.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:mobile/screens/home_page.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  List<Slide> slides = new List();

  Function goToTab;

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "روابط اجتماعی",
        styleTitle: TextStyle(
            color: Color(0xff3da4ab),
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'IranSans'),
        description:
        "سلام به نرم افزار اموزشی ما خوش امدید. "
            "این برنامه جهت افزایش مهارت و توانمندی شما"
            " در روابط اجتماعی و ارتباط با جنس مخالف تهیه شده است.",
        styleDescription: TextStyle(
            color: Color(0xFF20BFA9),
            fontSize: 20.0,
            //fontStyle: FontStyle.italic,
            fontFamily: 'IranSans'),
        pathImage: "assets/images/1.jpg",
      ),
    );
    slides.add(
      new Slide(
        title: "آموزش رایگان",
        styleTitle: TextStyle(
            color: Color(0xff3da4ab),
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'IranSans'),
        description:
        "محتوای آموزشی برای شما رایگان خواهد بود"
            " و منبع درآمد ما از تبلیغاتی ست که در محیط برنامه"
            " برای شما نمایش داده می شود، با مشاهده هر چه بیشتر"
            " تبلیغات، ما را حمایت کنید و انگیزه ای باشید برای ما"
            " تا محتوای آموزشی رایگان بیشتری برای شما تهیه کنیم.",
        styleDescription: TextStyle(
            color: Color(0xFF20BFA9),
            fontSize: 20.0,
            //fontStyle: FontStyle.italic,
            fontFamily: 'IranSans'),
        pathImage: "assets/images/2.jpg",
      ),
    );
    slides.add(
      new Slide(
        title: "فضای مجازی",
        styleTitle: TextStyle(
            color: Color(0xff3da4ab),
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'IranSans'),
        description:
        "تمام دوره های آموزشی با متد های روز دنیا تهیه"
            " شده و شما با دنبال کردن بخش های مختلف و تمرین"
            " تکنیک های ارائه شده،  میتوانید استاد برقراری"
            " ارتباط در فضای مجازی و حقیقی شوید .",
        styleDescription: TextStyle(
            color: Color(0xFF20BFA9),
            fontSize: 20.0,
            //fontStyle: FontStyle.italic,
            fontFamily: 'IranSans'),
        pathImage: "assets/images/3.jpg",
      ),
    );
    slides.add(
      new Slide(
        title: "با ما باشید",
        styleTitle: TextStyle(
            color: Color(0xff3da4ab),
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'IranSans'),
        description:
        "دوره های آموزشی که در حال حاضر مشاهده می کنید"
            " بخش کوچکی از محتوای اصلی برنامه است که به مرور"
            " زمان و در بروز رسانی های بعدی قرار داده خواهد شد. "
            "حمایت شما انگیزه بخش ادامه این مسیر خواهد بود.",
        styleDescription: TextStyle(
            color: Color(0xFF20BFA9),
            fontSize: 20.0,
            //fontStyle: FontStyle.italic,
            fontFamily: 'IranSans'),
        pathImage: "assets/images/4.jpg",
      ),
    );
  }

  void onDonePress() {
    // Back to the first tab
    // this.goToTab(0);
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return HomePage.basic();
    }));
  }

  void onTabChangeCompleted(index) {
    // Index of current tab is focused
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: Color(0xFF20BFA9),
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: Color(0xFF20BFA9),
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: Color(0xFF20BFA9),
    );
  }

  List<Widget> renderListCustomTabs() {
    List<Widget> tabs = new List();
    for (int i = 0; i < slides.length; i++) {
      Slide currentSlide = slides[i];
      tabs.add(Container(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          margin: EdgeInsets.only(bottom: 60.0, top: 60.0),
          child: ListView(
            children: <Widget>[
              GestureDetector(
                  child: Image.asset(
                    currentSlide.pathImage,
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.contain,
                  )),
              Container(
                child: Text(
                  currentSlide.title,
                  style: currentSlide.styleTitle,
                  textAlign: TextAlign.center,
                ),
                margin: EdgeInsets.only(top: 20.0),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    currentSlide.description,
                    style: currentSlide.styleDescription,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                margin: EdgeInsets.only(top: 20.0),
              ),
            ],
          ),
        ),
      ));
    }
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      // List slides
      // slides: this.slides,

      // Skip button
      renderSkipBtn: this.renderSkipBtn(),
      colorSkipBtn: Color(0x33ffcc5c),
      highlightColorSkipBtn:  Color(0xff3da4ab),

      // Next button
      renderNextBtn: this.renderNextBtn(),

      // Done button
      renderDoneBtn: this.renderDoneBtn(),
      onDonePress: this.onDonePress,
      colorDoneBtn: Color(0x33ffcc5c),
      highlightColorDoneBtn:  Color(0xff3da4ab),

      // Dot indicator
      colorDot: Color(0xff3da4ab),
      sizeDot: 13.0,
      typeDotAnimation: dotSliderAnimation.SIZE_TRANSITION,

      // Tabs
      listCustomTabs: this.renderListCustomTabs(),
      backgroundColorAllSlides: Colors.white,
      refFuncGoToTab: (refFunc) {
        this.goToTab = refFunc;
      },

      // Behavior
      scrollPhysics: BouncingScrollPhysics(),

      // Show or hide status bar
      shouldHideStatusBar: true,

      // On tab change completed
      onTabChangeCompleted: this.onTabChangeCompleted,
    );
  }
}
