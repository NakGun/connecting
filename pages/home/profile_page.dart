import 'dart:convert';
import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:path/path.dart' as pathDart;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecting/contstants/constants.dart';
import 'package:connecting/contstants/firebase_keys.dart';
import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/data/user.dart';
import 'package:connecting/firebase/firebase_storage.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:connecting/isolate/resize_image.dart';
import 'package:connecting/pages/login/join_page.dart';
import 'package:connecting/util/image_path.dart';
import 'package:connecting/util/progress_bar.dart';
import 'package:connecting/widgets/add_info.dart';
import 'package:connecting/widgets/base_info.dart';
import 'package:connecting/widgets/side_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

class ProfilePage extends StatefulWidget {

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  User userData;
  AnimationController _animationController;
  bool _menuOpened = false;
  double menuWidth;
  int duration = 300;

  String tmpImageUrl;
  String selectedBlood;

  Firestore firestore = Firestore.instance;

  //이미지 내 서버에 업로드..
  static final String uploadEndPoint = 'http://oniyuni.ddns.net/userImages/upload_image.php';
  String status = '';
  String base64Image;
  //File tmpFile;
  String errMessage = 'Error Uploading Image';
  File imageFile;
  static final String myServerImageUrl = 'http://oniyuni.ddns.net/userImages/';

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: duration));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  //사진 저장 후 초기화 용도
//  void setValue(){
//    setState(() {
//      userImg = [];
//    });
//  }
  @override
  Widget build(BuildContext context) {

    menuWidth = MediaQuery.of(context).size.width / 1.5;
    return GestureDetector(
      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Consumer<MyUserData>(
        builder: (context, myUserData, child) {
          userData = myUserData.data;
//          print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${userImg.isEmpty}');
          //dynamic to String 형변환
          //userImg = myUserData.data.profileImg.map((s) => s as String).toList();
//          if(userImg.isEmpty){
//            userImg = myUserData.data.profileImg.map((s) => s as String).toList();
//          }

          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  AnimatedContainer(
                    curve: Curves.easeInOut,
                    duration: Duration(milliseconds: duration),
                    transform: Matrix4.translationValues(
                        _menuOpened ? -menuWidth : 0, 0, 0),
                    child: getProfile(),
                  ),
                  _sideMenu(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Column getProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _appBar(),
        Divider(
          height: 1,
          color: Colors.grey[900],
        ),
        SizedBox(
          height: 3,
        ),

        //body 전체
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                //사진첫째줄
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _photoImage(1.6, 1.53, 1),
//                        DragTarget<int>(
//                          builder: (context, accept, reject) {
//                            return Draggable<int>(
//                              data: 0,
//                              child: _photoImage(1.6, 1.53, 0),
//                         //     feedback: _photoImage(1.6, 1.53, 0),
//                            );
//                          },
//                          onAccept: (int) {
//                            setState(() {
//                              tmpImageUrl = userImg[0];
//                              userImg[0] = userImg[int];
//                              userImg[int] = tmpImageUrl;
//                            });
//                          },
//                        ),
                        Column(
                          children: <Widget>[
                            _photoImage(3.25, 3.1, 2),
//                            DragTarget<int>(
//                              builder: (context, accept, reject) {
//                                return Draggable<int>(
//                                  data: 1,
//                                  child: _photoImage(3.25, 3.1, 1),
//                                  feedback: _photoImage(3.25, 3.1, 1),
//                                );
//                              },
//                              onAccept: (int) {
//                                print('Taget 1~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
//                                setState(() {
//                                  tmpImageUrl = userImg[1];
//                                  userImg[1] = userImg[int];
//                                  userImg[int] = tmpImageUrl;
//                                });
//                              },
//                            ),
                            SizedBox(
                              height: 3,
                            ),
                            _photoImage(3.25, 3.1, 3),
//                            DragTarget<int>(
//                              builder: (context, accept, reject) {
//                                return Draggable<int>(
//                                  data: 2,
//                                  child: _photoImage(3.25, 3.1, 2),
//                                  feedback: _photoImage(3.25, 3.1, 2),
//                                );
//                              },
//                              onAccept: (int) {
//                                print('Taget 2~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
//                                setState(() {
//                                  tmpImageUrl = userImg[2];
//                                  userImg[2] = userImg[int];
//                                  userImg[int] = tmpImageUrl;
//                                });
//                              },
//                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                //두번째줄
                Row(
                  children: <Widget>[
                    _photoImage(3.15, 3.1, 4),
//                    DragTarget<int>(
//                      builder: (context, accept, reject) {
//                        return Draggable<int>(
//                          data: 3,
//                          child: _photoImage(3.15, 3.1, 3),
//                          feedback: _photoImage(3.15, 3.1, 3),
//                        );
//                      },
//                      onAccept: (int) {
//                        print('Taget 3~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
//                        setState(() {
//                          tmpImageUrl = userImg[3];
//                          userImg[3] = userImg[int];
//                          userImg[int] = tmpImageUrl;
//                        });
//                      },
//                    ),
                    _photoImage(3.15, 3.1, 5),
//                    DragTarget<int>(
//                      builder: (context, accept, reject) {
//                        return Draggable<int>(
//                          data: 4,
//                          child: _photoImage(3.15, 3.1, 4),
//                          feedback: _photoImage(3.15, 3.1, 4),
//                        );
//                      },
//                      onAccept: (int) {
//                        print('Taget 4~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
//                        setState(() {
//                          tmpImageUrl = userImg[4];
//                          userImg[4] = userImg[int];
//                          userImg[int] = tmpImageUrl;
//                        });
//                      },
//                    ),
                    _photoImage(3.15, 3.1, 6),
//                    DragTarget<int>(
//                      builder: (context, accept, reject) {
//                        return Draggable<int>(
//                          data: 5,
//                          child: _photoImage(3.15, 3.1, 5),
//                          feedback: _photoImage(3.15, 3.1, 5),
//                        );
//                      },
//                      onAccept: (int) {
//                        print('Taget 5~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
//                        setState(() {
//                          tmpImageUrl = userImg[5];
//                          userImg[5] = userImg[int];
//                          userImg[int] = tmpImageUrl;
//                        });
//                      },
//                    ),
                  ],
                ),

                //명칭 및 기본정보
                BaseInfo(
                  crudTp: true,
                  user: userData,
                ),
                Divider(
                  thickness: 1,
                ),

                //추가정보
                AddInfo(
                  textReadOnly: false,
                  user: userData,
                  //file: _image,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Padding _photoImage(double hRate, double wRate, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 3.0),
      child: GestureDetector(
        onTap: () async {
          imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
          imageFile == null ? null : progressBar(context);

          ///Storage에 사진업로드
//          Directory directory = await getTemporaryDirectory();

          final path = pathDart.join((await getTemporaryDirectory()).path,
              '${DateTime.now().toUtc().millisecondsSinceEpoch}_${userData.username}.png');
          final File newImage = await imageFile.copy('$path');

          //라이브포커스 등 리사이징이 안되는 파일들이 존재함 그런경우 일단 원래 해상도로 올리자..
          File resize;
          try {
            resize = await compute(getResizedImage, newImage);
          }catch(e){
            resize = newImage;
          }

//          dynamic downloadUrl = await storageProvider.uploadImg(
//              resize, getImgPath(userData.username));


          //이미지 업로드
         // tmpFile = imageFile;
          base64Image = base64Encode(resize.readAsBytesSync());

          String saveName = resize.path.split('/').last;
          await startUpload(saveName);

          dynamic downloadUrl = myServerImageUrl+saveName;
          //이미지 url저장
          firestore
              .collection("Users")
              .document(userData.userKey)
              .updateData({"profileImg$index": downloadUrl});

//            final firebaseStorageRef = FirebaseStorage.instance
//                .ref()
//                .child('$COLLECTION_POSTS' +'/'+ '${userData.username}')
//                .child('${DateTime.now().millisecondsSinceEpoch}.png');
//
//            final task = firebaseStorageRef.putFile(
//                image, StorageMetadata(contentType: 'image/png'));
//
//            print('================storage upload complelete==========================');
//            ///사진 참조 url저장
//            await task.onComplete.then((value) async {
//              var downloadUrl = await value.ref.getDownloadURL();
//              ///firebase에 참조 url업데이트
//              firestore.collection("Users").document(userData.userKey).updateData({"profileImg$index":downloadUrl});
//            });
          Navigator.pop(context);
        },
        onLongPress: (){
          Alert(
            context: context,
            title: "알림",
            desc: "사진을 삭제하시겠습니까?",
            buttons: [
              DialogButton(
                color: Color.fromRGBO(0, 179, 134, 1.0),
                radius: BorderRadius.circular(0.0),
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () {
                  firestore
                      .collection("Users")
                      .document(userData.userKey)
                      .updateData({"profileImg$index": ''});
                  Navigator.pop(context);
                }
              ),
            ],
          ).show();
        },
        child: Container(
          height: MediaQuery.of(context).size.width / hRate,
          width: MediaQuery.of(context).size.width / wRate,
          color: Colors.grey[400],
          child: _getImage(index),
          //이미지를 선택했다면 선택한 이미지가 아니면 조회된 이미지가 나오도록..
//          child: _image[index] == null ? _getImage(index) : Image.file(_image[index], fit: BoxFit.cover,),
        ),
      ),
    );
  }

  startUpload(String fileName) async {
    setStatus('Uploading Image...');
    if (null == fileName) {
      setStatus(errMessage);
      return -1;
    }
    await upload(fileName);
  }

  upload(String fileName) async {
    print('base64Image=====> ${base64Image}');
    print('fileName=====> ${fileName}');
    await http.post(uploadEndPoint, body: {
      "image": base64Image,
      "name": fileName,
    }).then((result) {
      setStatus(result.statusCode == 200 ? result.body : errMessage);
    }).catchError((error) {
      setStatus(error);
    });
  }

  setStatus(String message) {
    setState(() {
      status = message;
      print('status=====>${status}');
    });
  }

  Widget _getImage(int index) {
    String profileImg = '';

    if (index == 1) {
      profileImg = userData.profileImg1;
    } else if (index == 2) {
      profileImg = userData.profileImg2;
    } else if (index == 3) {
      profileImg = userData.profileImg3;
    } else if (index == 4) {
      profileImg = userData.profileImg4;
    } else if (index == 5) {
      profileImg = userData.profileImg5;
    } else if (index == 6) {
      profileImg = userData.profileImg6;
    }

    return profileImg != ''
        ? Image.network(
            profileImg,
            fit: BoxFit.cover,
          )
        : Center(
            child: Text(
            'add Image[+]',
            style: TextStyle(fontSize: 10),
          ));
  }

//
//  Widget _getImage(int urlIndex) {
//    //조회사진이 없을경우 index 범위 오류나므로 index 범위 체크와 이미지url여부를 모두 체크
//    return userImg.length > urlIndex && userImg[urlIndex] != '' ?
//      Image.network(
//      userImg[urlIndex],
//      fit: BoxFit.cover,
//    ) :
//    Center(child: Text('add Image[+]', style: TextStyle(fontSize: 10),));
//
//    ///TODO:값이 있냐없냐에 따라 십자가 아이콘 또는 사진보여줘야함
////      FlatButton.icon(
////                icon: Icon(Icons.add),
////                label: Text(''),
////              );
//  }

  Widget _appBar() {
    return Container(
      color: Colors.pink[300],
      width: double.infinity,
      height: 50,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                '프로필',
                style: TextStyle(fontWeight: FontWeight.w100, fontSize:20, fontFamily: 'lotte'),
              ),
            ),
          ),
          IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animationController,
              semanticLabel: 'Show Menu',
            ),
            onPressed: () {
              _menuOpened
                  ? _animationController.reverse()
                  : _animationController.forward();
              setState(() {
                _menuOpened = !_menuOpened;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _sideMenu() {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      color: Colors.grey[200],
      duration: Duration(milliseconds: duration),
      transform: Matrix4.translationValues(
          _menuOpened
              ? MediaQuery.of(context).size.width - menuWidth
              : MediaQuery.of(context).size.width,
          0,
          0),
      child: SafeArea(
        child: SizedBox(
          width: menuWidth,
          child: ProfileSideMenu(),
        ),
      ),
    );
  }

  DropdownButton<String> androidDropdown() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (String currency in bloodList) {
      var newItem = DropdownMenuItem(
        child: Text(currency),
        value: currency,
      );
      dropdownItems.add(newItem);
    }

    return DropdownButton<String>(
      value: selectedBlood,
      items: dropdownItems,
      onChanged: (value) {
        setState(() {
          selectedBlood = value;
        });
      },
    );
  }

  void setRebuild(){
    setState(() {
      _menuOpened = false;
    });
  }
}
