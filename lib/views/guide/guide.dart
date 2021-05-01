import 'package:flutter/material.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:timeline_tile/timeline_tile.dart';

class GuidePage extends StatefulWidget {
  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  List<Map> _steps = [
    {
      "isFirst": true,
      "en": 'Take photo or upload image of cafeteire paper',
      "title": "Take/Upload Photo",
      "imageUrl": "assets/images/take-photo.jpg"
    },
    {
      "en": 'Crop the image to capture the desired area',
      "title": "Crop Photo",
      "imageUrl": "assets/images/cropping.jpg"
    },
    {"en": 'Get results and useful recommdendations', "title": "Get Results"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: Text('Guide To Using Soil Check'),
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
              Center(
                child: Text(
                  "This guide is subject to changes",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _steps.length,
                  scrollDirection: Axis.vertical,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return TimelineTile(
                      alignment: TimelineAlign.manual,
                      lineXY: 0.005,
                      isFirst: index == 0,
                      indicatorStyle: const IndicatorStyle(
                        width: 20,
                        color: AppColors.primaryColor,
                      ),
                      endChild: _RightChild(
                        asset: _steps[index]["imageUrl"],
                        title: '${index + 1}. ${_steps[index]["title"]}',
                        message: '${_steps[index]["en"]}',
                      ),
                      beforeLineStyle: LineStyle(
                        color: AppColors.primaryColor.withAlpha(50),
                      ),
                    );
                  },
                ),
              ),
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
