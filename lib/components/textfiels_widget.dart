import 'package:flutter/material.dart';

class TextFormWidget extends StatelessWidget {
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Color shadowColor;
  final Color prefixIconActiveColor;
  final Color fillColor;
  final VoidCallback? onSuffixIconTap;
  final String? Function(String?)? validator;

  const TextFormWidget({
    Key? key,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.shadowColor = Colors.black12,
    this.prefixIconActiveColor = Colors.blueAccent,
    this.fillColor = Colors.white,
    this.onSuffixIconTap,
   required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.8,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: prefixIconActiveColor,
                )
              : null,
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixIconTap,
                  child: Icon(
                    suffixIcon,
                    color: prefixIconActiveColor,
                  ),
                )
              : null,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: prefixIconActiveColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
