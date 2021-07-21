import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/soil_check_result.dart';
import 'package:flutter_app/services/homestead.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/views/newtest/takeshot.dart';
import 'package:flutter_app/views/result/result_raw.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../../home.dart';

class SoilTestPage extends StatefulWidget {
  @override
  _SoilTestPageState createState() => _SoilTestPageState();
}

const timeDuration = 5;

class _SoilTestPageState extends State<SoilTestPage> {
  int counter = timeDuration;
  Timer timer;
  int currentStep = 0;
  bool timeOut = false;
  bool canStartTimer = true;
  bool onGoing = false;
  SoilCheckResult soilResult;
  String testType = "";
  int duration = 3;

  startTimer() {
    counter = duration * 60;
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
          timer.cancel();
          timeOut = true;
          canStartTimer = true;
          onGoing = false;
          FlutterRingtonePlayer.playAlarm();
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

  void _updateTestType() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var type = sp.getString("test_type");
      var dur = 3;
      if (type == "ph") {
        dur = 1;
      }
      setState(() {
        testType = type;
        duration = dur;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future _setPosition() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    try {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          _showToastError("Location service is not enabled");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Home(
                initialPage: 1,
              ),
            ),
          );
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          _showToastError("Location permission is denied");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Home(
                initialPage: 1,
              ),
            ),
          );
          return;
        }
      }

      _locationData = await location.getLocation();

      var sp = await SharedPreferences.getInstance();
      sp.setDouble("longitude", _locationData.longitude);
      sp.setDouble("latitude", _locationData.latitude);
    } catch (e) {
      _showToastError(e.toString());
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
    _updateTestType();
  }

  final RoundedLoadingButtonController nextController =
      new RoundedLoadingButtonController();

  String textContent() {
    if (currentStep == 0) {
      return "Take Photo";
    }
    if (currentStep == 1) {
      return timeOut ? "Take Photo" : "Back";
    }
    if (currentStep == 2) {
      return "New Test";
    }
    return "";
  }

  TextEditingController homesteadController = TextEditingController();
  TextEditingController zoneController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  FocusNode homeSteadFocus = FocusNode(canRequestFocus: true);
  FocusNode zoneFocus = FocusNode(canRequestFocus: true);
  FocusNode notesFocus = FocusNode(canRequestFocus: true);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(testType.isNotEmpty ? '$testType Test' : 'Soil Test Steps'),
        leading: IconButton(
          icon: Icon(
            Icons.navigate_before,
            size: 38,
          ),
          onPressed: () async {
            var exit = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Are you sure you want to quit Test?'),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text('Exit'),
                      onPressed: () => Navigator.of(context).pop(true)),
                  ElevatedButton(
                      child: Text('Stay'),
                      onPressed: () => Navigator.of(context).pop(false)),
                ],
              ),
            );
            if (exit) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure you want to quit Test?'),
            actions: <Widget>[
              ElevatedButton(
                  child: Text('Exit'),
                  onPressed: () => Navigator.of(context).pop(true)),
              ElevatedButton(
                  child: Text('Stay'),
                  onPressed: () => Navigator.of(context).pop(false)),
            ],
          ),
        ),
        child: Container(
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: currentStep,
            physics: ClampingScrollPhysics(),
            controlsBuilder: (BuildContext context,
                {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
              // bool showControls = false;
              bool showControls = currentStep == 1;

              return showControls
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton.icon(
                          onPressed: onGoing
                              ? null
                              : () {
                                  if (timeOut) {
                                    FlutterRingtonePlayer.stop();
                                    setState(() {
                                      currentStep = 2;
                                    });
                                  } else {
                                    setState(() {
                                      currentStep = 0;
                                    });
                                  }
                                },
                          icon: Icon(!timeOut
                              ? Icons.skip_next_outlined
                              : Icons.label_important_outline_sharp),
                          label: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(textContent()),
                          ),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                          ),
                        ),
                        // currentStep == 1
                        //     ? OutlinedButton(
                        //         onPressed: onStepCancel,
                        //         child: const Text('CANCEL'),
                        //       )
                        //     : SizedBox(),
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
                  onGoing = false;
                  timeOut = false;
                  currentStep = 0;
                });
              }
            },
            steps: [
              Step(
                title: Text('Tagging'),
                isActive: currentStep == 0,
                content: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fill in details for the soil test',
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
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(10),
                                ),
                              ),
                              labelText: "HomeStead Name",
                              labelStyle: TextStyle(color: Colors.black54),
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            return await HomeSteadService.fetchHomesteads(
                                pattern);
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
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(10),
                                ),
                              ),
                              labelText: "HomeStead Zone",
                              labelStyle: TextStyle(color: Colors.black54),
                            ),
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
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(10),
                              ),
                            ),
                            labelText: "Comments",
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          style: TextStyle(
                            color: AppColors.primaryColor,
                          ),
                          maxLines: 2,
                          minLines: 2,
                          focusNode: notesFocus,
                          controller: notesController,
                          onChanged: (value) {},
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: Text(
                                'RESET',
                              ),
                              onPressed: () async {
                                try {
                                  notesController.text = '';
                                  zoneController.text = '';
                                  homesteadController.text = '';
                                } catch (e) {
                                  print(e.toString());
                                }
                              },
                            ),
                            ElevatedButton(
                              child: Text('SAVE DETAILS'),
                              onPressed: () async {
                                try {
                                  print('b4 done');
                                  if (_formKey.currentState.validate()) {
                                    print('done');
                                    var sp =
                                        await SharedPreferences.getInstance();
                                    print('done');
                                    sp.setString("notes",
                                        notesController.text ?? 'Random');
                                    sp.setString("zone",
                                        zoneController.text ?? 'Random');
                                    sp.setString("homestead",
                                        homesteadController.text ?? 'Random');
                                    _showToast('Details Saved');
                                    Future.delayed(
                                        Duration(milliseconds: 500),
                                        () => {
                                              setState(() {
                                                currentStep = 1;
                                              })
                                            });
                                    print('done');
                                  }
                                } catch (e) {
                                  print(e.toString());
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Step(
                title: Text('Timer'),
                isActive: currentStep == 1,
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
                                        borderRadius:
                                            BorderRadius.circular(18.0),
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
                              child: Column(
                                children: [
                                  Text(
                                    'Start the Timer and immediately dip the PAD into the the decanted water solution.',
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Wait for $duration minutes',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
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
                isActive: currentStep == 2,
                content: TakeShot(
                    // updateFn: () {
                    //   if (mounted) {
                    //     this.setState(() {
                    //       currentStep++;
                    //     });
                    //   }
                    // },
                    // updateSoilResult: (SoilCheckResult res) {
                    //   setState(() {
                    //     soilResult = res;
                    //   });
                    // },
                    ),
              ),
              // Step(
              //   title: Text('Results'),
              //   isActive: currentStep == 2,
              //   content: SoilResultWidget(
              //     soilResult: soilResult,
              //   ),
              // ),
            ],
          ),
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

  _showToastError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
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
}
