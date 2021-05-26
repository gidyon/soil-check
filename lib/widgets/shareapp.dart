import 'package:flutter/material.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:share/share.dart';

class ShareApp extends StatefulWidget {
  @override
  _ShareAppState createState() => _ShareAppState();
}

class _ShareAppState extends State<ShareApp> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Share.share('check out my website https://example.com');
      },
      child: Icon(
        Icons.share,
        color: AppColors.primaryColor,
      ),
    );
  }
}
