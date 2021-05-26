import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'package:flutter_app/models/account.dart';
import 'package:flutter_app/services/account.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/views/signin/signup.dart';
import 'package:flutter_app/widgets/logo.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'dart:async';

class OtpScreen extends StatefulWidget {
  final String names;
  final String phone;

  OtpScreen({
    Key key,
    @required this.names,
    @required this.phone,
  }) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpKey = GlobalKey<FormState>();
  var scaffoldState = GlobalKey<ScaffoldState>();

  String otp, error;

  final RoundedLoadingButtonController _signInController =
      new RoundedLoadingButtonController();

  Future<void> _signUpUser() async {
    await AccountServiceSQLite.setAccount(
      Account(
        names: widget.names,
        phone: widget.phone,
        language: "english",
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _signIn();
  }

  String _verificationId;
  int _resendToken;

  Future<void> signInOtp() async {
    _signInController.start();

    if (mounted) {
      _signInController.start();

      FirebaseAuth auth = FirebaseAuth.instance;

      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      await _signUpUser();

      await auth.signInWithCredential(phoneAuthCredential);

      _signInController.success();

      if (mounted) {
        _signInController.reset();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Home(),
          ),
        );
      }
    }
  }

  Future<void> _signIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phone,
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('got verificationCompleted');
          await _signUpUser();
          await auth.signInWithCredential(credential);
          if (mounted) {
            _signInController.reset();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => Home(),
              ),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('fireabse verifaction failed: ${e.message}');
          if (!mounted) {
            print('not mounted but error was: ${e.message}');
            return;
          }
          if (e.code == 'invalid-phone-number') {
            setState(() {
              error = 'The provided phone number is not valid';
            });
          } else {
            setState(() {
              error = e.message;
            });
          }
          _signInController.reset();
        },
        codeSent: (String verificationId, int resendToken) async {
          print('code sent');
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _resendToken = resendToken;
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      _signInController.reset();
      print('got error');
      print(e.toString());
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppLogo(),
              SizedBox(
                height: 40,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Form(
                  key: otpKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      error != null
                          ? Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Text(
                                error,
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : SizedBox(),
                      Container(
                        child: TextFormField(
                          style: TextStyle(color: AppColors.primaryColor),
                          autofocus: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(30),
                              ),
                            ),
                            labelText: "Enter OTP Sent to ${widget.phone}",
                            labelStyle:
                                TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                          validator: (val) {
                            return val.length < 6 || val.length > 6
                                ? 'OTP Code is invalid'
                                : null;
                          },
                          onSaved: (val) async {
                            setState(() {
                              otp = val;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: RoundedLoadingButton(
                          child: Text('Sign In',
                              style: TextStyle(color: Colors.white)),
                          controller: _signInController,
                          onPressed: () async {
                            if (otpKey.currentState.validate()) {
                              setState(() {
                                error = '';
                              });
                              otpKey.currentState.save();
                              await signInOtp();
                            } else {
                              _signInController.reset();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Not ${widget.phone}?'),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        child: Text(
                          'Click Here',
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => SignUpScreen(
                                names: widget.names,
                                phone: widget.phone,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
