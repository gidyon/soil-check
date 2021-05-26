import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/soil_check_result.dart';
import 'package:flutter_app/services/homestead.dart';
import 'package:flutter_app/services/location.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/views/newtest/takeshot.dart';
import 'package:flutter_app/views/result/result_raw.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home.dart';

class SoilTestPage extends StatefulWidget {
  @override
  _SoilTestPageState createState() => _SoilTestPageState();
}

const timeDuration = 10;

class _SoilTestPageState extends State<SoilTestPage> {
  int counter = timeDuration;
  Timer timer;
  int currentStep = 0;
  bool timeOut = false;
  bool canStartTimer = true;
  bool onGoing = true;
  SoilCheckResult soilResult;

  startTimer() {
    counter = timeDuration;
    if (timer != null) {
      timer.cancel();
    }
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (counter > 0) {
          counter--;
          canStartTimer = false;
          onGoing = true;
        } else {
          // setState(() {
          //   currentStep = 1;
          // });
          timer.cancel();
          timeOut = true;
          canStartTimer = true;
          onGoing = false;
        }
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (timer != null) {
      timer.cancel();
    }
  }

  Future _setPosition() async {
    try {
      bool allowed = await askPermission();
      if (allowed) {
        var pos = await Geolocator.getCurrentPosition();
        var sp = await SharedPreferences.getInstance();
        print('setting position to ${pos.latitude} == ${pos.longitude}');
        sp.setDouble("longitude", pos.longitude);
        sp.setDouble("latitude", pos.latitude);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Home(
              initialPage: 1,
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Home(
            initialPage: 1,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setPosition();
    Future.delayed(Duration(milliseconds: 100), () {
      _showDetailsDialog(context);
    });
  }

  final RoundedLoadingButtonController nextController =
      new RoundedLoadingButtonController();

  String textContent() {
    if (currentStep == 0) {
      return "Take Photo of PAD";
    }
    if (currentStep == 2) {
      return "New Test";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soil Test Steps'),
        leading: IconButton(
          icon: Icon(
            Icons.navigate_before,
            size: 38,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: currentStep,
          physics: ClampingScrollPhysics(),
          controlsBuilder: (BuildContext context,
              {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
            bool showControls = currentStep != 1;
            bool showNext = timeOut && currentStep != 2;

            return showControls
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton.icon(
                        onPressed: showNext
                            ? onStepContinue
                            : currentStep == 2
                                ? () {
                                    if (currentStep == 2) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              SoilTestPage(),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                        icon: Icon(currentStep != 2
                            ? Icons.skip_next_outlined
                            : Icons.label_important_outline_sharp),
                        label: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(textContent()),
                        ),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                        ),
                      ),
                      currentStep == 1
                          ? OutlinedButton(
                              onPressed: onStepCancel,
                              child: const Text('CANCEL'),
                            )
                          : SizedBox(),
                    ],
                  )
                : SizedBox();
          },
          onStepCancel: () {},
          onStepContinue: () {
            print(currentStep);
            if (currentStep == 0) {
              setState(() {
                currentStep++;
              });
            } else if (currentStep == 1) {
              setState(() {
                currentStep = 2;
              });
            } else if (currentStep == 2) {
              setState(() {
                currentStep = 0;
              });
            }
          },
          steps: [
            Step(
              title: Text('Timer'),
              isActive: currentStep == 0,
              content: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    canStartTimer
                        ? timeOut
                            ? Text(
                                'PAD Is Ready To Take Photo',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () {
                                  startTimer();
                                },
                                icon: Icon(Icons.timer),
                                label: Text('Start Timer'),
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                  ),
                                ),
                              )
                        : Text(
                            '$counter Sec',
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(color: AppColors.primaryColor),
                          ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              'Start timer and Dip the PAD into the the decanted water sample.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .color,
                                  ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Image.asset(
                              'assets/images/cropping.jpg',
                              height: 200,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            Step(
              title: Text('Upload'),
              isActive: currentStep == 1,
              content: TakeShot(
                updateFn: () {
                  if (mounted) {
                    this.setState(() {
                      currentStep++;
                    });
                  }
                },
                updateSoilResult: (SoilCheckResult res) {
                  setState(() {
                    soilResult = res;
                  });
                },
              ),
            ),
            Step(
              title: Text('Results'),
              isActive: currentStep == 2,
              content: SoilResultWidget(
                soilResult: soilResult,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<String> dialogInstructions = [
    'Clicking Start Timer will start a 3 minute timer.',
    'Immediately place the PAD onto the decanted water sample.',
    'Once timer ends, you will be prompted to take or upload photo of the PAD.'
  ];

  String homestead, zone;

  _showDetailsDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            // title: Text(
            //   'Save Test Details',
            //   // style: Theme.of(context).textTheme.headline5.copyWith(
            //   //       color: AppColors.primaryColor,
            //   //       fontWeight: FontWeight.bold,
            //   //     ),
            // ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            content: HomeStead(),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    child: Text(
                      'RANDOM TEST',
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      var sp = await SharedPreferences.getInstance();
                      sp.setString("homestead", "Random");
                      sp.setString("zone", "Random");
                      sp.setString("notes", notes);
                      _showToast('Details Saved');
                    },
                  ),
                  ElevatedButton(
                    child: Text('SAVE DETAILS'),
                    onPressed: () async {
                      var sp = await SharedPreferences.getInstance();
                      sp.setString("notes", notes);
                      Navigator.pop(context);
                      _showToast('Details Saved');
                    },
                  )
                ],
              )
            ],
          );
        });
  }
}

String notes = '';
String homeStead = '';
String zone = '';

class HomeStead extends StatefulWidget {
  @override
  _HomeSteadState createState() => _HomeSteadState();
}

class _HomeSteadState extends State<HomeStead> {
  TextEditingController homesteadController = TextEditingController();
  TextEditingController zoneController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  FocusNode homeSteadFocus = FocusNode(canRequestFocus: true);
  FocusNode zoneFocus = FocusNode(canRequestFocus: true);
  FocusNode notesFocus = FocusNode(canRequestFocus: true);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Homestead, zone an additional notes for the test',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: AppColors.primaryColor),
            ),
            SizedBox(
              height: 20,
            ),
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: homesteadController,
                autofocus: true,
                maxLines: 1,
                focusNode: homeSteadFocus,
                scrollPadding: EdgeInsets.all(5),
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
                decoration: InputDecoration(
                  labelText: "HomeStead Name",
                  filled: true,
                  isDense: true,
                  labelStyle: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                onChanged: (value) async {
                  var sp = await SharedPreferences.getInstance();
                  print(
                      'setting homestead to $value == ${homesteadController.text}');
                  sp.setString("homestead", value);
                },
              ),
              suggestionsCallback: (pattern) async {
                return await HomeSteadService.fetchHomesteads(pattern);
              },
              hideOnEmpty: true,
              itemBuilder: (context, suggestion) {
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.home_outlined),
                  title: Text('$suggestion'),
                );
              },
              onSuggestionSelected: (suggestion) async {
                try {
                  homesteadController.text = suggestion;
                  zoneFocus.requestFocus();
                  var sp = await SharedPreferences.getInstance();
                  print(
                      'setting homestead to $suggestion == ${homesteadController.text}');
                  sp.setString("homestead", suggestion);
                } catch (e) {
                  print(e.toString());
                }
              },
            ),
            SizedBox(
              height: 20,
            ),
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: zoneController,
                focusNode: zoneFocus,
                maxLines: 1,
                scrollPadding: EdgeInsets.all(5),
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
                decoration: InputDecoration(
                  // border: new OutlineInputBorder(
                  //   borderRadius: const BorderRadius.all(
                  //     const Radius.circular(10),
                  //   ),
                  // ),
                  filled: true,
                  isDense: true,
                  labelText: "HomeStead Zone",
                  labelStyle: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                onChanged: (value) async {
                  var sp = await SharedPreferences.getInstance();
                  print('setting zone to $value == ${zoneController.text}');
                  sp.setString("zone", value);
                },
              ),
              suggestionsCallback: (pattern) async {
                return await HomeSteadService.fetchZones(
                    homesteadController.text, pattern);
              },
              hideOnEmpty: true,
              itemBuilder: (context, suggestion) {
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.home_outlined),
                  title: Text('$suggestion'),
                );
              },
              onSuggestionSelected: (suggestion) async {
                zoneController.text = suggestion;
                notesFocus.requestFocus();
                var sp = await SharedPreferences.getInstance();
                print('setting zone to $suggestion == ${zoneController.text}');
                sp.setString("zone", suggestion);
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                // border: new OutlineInputBorder(
                //   borderRadius: const BorderRadius.all(
                //     const Radius.circular(10),
                //   ),
                // )
                filled: true,
                isDense: true,
                labelText: "Notes",
                labelStyle: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              style: TextStyle(
                color: AppColors.primaryColor,
              ),
              maxLines: 2,
              minLines: 1,
              focusNode: notesFocus,
              controller: notesController,
              onChanged: (value) {
                notes = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    homeSteadFocus.dispose();
    zoneFocus.dispose();
    notesFocus.dispose();
    super.dispose();
  }
}
// _showDetailsDialog(BuildContext context) {
//   showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             'Starts 3 minute timer',
//             style: Theme.of(context).textTheme.headline5.copyWith(
//                   color: AppColors.primaryColor,
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//           content: Container(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: dialogInstructions
//                   .map((e) => Container(
//                         margin: EdgeInsets.only(bottom: 5),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(String.fromCharCode(0x2022)),
//                             SizedBox(
//                               width: 5,
//                             ),
//                             Flexible(
//                               child: Text(
//                                 e,
//                                 style: Theme.of(context).textTheme.bodyText2,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ))
//                   .toList(),
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text(
//                 'START TIMER',
//               ),
//               onPressed: () {
//                 Navigator.pop(context);
//                 startTimer();
//               },
//             ),
//             TextButton(
//               child: Text('EXIT PAGE'),
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context);
//               },
//             )
//           ],
//         );
//       });
// }
