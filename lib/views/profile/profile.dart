import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/account.dart';
import 'package:flutter_app/services/account.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/views/signin/signup.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Future<Account> _account = AccountServiceV2.getAccount();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: FutureBuilder<Account>(
          future: _account,
          builder: (context, snapshot) {
            Account account = snapshot.data;
            if (snapshot.hasData) {
              return _loading
                  ? SizedBox(
                      child: CircularProgressIndicator(),
                      width: 60,
                      height: 60,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 100.0, // soften the shadow
                            spreadRadius: 1.0, //extend the shadow
                            offset: Offset(
                              2.0, // Move to right 10  horizontally
                              2.0, // Move to bottom 10 Vertically
                            ),
                          )
                        ],
                      ),
                      padding: EdgeInsets.all(40),
                      margin: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Container(
                              child: ImageIcon(
                            AssetImage('assets/images/farmer-icon-2.png'),
                            color: AppColors.primaryColor,
                            size: 80,
                          )),
                          // Container(
                          //   child: Image.asset(
                          //     'assets/images/farmer-icon-2.png',
                          //     color: Colors.white,
                          //   ),
                          // ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              '${account.names}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            alignment: Alignment.center,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              '${account.phone}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            alignment: Alignment.center,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _loading = true;
                                });
                                FirebaseAuth.instance.signOut();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        SignUpScreen(
                                      phone: account.phone,
                                      names: account.names,
                                    ),
                                  ),
                                );
                              },
                              child: Text('Edit'),
                              style: OutlinedButton.styleFrom(),
                            ),
                          )
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
}
