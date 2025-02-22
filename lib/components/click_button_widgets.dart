import 'package:flutter/material.dart';

class ClickButtonWidget extends StatelessWidget {
  final String text;
  final Color buttonColor;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow; 

  const ClickButtonWidget({
    Key? key,
    required this.text,
    this.buttonColor = Colors.blue,
    this.textColor = Colors.white,
    this.borderColor = Colors.blue,
    this.borderWidth = 2.0,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      height: height * 0.06,
      width: width * 0.8,
      decoration: BoxDecoration(
        boxShadow: boxShadow ?? [], 
        color: buttonColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
