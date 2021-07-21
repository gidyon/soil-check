import 'package:flutter/material.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/views/guide/guide.dart';
import 'package:flutter_app/views/newtest/test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewTest extends StatefulWidget {
  @override
  _NewTestState createState() => _NewTestState();
}

class _NewTestState extends State<NewTest> {
  // List<Map> _steps = [
  //   {
  //     "isFirst": true,
  //     "en":
  //         'Click \'Start Test\' button below (this will start timer) and immediately place the PAD onto the decanted water sample',
  //     "title": "Start Timer",
  //     // "imageUrl": "assets/images/take-photo.jpg"
  //   },
  //   {
  //     "en":
  //         'Once the timer ends, you will be prompted to take a photo of the PAD and only crop the necessary section',
  //     "title": "Take Photo",
  //     // "imageUrl": "assets/images/cropping.jpg"
  //   },
  //   {
  //     "en": 'Upload the Image and you will get AI results',
  //     "title": "Get Results"
  //   },
  // ];

  _updateTestType(String testType) async {
    var sp = await SharedPreferences.getInstance();
    sp.setString("test_type", testType);
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => SoilTestPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                child: OutlinedButton.icon(
                  label: Text('Read Full Guide'),
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => GuidePage()));
                  },
                  icon: Icon(Icons.menu_book_sharp),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'SELECT TEST TO CONTINUE',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: FloatingActionButton.extended(
                  heroTag: 'ph',
                  label: Text('pH Test'),
                  onPressed: () async {
                    await _updateTestType("ph");
                  },
                  icon: Icon(Icons.label_important_outline_sharp),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: FloatingActionButton.extended(
                  heroTag: 'nitrate',
                  label: Text('Nitrate Test'),
                  onPressed: () async {
                    await _updateTestType("nitrate");
                  },
                  icon: Icon(Icons.label_important_outline_sharp),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: FloatingActionButton.extended(
                  heroTag: 'phosphate',
                  label: Text('Phosphate Test'),
                  onPressed: () async {
                    await _updateTestType("phosphate");
                  },
                  icon: Icon(Icons.label_important_outline_sharp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
