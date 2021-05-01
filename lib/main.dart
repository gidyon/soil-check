import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/views/signin/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soil Check',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        backgroundColor: AppColors.whiteColor,
        fontFamily: 'Nunito',
      ),
      home: Landing(title: 'Flutter Demo Landing Page'),
    );
  }
}

class Landing extends StatefulWidget {
  Landing({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        print('user changes');
        if (snapshot.connectionState == ConnectionState.active) {
          User user = snapshot.data;
          if (user == null) {
            print('usrr null');
            return SignUpScreen();
          }
          print('usrr nnot ull');

          return Home();
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
