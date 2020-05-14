import 'package:flutter/material.dart';

class OnBoardingButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size){
    Path path = Path();

    //이동 후 선 3개 그리기
    path.moveTo(0, size.height/2);
    //path.lineTo(size.width, size.height);
    path.quadraticBezierTo(size.width/2, size.height, size.width, size.height);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(size.width/2, 0, 0, size.height/2);

    //path.lineTo(0, size.height/2);


//    path.lineTo(0, size.height);

    return path;
  }

  //CustomClipper extend하기 위해선 shouldReclip 가 필수
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}
