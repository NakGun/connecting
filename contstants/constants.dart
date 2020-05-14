import 'package:flutter/material.dart';

const double galleryHeaderHeight = 64;
const double desktopDisplay1FontDelta = 16;
const double desktopSettingsWidth = 520;
const firstHeaderDesktopTopPadding = 5.0;
const double systemTextScaleFactorOption = -1;
const splashPageAnimationDurationInMilliseconds = 300;


/* padding */
const double common_xxxs_gap = 4.0;
const double common_xs_gap = 10.0;
const double common_s_gap = 12.0;
const double common_gap = 14.0;
const double common_l_gap = 16.0;
const double profile_radius = 16.0;

Size size;

//나이 100까지 생성
List<String> ageList = List.generate(100, (generator){
  return '$generator';
});

//혈핵형
List<String> bloodList = [
  'A형',
  'O형',
  'B형',
  'AB형',
  '신형',
  '구형',
  '하지마형',
];

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: '행복한 소식을 전해보세요~!',
  border: InputBorder.none,
);

const kTextFiedlDecoration =
InputDecoration(
  hintText: 'Enter a value.',
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide:
    BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide:
    BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);