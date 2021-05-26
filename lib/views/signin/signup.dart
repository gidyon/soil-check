import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'package:flutter_app/models/account.dart';
import 'package:flutter_app/services/account.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/utils/helpers.dart';
import 'package:flutter_app/widgets/powered_by.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'dart:async';

class SignUpScreen extends StatefulWidget {
  final String names;
  final String phone;

  const SignUpScreen({Key key, this.names, this.phone}) : super(key: key);
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _signupFormKey = GlobalKey<FormState>();
  var _scaffoldState = GlobalKey<ScaffoldState>();

  final RoundedLoadingButtonController _signUpController =
      new RoundedLoadingButtonController();

  String _phone;
  String _fullNames;
  String _phoneFormated, _error;

  Future<void> _signIn() async {
    if (_signupFormKey.currentState.validate()) {
      try {
        _signupFormKey.currentState.save();

        await AccountServiceV2.setAccount(Account(
          names: _fullNames,
          phone: _phoneFormated,
          language: 'ENGLISH',
        ));

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => OtpScreen(
        //       names: _fullNames,
        //       phone: _phoneFormated,
        //     ),
        //   ),
        // );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Home(),
          ),
        );
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      }
    } else {
      _signUpController.reset();
    }
  }

  @override
  void initState() {
    super.initState();
    _fullNames = widget.names;
    _phone = widget.phone;
  }

  String phoneNumber;
  String phoneIsoCode;
  bool visible = false;
  String confirmedNumber = '';

  void onPhoneNumberChange(
      String number, String internationalizedPhoneNumber, String isoCode) {
    print(number);
    setState(() {
      phoneNumber = number;
      phoneIsoCode = isoCode;
    });
  }

  onValidPhoneNumber(
      String number, String internationalizedPhoneNumber, String isoCode) {
    setState(() {
      visible = true;
      confirmedNumber = internationalizedPhoneNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Form(
                  key: _signupFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            'Provide the following details',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _error != null
                          ? Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Text(
                                _error,
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : SizedBox(),
                      Container(
                        child: TextFormField(
                          initialValue: _fullNames,
                          style: TextStyle(color: AppColors.primaryColor),
                          autofocus: _phone == null || _phone == '',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          maxLength: 18,
                          decoration: InputDecoration(
                            labelText: "Full Names",
                            counterText: '',
                            filled: true,
                            errorStyle: TextStyle(color: Colors.deepOrange),
                            errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepOrange)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            labelStyle:
                                TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                          validator: (val) => val.length < 2
                              ? 'Full names entered invalid'
                              : null,
                          onSaved: (val) => _fullNames = val,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: TextFormField(
                          initialValue: _phone,
                          autofocus: _phone != null && _phone != '',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: AppColors.primaryColor),
                          decoration: InputDecoration(
                            labelText: "Phone Number",
                            filled: true,
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            labelStyle:
                                TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                          validator: (val) {
                            return val.length < 8 || val.length > 13
                                ? 'Phone number entered invalid'
                                : null;
                          },
                          onSaved: (val) {
                            _phoneFormated = Utils.formatPhone(val);
                            if (!_phoneFormated.startsWith('+')) {
                              _phoneFormated = '+$_phoneFormated';
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: RoundedLoadingButton(
                          child: Text('Save Details',
                              style: TextStyle(color: Colors.white)),
                          controller: _signUpController,
                          width: MediaQuery.of(context).size.width,
                          onPressed: () async {
                            await _signIn();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              PoweredBy()
            ],
          ),
        ),
      ),
    );
  }
}
