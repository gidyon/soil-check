import 'package:flutter/material.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/widgets/shareapp.dart';

import 'language.dart';

class DefaultAppBar {
  static AppBar createAppBar(BuildContext context, String title) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.whiteColor,
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.navigate_before,
            color: AppColors.primaryColor,
            size: 38,
          )),
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(color: AppColors.primaryColor),
            ),
            Row(
              children: [
                ShareApp(),
                SizedBox(
                  width: 10,
                ),
                LanguageSelection()
              ],
            )
          ],
        ),
      ),
    );
  }
}
