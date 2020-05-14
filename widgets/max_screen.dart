import 'package:carousel_pro/carousel_pro.dart';
import 'package:connecting/contstants/constants.dart';
import 'package:connecting/data/user.dart';
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class MaxScreenPage extends StatefulWidget {
  final User user;

  const MaxScreenPage({Key key, this.user}) : super(key: key);

  @override
  _MaxScreenPageState createState() => _MaxScreenPageState();
}

class _MaxScreenPageState extends State<MaxScreenPage> {
  int beforeImage = 0;
  int afterImage = 0;

  List<String> imageList = List(6);
  Matrix4 matrix = Matrix4.identity();

  @override
  Widget build(BuildContext context) {

    imageList[0] = widget.user.profileImg1;
    imageList[1] = widget.user.profileImg2;
    imageList[2] = widget.user.profileImg3;
    imageList[3] = widget.user.profileImg4;
    imageList[4] = widget.user.profileImg5;
    imageList[5] = widget.user.profileImg6;

    return MatrixGestureDetector(
      onMatrixUpdate: (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
        setState(() {
          matrix = m;
        });
      },
      child: Transform(
        transform: matrix,
        child: GestureDetector(
          onTap: (){
            //Navigator.pop(context);
          },
          child: Container(
            color: Colors.white,
            width: size.width,
            height: size.height,
            child: Carousel(
              onImageChange: (before, after) {
                beforeImage = before;
                afterImage = after;
                print('111');
                setState(() {
                  matrix = Matrix4.identity();
                });
              },
              boxFit: BoxFit.scaleDown,
              //boxFit: BoxFit.fill,
              images: _imageList(),
              autoplay: false,
              indicatorBgPadding: 1.0,
              dotBgColor: Colors.transparent,
              //dotColor: Colors.white60,
             // dotIncreasedColor: Colors.orangeAccent[100],
              //dotSize: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  List _imageList () {
    List imageSet = [];
    for(int i = 0; i < imageList.length; i++){
      imageList[i] == '' ? imageSet.add(AssetImage('assets/placeholder.png')) : imageSet.add(NetworkImage(imageList[i]));
    }
    return imageSet;
  }
}
