import 'package:flutter/material.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/widgets/logo.dart';
import 'package:flutter_app/widgets/powered_by.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: Text('About Soil Check'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppLogo(),
              Center(
                child: Container(
                  child: Text(
                      'Soil Check is a mobile application developed to assist farmers in interpreting soil test results using cafeterier method. The app uses Machine Learning models to interpret the result. This means that farmers will get results and recommendations almost instant after conducting the test. Our mission is to improve farm productivity to farmers who lack access to soil information.'),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Center(child: PoweredBy()),
            ],
          ),
        ),
      ),
    );
  }
}
