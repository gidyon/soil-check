import 'package:flutter/material.dart';

class PoweredBy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            child: RichText(
          text: TextSpan(
              text: 'Developed by ',
              style: TextStyle(color: Colors.black54, fontSize: 15),
              children: <TextSpan>[
                TextSpan(
                  text: ' Labpoint Limited',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                )
              ]),
        )),
        SizedBox(
          height: 3,
        ),
        // Center(
        //   child: Text(
        //     'labpoint.co.ke',
        //     style: TextStyle(
        //         color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
        //   ),
        // )
      ],
    );
  }
}
