import 'package:carousel_pro/carousel_pro.dart';
import 'package:connecting/data/user.dart';
import 'package:connecting/widgets/add_info.dart';
import 'package:connecting/widgets/base_info.dart';
import 'package:connecting/widgets/max_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class GalleryDetailPage extends StatefulWidget {
  final User user;

  const GalleryDetailPage({Key key, this.user}) : super(key: key);

  @override
  _GalleryDetailPageState createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  int beforeImage = 0;
  int afterImage = 0;

  List<String> imageList = List(6);


  @override
  Widget build(BuildContext context) {
    imageList[0] = widget.user.profileImg1;
    imageList[1] = widget.user.profileImg2;
    imageList[2] = widget.user.profileImg3;
    imageList[3] = widget.user.profileImg4;
    imageList[4] = widget.user.profileImg5;
    imageList[5] = widget.user.profileImg6;

    return GestureDetector(
      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('${widget.user.username}'),
        ),
        body: ListView(
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  //Navigator.push(context, MaterialPageRoute(builder: (context)=>MaxScreenPage(url: imageList[afterImage],)));
                },
                child: imageSlide()),

          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget imageSlide() {
    return Container(
      height: MediaQuery.of(context).size.width,
      child: Carousel(
        onImageChange: (before, after) {
          beforeImage = before;
          afterImage = after;
        },
        boxFit: BoxFit.scaleDown,
        //boxFit: BoxFit.fill,
        images: _imageList(),
        autoplay: false,
        indicatorBgPadding: 1.0,
        dotBgColor: Colors.transparent,
        dotColor: Colors.grey[200],
        dotIncreasedColor: Colors.orangeAccent[100],
        //dotSize: 4.0,
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
