import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/emptyappbar.dart';

import 'about.dart';

class InitScreen extends StatefulWidget {
  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  final controller = PageController(
    initialPage: 0,
  );
  @override
  Widget build(BuildContext context) {
    // FirebaseAuth.instance.signOut();
    return Scaffold(
      appBar: EmptyAppBar(),
      // backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: PageView(
          controller: controller,
          children: <Widget>[
            WelcomePage(),
            // Container(
            //   color: Colors.cyan,
            //   child: Text('Hello Am Cyan'),
            // ),
            // Container(
            //   color: Colors.deepPurple,
            //   child: Text('Hello Am deepPurple'),
            // ),
          ],
          physics: BouncingScrollPhysics(),
        ),
      ),
    );
  }
}
