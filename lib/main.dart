import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:payza/web_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class App extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
//     );
//
//     return MaterialApp(
//       title: 'Introduction screen',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.deepPurple),
//       home: OnBoardingPage(),
//     );
//   }
// }

void main() => runApp(MaterialApp(home: OnBoardingPage()));

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  @override
  Future initState() {
    super.initState();
    _routeCheckerToHome();
  }

  Future <void> _routeCheckerToHome() async {
//    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    //Check then Navigate to Onboarding
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      if (prefs.containsKey('firstTime')) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => WebViewExample()));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstTime', false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => WebViewExample()),
    );
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/$assetName.jpg', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.white),
    );

    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return SafeArea(
      child: IntroductionScreen(
        key: introKey,
        pages: [
          PageViewModel(
            title: "Pay for Electricity",
            body:
            "It takes 60 seconds to Recharge your Prepaid and Postpaid Electricity Meters in Nigeria conveniently.",
            image: _buildImage('img1'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Recharge Cable Tv",
            body:
            "Instantly Recharge your GoTv, DStv & Startimes online on PayPaddi and avoid waiting in the queues.",
            image: _buildImage('img2'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Airtime & Data",
            body:
            "It's now easier to make purchases for Airtime & Data on all your Nigerian network Numbers.",
            image: _buildImage('img3'),
            decoration: pageDecoration,
          ),

          // PageViewModel(
          //   title: "Another title page",
          //   body: "Another beautiful body text for this example onboarding",
          //   image: _buildImage('img2'),
          //   footer: RaisedButton(
          //     onPressed: () {
          //       introKey.currentState?.animateScroll(0);
          //     },
          //     child: const Text(
          //       'FooButton',
          //       style: TextStyle(color: Colors.white),
          //     ),
          //     color: Colors.lightBlue,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8.0),
          //     ),
          //   ),
          //   decoration: pageDecoration,
          // ),
          // PageViewModel(
          //   title: "Title of last page",
          //   bodyWidget: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: const [
          //       Text("Click on ", style: bodyStyle),
          //       Icon(Icons.edit),
          //       Text(" to edit a post", style: bodyStyle),
          //     ],
          //   ),
          //   image: _buildImage('img1'),
          //   decoration: pageDecoration,
          // ),
        ],
        onDone: () => _onIntroEnd(context),
        onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        showSkipButton: true,
        skipFlex: 0,
        nextFlex: 0,
        skip: const Text('Skip'),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Color(0xFFBDBDBD),
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      ),
    );
  }
}
