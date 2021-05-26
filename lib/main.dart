import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/views/init/page_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  Future<bool> _agreedToPrivacy() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var b = sp.getBool('agreedToPrivacy');
      return b == true;
    } catch (e) {}
    return false;
  }

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
      home: FutureBuilder<bool>(
        future: _agreedToPrivacy(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data) {
              return Home();
            } else {
              return InitScreen();
            }
          } else if (snapshot.hasError) {
            return InitScreen();
          } else {
            return SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            );
          }
        },
      ),
    );
  }
}
