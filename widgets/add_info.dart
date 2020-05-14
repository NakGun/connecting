import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecting/contstants/constants.dart';
import 'package:connecting/contstants/firebase_keys.dart';
import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/data/user.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:connecting/pages/home/profile_page.dart';
import 'package:connecting/widgets/my_progress_indicator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AddInfo extends StatefulWidget {
  final bool textReadOnly;
  final User user;
  final List<File> file;

  AddInfo(
      {Key key, @required this.textReadOnly, @required this.user, this.file})
      : super(key: key);

  @override
  _AddInfoState createState() => _AddInfoState();
}

class _AddInfoState extends State<AddInfo> {
  TextEditingController bloodKind = TextEditingController();
  TextEditingController job = TextEditingController();
  TextEditingController likeBook = TextEditingController();
  TextEditingController likeStar = TextEditingController();
  TextEditingController introduce = TextEditingController();

  Firestore firestore = Firestore.instance;
  List<String> userImgUrl = List(6);

  @override
  void initState() {
    bloodKind.text = widget.user.blood;
    job.text = widget.user.job;
    likeBook.text = widget.user.likeBook;
    likeStar.text = widget.user.likeStar;
    introduce.text = widget.user.intro;

    super.initState();
  }

  @override
  void dispose() {
    bloodKind.dispose();
    job.dispose();
    likeBook.dispose();
    likeStar.dispose();
    introduce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ProgressDialog pr;
    pr = new ProgressDialog(context);
    pr.style(
        message: 'Please Waiting...',
        borderRadius: 5.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 10.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w600));

    return Consumer<MyUserData>(
      builder: (context, myUserData, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                '  추가정보',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
            addInfoBlood('${myUserData.data.blood}', 'assets/blood.png',
                widget.textReadOnly),
            addInfoJob('${myUserData.data.job}', 'assets/job.png',
                widget.textReadOnly),
            addInfoLikeBook('${myUserData.data.likeBook}', 'assets/book.png',
                widget.textReadOnly),
            addInfoLikeStar('${myUserData.data.likeStar}',
                'assets/movie_star.png', widget.textReadOnly),
            addInfoIntroduce('${myUserData.data.intro}',
                'assets/introduction.png', widget.textReadOnly),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.orange,
                child: widget.textReadOnly == true
                    ? null
                    : FlatButton(
                        child: Text(
                          '저장',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () async {
                          //pr.show();
                          ///추가정보 업데이트
                          final Map<String, dynamic> userData =
                              User.getMapForCreateAddInfo(
                                  bloodKind.text,
                                  job.text,
                                  likeBook.text,
                                  likeStar.text,
                                  introduce.text);
                          await firestoreProvider.userAddUpdate(
                              myUserData.data.userKey, userData);

                          FocusScope.of(context).requestFocus(FocusNode());

                          Alert(
                            context: context,
                            //type: AlertType.info,
                            title: "알림",
                            desc: "저장되었습니다!",
                            buttons: [
                              DialogButton(
                                child: Text(
                                  "OK",
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () => Navigator.pop(context),
                                color: Color.fromRGBO(0, 179, 134, 1.0),
                                radius: BorderRadius.circular(0.0),
                              ),
                            ],
                          ).show();

                          //사진업로드처리
//                    for(var i = 0; i<widget.file.length; i++){
//print('widget.file[i].toString()=======================>>${widget.file[i].toString()}');
//                      //바뀐파일이 있는 경우만
//                      if(widget.file[i].toString() != 'null'){
//                        ///Storage에 사진업로드
//                        final firebaseStorageRef = FirebaseStorage.instance
//                            .ref()
//                            .child('$COLLECTION_POSTS' +'/'+ '${myUserData.data.username}')
//                            .child('${DateTime.now().millisecondsSinceEpoch}.png');
//
//                        final task = firebaseStorageRef.putFile(
//                            widget.file[i], StorageMetadata(contentType: 'image/png'));
//
//                        print('================storage upload complelete==========================');
//
//                        await task.onComplete.then((value) async {
//                          var downloadUrl = await value.ref.getDownloadURL();
//                          userImgUrl[i] = downloadUrl;
//                        });
//                      }else{
//                        userImgUrl[i] = widget.user.profileImg[i];
//                      }
//                    }
                          //사진 업로드 (6개의 배열을 만들어 모두 업데이트함)
//                    firestore.collection("Users").document(myUserData.data.userKey).updateData({"profileImg":userImgUrl});
//                    Navigator.pop(context);
//                    ProfilePage().createState().setValue();

//                      await firestoreProvider.imageUrlUpload(
//                          userKey: widget.user.userKey, imgUrl: widget.userImgUrl);
//                        //첨 회원가입이 아닐경우만 팝
//                        if(data.username != null){
//                          Navigator.pop(context);
//                        }
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Container addInfoBlood(String text, String iconPath, bool textReadOnly) {
    return Container(
      //패딩하느니 그냥 일단 버튼 남겨둠...
      child: FlatButton(
        onPressed: () {
          print('$textReadOnly');
        },
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Image(
                  height: 20,
                  width: 20,
                  image: AssetImage('$iconPath'),
                ),
                Text('혈핵형', style: TextStyle(fontSize: 10),),
              ],
            ),
            Container(
              width: size.width - 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextFormField(
                  controller: bloodKind,
                  readOnly: textReadOnly,
                  decoration: InputDecoration.collapsed(
                    hintText: '혈핵형',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container addInfoJob(String text, String iconPath, bool textReadOnly) {
    return Container(
      child: FlatButton(
        onPressed: () {
          print('혈핵형');
        },
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Image(
                  height: 20,
                  width: 20,
                  image: AssetImage('$iconPath'),
                ),
                Text('직업', style: TextStyle(fontSize: 10),),
              ],
            ),
            Container(
              width: size.width - 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextFormField(
                  controller: job,
                  //controller: _city,
                  readOnly: textReadOnly,
                  decoration: InputDecoration.collapsed(
                    hintText: '직업',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container addInfoLikeBook(String text, String iconPath, bool textReadOnly) {
    return Container(
      child: FlatButton(
        onPressed: () {
          print('혈핵형');
        },
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Image(
                  height: 20,
                  width: 20,
                  image: AssetImage('$iconPath'),
                ),
                Text('책', style: TextStyle(fontSize: 10),),
              ],
            ),
            Container(
              width: size.width - 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextFormField(
                  controller: likeBook,
                  readOnly: textReadOnly,
                  decoration: InputDecoration.collapsed(
                    hintText: '좋아하는책',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container addInfoLikeStar(String text, String iconPath, bool textReadOnly) {
    return Container(
      child: FlatButton(
        onPressed: () {
          print('혈핵형');
        },
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Image(
                  height: 20,
                  width: 20,
                  image: AssetImage('$iconPath'),
                ),
                Text('영화', style: TextStyle(fontSize: 10),),
              ],
            ),
            Container(
              width: size.width - 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextFormField(
                  controller: likeStar,
                  readOnly: textReadOnly,
                  decoration: InputDecoration.collapsed(
                    hintText: '좋아하는연예인',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container addInfoIntroduce(String text, String iconPath, bool textReadOnly) {
    return Container(
      child: FlatButton(
        onPressed: () {
          print('혈핵형');
        },
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Image(
                  height: 20,
                  width: 20,
                  image: AssetImage('$iconPath'),
                ),
                Text('내소개', style: TextStyle(fontSize: 10),),
              ],
            ),
            Container(
              width: size.width - 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextFormField(
                  controller: introduce,
                  readOnly: textReadOnly,
                  decoration: InputDecoration.collapsed(
                    hintText: '자기소개',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
