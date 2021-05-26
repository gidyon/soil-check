import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'package:flutter_app/views/about/about.dart';
import 'package:flutter_app/views/guide/guide.dart';
import 'package:flutter_app/views/healthstatment/statement.dart';
import 'package:flutter_app/widgets/logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<bool> readHealthStatement;
  bool shown = false;

  static Future<bool> _readHealthStatement() async {
    var sp = await SharedPreferences.getInstance();
    try {
      var b = sp.getBool('readHealthStatement');
      return b ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    readHealthStatement = _readHealthStatement();
  }

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(HealthStatementOverlay());
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: FutureBuilder<bool>(
          future: readHealthStatement,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var read = snapshot.data;
              if (!read) {
                if (!shown) {
                  Future.delayed(Duration(milliseconds: 100), () {
                    setState(() {
                      shown = true;
                    });
                    _showOverlay(context);
                  });
                }
              }

              return Container(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    AppLogo(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        'Welcome To Soil Check',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      alignment: Alignment.center,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: _buildButtonLink('READ GUIDE', 'guide'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: _buildButtonLink('ABOUT SOILCHECK', 'about'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: _buildButtonLink('NEW TEST', 'test'),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Container(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    )
                  ],
                ),
              );
            } else {
              return SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildButtonLink(String label, String id) {
    // return OutlinedButton(
    //   onPressed: () {},
    //   child: Text(label),
    //   style: OutlinedButton.styleFrom(),
    // );
    return FloatingActionButton.extended(
      label: Text(label),
      heroTag: label,
      onPressed: () async {
        if (id == "guide") {
          // Navigate to guide
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => GuidePage(),
            ),
          );
          return;
        }
        if (id == "test") {
          // Navigate to test
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Home(
                initialPage: 1,
              ),
            ),
          );
          return;
        }
        if (id == "about") {
          // Navigate to about
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => AboutPage(),
            ),
          );
          return;
        }
      },
      // icon: Icon(Icons.photo_library),
    );
  }
}

class HealthStatementOverlay extends ModalRoute<void> {
  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.65);

  @override
  String get barrierLabel => 'Health Statement';

  @override
  bool get maintainState => true;

  @override
  void changedInternalState() {
    super.changedInternalState();
  }

  bool _showUserAppButton = false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black54,
          body: Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 150,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Flexible(
                    child: Text(
                      'To use this app you must first agree to the health and safety statement',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            HealthStatementPage(),
                      ),
                    ),
                    child: Text(
                      'READ STATEMENT',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // background
                      onPrimary: Colors.white, // foreground
                      padding: EdgeInsets.all(10),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Flexible(
                    child: Text(
                      'Tap the tick below to confirm you agree',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      _showUserAppButton = true;
                      changedExternalState();
                    },
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 100,
                      color: _showUserAppButton ? Colors.green : Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _showUserAppButton
                      ? Container(
                          child: ElevatedButton(
                            onPressed: () async {
                              var sp = await SharedPreferences.getInstance();
                              await sp.setBool('readHealthStatement', true);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'USE SOIL CHECK',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green, // background
                              onPrimary: Colors.white, // foreground
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
