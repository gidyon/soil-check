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
  List<Map> _steps = [
    {
      "isFirst": true,
      "en":
          'Click \'Start Test\' button below (this will start timer) and immediately place the PAD onto the decanted water sample',
      "title": "Start Timer",
      // "imageUrl": "assets/images/take-photo.jpg"
    },
    {
      "en":
          'Once the timer ends, you will be prompted to take a photo of the PAD and only crop the necessary section',
      "title": "Take Photo",
      // "imageUrl": "assets/images/cropping.jpg"
    },
    {
      "en": 'Upload the Image and you will get AI results',
      "title": "Get Results"
    },
  ];

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
              // Container(
              //   child: Text(
              //     'GUIDE TO SOIL TEST',
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //         color: AppColors.primaryColor,
              //         fontSize: 15,
              //         fontWeight: FontWeight.w600),
              //   ),
              // ),
              // SizedBox(
              //   height: 10,
              // ),
              // Container(
              //   child: ListView.builder(
              //     shrinkWrap: true,
              //     itemCount: _steps.length,
              //     scrollDirection: Axis.vertical,
              //     physics: NeverScrollableScrollPhysics(),
              //     itemBuilder: (context, index) {
              //       return TimelineTile(
              //         alignment: TimelineAlign.manual,
              //         lineXY: 0.005,
              //         isFirst: index == 0,
              //         indicatorStyle: const IndicatorStyle(
              //           width: 20,
              //           color: AppColors.primaryColor,
              //         ),
              //         endChild: _RightChild(
              //           asset: _steps[index]["imageUrl"],
              //           title: '${index + 1}. ${_steps[index]["title"]}',
              //           message: '${_steps[index]["en"]}',
              //         ),
              //         beforeLineStyle: LineStyle(
              //           color: AppColors.primaryColor.withAlpha(50),
              //         ),
              //       );
              //     },
              //   ),
              // ),
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
              // OutlinedButton.icon(
              //   onPressed: () {},
              //   icon: Icon(Icons.label_important_outline_sharp),
              //   label: Text('pH Test'),
              // ),
              // OutlinedButton.icon(
              //   onPressed: () {},
              //   icon: Icon(Icons.label_important_outline_sharp),
              //   label: Text('Phosphate Test'),
              // ),
              // OutlinedButton.icon(
              //   onPressed: () {},
              //   icon: Icon(Icons.label_important_outline_sharp),
              //   label: Text('Nitrate Test'),
              // ),
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
              // Container(
              //   child: FloatingActionButton.extended(
              //     label: Text('Start Test'),
              //     onPressed: () async {
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (BuildContext context) => SoilTestPage()));
              //     },
              //     icon: Icon(Icons.label_important_outline_sharp),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RightChild extends StatelessWidget {
  const _RightChild({
    Key key,
    this.asset,
    this.title,
    this.message,
    this.disabled = false,
  }) : super(key: key);

  final String asset;
  final String title;
  final String message;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withAlpha(50),
        borderRadius: BorderRadiusDirectional.all(Radius.circular(20)),
      ),
      margin: EdgeInsets.only(top: 20),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: disabled
                      ? const Color(0xFFBABABA)
                      : const Color(0xFF636564),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6),
                child: Text(
                  message,
                  style: TextStyle(
                    color: disabled
                        ? const Color(0xFFD5D5D5)
                        : const Color(0xFF636564),
                    fontSize: 16,
                  ),
                ),
              ),
              asset != null
                  ? Image.asset(
                      asset,
                      height: 100,
                    )
                  : SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}
