import 'package:flutter/material.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/widgets/defaultappbar.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

List<String> healthTemptations = [
  'Taste Cafetiere solution. You may get infections',
  'Take selfies. This is not recommended since the app is a productivity tool',
];

class HealthStatementPage extends StatefulWidget {
  @override
  _HealthStatementPageState createState() => _HealthStatementPageState();
}

class _HealthStatementPageState extends State<HealthStatementPage> {
  final RoundedLoadingButtonController _agreeController =
      new RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    var titleStyle = TextStyle(
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w900,
      fontSize: 16,
    );
    return Scaffold(
      appBar: DefaultAppBar.createAppBar(
        context,
        'Health & Safety',
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'Your Safety',
              style: titleStyle,
            ),
            Flexible(
              child: Text(
                'Be careful',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Health and Hygiene',
              style: titleStyle,
            ),
            Flexible(
              child: Text(
                'While using the app you might be tempted to do the following, please DONT!',
              ),
            ),
            Container(
              child: Column(
                children: healthTemptations
                    .map((e) => Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(String.fromCharCode(0x2022)),
                            SizedBox(
                              width: 5,
                            ),
                            Flexible(child: Text(e)),
                          ],
                        ))
                    .toList(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                child: Center(
              child: Column(
                children: [
                  RoundedLoadingButton(
                    child: Text('Close', style: TextStyle(color: Colors.white)),
                    controller: _agreeController,
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    width: 200,
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
