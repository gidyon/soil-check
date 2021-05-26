import 'package:flutter/material.dart';
import 'package:flutter_app/views/privacy/privacy.dart';
import 'package:flutter_app/widgets/logo.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    TextStyle linkStyle = themeData.textTheme.bodyText1.copyWith(
      // color: Colors.black,
      fontSize: 12,
    );

    return Container(
        padding: EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              child: Padding(padding: EdgeInsets.all(20), child: AppLogo()),
              minRadius: 10,
              backgroundColor: Colors.white,
              maxRadius: 90,
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Welcome to SoilCheck',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Flexible(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        style: linkStyle,
                        text:
                            'App that will helps farmers and researchers analyze soil nutrients using '),
                    TextSpan(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        text: 'Cafeteire Method'),
                    TextSpan(
                        style: linkStyle,
                        text: ' and give out recommendations'),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            FloatingActionButton.extended(
              label: Text('Get Started'),
              onPressed: () {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        transitionDuration: Duration(seconds: 1),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          animation = CurvedAnimation(
                              parent: animation, curve: Curves.bounceOut);
                          return ScaleTransition(
                              scale: animation,
                              alignment: Alignment.center,
                              child: child);
                        },
                        pageBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> animationSec) {
                          return PrivacyPage();
                        }));
                // MaterialPageRoute(
                //     builder: (BuildContext context) => PrivacyPage()));
              },
            )
          ],
        ));
  }
}
