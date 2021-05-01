import 'package:flutter/material.dart';
import 'package:flutter_app/models/account.dart';
import 'package:flutter_app/services/account_sqlite.dart';
import 'package:flutter_app/views/about/about.dart';
import 'package:flutter_app/views/guide/guide.dart';
import 'package:flutter_app/views/newtest/test.dart';
import 'package:flutter_app/widgets/logo.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Future<Account> _accountFuture = AccountServiceSQLite.getAccount();

  @override
  Widget build(BuildContext context) {
    // FirebaseAuth.instance.signOut();
    return Center(
      child: SingleChildScrollView(
        child: FutureBuilder<Account>(
          future: _accountFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Account account = snapshot.data;
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
                        'Welcome ${account.names ?? 'to Soil Check'}',
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
      heroTag: UniqueKey(),
      onPressed: () {
        if (id == "guide") {
          // Navigate to guide
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => GuidePage()));
          return;
        }
        if (id == "test") {
          // Navigate to test
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => SoilTestPage()));
          return;
        }
        if (id == "about") {
          // Navigate to about
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AboutPage()));
          return;
        }
      },
      // icon: Icon(Icons.photo_library),
    );
  }
}
