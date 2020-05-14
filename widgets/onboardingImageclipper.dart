import 'package:flutter/material.dart';

class OnBoardingImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size){
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(12, size.height - 38, 40, size.height - 48);
    path.lineTo(size.width - 40, size.height - 140);
    path.quadraticBezierTo(size.width, size.height - 145, size.width, size.height - 212);
    path.lineTo(size.width, 0);
    return path;
  }

  //CustomClipper extend하기 위해선 shouldReclip 가 필수
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}
