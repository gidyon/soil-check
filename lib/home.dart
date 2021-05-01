import 'package:flutter/material.dart';
import 'package:flutter_app/views/home/home.dart';
import 'package:flutter_app/views/newtest/newtest.dart';
import 'package:flutter_app/views/profile/profile.dart';
import 'package:flutter_app/views/results/results.dart';
import 'package:flutter_app/widgets/language.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomeScreen(),
    NewTest(),
    ResultsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LanguageSelection(),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex:
              _currentIndex, // this will be set when a new tab is tapped
          type: BottomNavigationBarType.fixed,
          onTap: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.camera_enhance),
              label: 'New Test',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Results',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/images/farmer-icon-2.png'),
              ),
              label: 'Profile',
            )
          ],
        ),
        body: _children[_currentIndex]);
  }
}
