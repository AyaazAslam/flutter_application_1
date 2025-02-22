import 'package:flutter/cupertino.dart';

class MyCustomCliper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var height = size.height;
    var width = size.width;
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(width * 0.15, 0);
    path.quadraticBezierTo(width * 0.43, height * 0.15, width * 0.82, 0);
    path.quadraticBezierTo(width * 0.3, height * 0.3, width * 0.82, 0);
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
