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
      "title": "Select Test Type",
      "imageUrl": "assets/images/take-photo.jpg",
      "steps": {
        "en": [
          {
            "text": "Either pH / phosphate / nitratee",
          },
          {
            "text": "Each option then triggers a different set of instructions",
          }
        ]
      },
    },
    {
      "isFirst": true,
      "title": "Cafetiere step",
      "imageUrl": "assets/images/take-photo.jpg",
      "steps": {
        "en": [
          {
            "text": "Add soil, then add water and mix within the cafetiere",
            "image": "assets/images/take-photo.jpg",
          },
          {
            "text":
                "Trap the soil below the filter mesh and poor a small amount of the water into a separate container",
            "image": "assets/images/take-photo.jpg",
          }
        ]
      },
    },
    {
      "isFirst": true,
      "title": "Test PAD",
      "imageUrl": "assets/images/take-photo.jpg",
      "steps": {
        "en": [
          {
            "text":
                "Select ‘start the test’ (this will start a timer) and immediately place the PAD onto the decanted water sample.",
            "image": "assets/images/take-photo.jpg",
          },
          {
            "text":
                "Once timer ends an instruction to prompt the user to now take the photograph Upload image prompt (reminder to submit later if needed)",
            "image": "assets/images/take-photo.jpg",
          }
        ]
      },
    },
    {
      "isFirst": true,
      "title": "PAD (water sample)",
      "imageUrl": "assets/images/take-photo.jpg",
      "steps": {
        "en": [
          {
            "text":
                "Repeat the PAD test using some water that has not been mixed with soil.",
            "image": "assets/images/take-photo.jpg",
          },
          {
            "text": "Upload image prompt (reminder to submit later if needed)",
            "image": "assets/images/take-photo.jpg",
          }
        ]
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: Text('Guide To Soil Check'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                        steps: _steps[index]["steps"]["en"],
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
    this.steps,
    this.disabled = false,
  }) : super(key: key);

  final String asset;
  final String title;
  final List<Map<String, String>> steps;
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
                  color: const Color(0xFF636564),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Column(
                  children: steps
                      .map((step) => Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(String.fromCharCode(0x2022)),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Flexible(
                                      child: Text(
                                        step["text"],
                                        style: TextStyle(
                                          color: disabled
                                              ? const Color(0xFFD5D5D5)
                                              : const Color(0xFF636564),
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                step["image"] != null
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12),
                                        child: Image.asset(
                                          step["image"],
                                          height: 100,
                                        ),
                                      )
                                    : SizedBox(),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
