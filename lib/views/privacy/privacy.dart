import 'package:flutter/material.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/views/signin/signup.dart';
import 'package:flutter_app/widgets/defaultappbar.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyPage extends StatefulWidget {
  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  final RoundedLoadingButtonController _agreeController =
      new RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    var titleStyle = TextStyle(
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w900,
      fontSize: 16,
    );
    return Scaffold(
      appBar: DefaultAppBar.createAppBar(
        context,
        'Privacy Statement',
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'Data Collection',
              style: titleStyle,
            ),
            Flexible(
              child: Text(
                'Farm/Homestead name and soil test results is collected for the purposes of model training and performing wider soil analysis and tagging.W\nPhone Number upon registration, is also collected for the purpose of communication.',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Device Location',
              style: titleStyle,
            ),
            Flexible(
              child: Text(
                'The location of the farm where the test is conducted is collected for the sole purpose of zonal/regional soil analysis and tagging.',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Flexible(
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        style: Theme.of(context).textTheme.bodyText1,
                        text:
                            'To Continue, please indicate your acceptance of the '),
                    TextSpan(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        text: 'Privacy Statement'),
                    TextSpan(
                        style: Theme.of(context).textTheme.bodyText1,
                        text: ' by clicking on the button below.'),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                child: Center(
              child: Column(
                children: [
                  RoundedLoadingButton(
                    child:
                        Text('I Agree', style: TextStyle(color: Colors.white)),
                    controller: _agreeController,
                    onPressed: () async {
                      _agreeController.start();

                      var sp = await SharedPreferences.getInstance();

                      await sp.setBool('agreedToPrivacy', true);

                      _agreeController.reset();

                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 300),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            animation = CurvedAnimation(
                                parent: animation, curve: Curves.easeIn);
                            return ScaleTransition(
                                scale: animation,
                                alignment: Alignment.center,
                                child: child);
                          },
                          pageBuilder: (BuildContext context,
                              Animation<double> animation,
                              Animation<double> animationSec) {
                            return SignUpScreen();
                          },
                        ),
                      );
                    },
                    width: 200,
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
