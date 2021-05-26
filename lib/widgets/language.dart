import 'package:flutter/material.dart';
import 'package:flutter_app/utils/colors.dart';

class LanguageSelection extends StatefulWidget {
  @override
  _LanguageSelectionState createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  List<String> _languages = ['En', 'Sw'];
  String _selectedLanguage = 'En';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Icon(
        Icons.g_translate_outlined,
        color: AppColors.primaryColor,
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     child: Row(
  //       children: [
  //         DropdownButton<String>(
  //           value: _selectedLanguage,
  //           iconSize: 24,
  //           iconEnabledColor: AppColors.primaryColor,
  //           elevation: 16,
  //           style: const TextStyle(color: Colors.deepPurple),
  //           underline: Container(
  //             height: 2,
  //             color: AppColors.primaryColor,
  //           ),
  //           onChanged: (String val) {
  //             setState(() {
  //               _selectedLanguage = val;
  //             });
  //           },
  //           items: _languages.map<DropdownMenuItem<String>>((String value) {
  //             return DropdownMenuItem<String>(
  //               value: value,
  //               child: Text(
  //                 value,
  //                 style: TextStyle(color: AppColors.primaryColor),
  //               ),
  //             );
  //           }).toList(),
  //         )
  //       ],
  //     ),
  //   );
  // }
}
