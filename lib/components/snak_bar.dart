import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showMySnakbarWidget(BuildContext context, String message,
    {Color backgroundColor = Colors.red,
    Color textColor = Colors.white,
    int durationInSecond = 2}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    
    content: Text(
      message,
      style: TextStyle(
        color: textColor,
      ),
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: durationInSecond),
  ));
}
