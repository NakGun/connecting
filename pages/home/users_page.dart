import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecting/contstants/constants.dart';
import 'package:connecting/contstants/firebase_keys.dart';
import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/data/setup_rcv.dart';
import 'package:connecting/data/user.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:connecting/pages/chat/chat_screen.dart';
import 'package:connecting/pages/home/credit_page.dart';
import 'package:connecting/pages/home/user_profile.dart';
import 'package:connecting/widgets/my_progress_indicator.dart';
import 'package:connecting/widgets/side_menu.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/getflutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage>
    with SingleTickerProviderStateMixin {
  final List<String> users = List.generate(10, (generator) {
    return 'user $generator';
  });

  AnimationController _animationController;
  bool _menuOpened = false;
  double menuWidth;
  int duration = 300;

  //나의 기본수신설정
  Map<String, dynamic> setupRCV;
  List<User> filterUsers = []; //필터된 유저리스트
  List<Map<String, dynamic>> machUser = [];

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: duration));
    //_getSetUp().then((data) => setState((){setupRCV = data;}));
    super.initState();
  }

//  Future wait(int seconds){
//    return new Future.delayed(Duration(seconds: seconds), () => {});
//  }
  @override
  void didChangeDependencies() {
    if (Provider
        .of<MyUserData>(context, listen: false)
        .data != null) {
      _getSetUp().then((data) =>
          setState(() {
            setupRCV = data;
          }));
      super.didChangeDependencies();
    }
  }

  Future<Map<String, dynamic>> _getSetUp() async {
    // await wait(1);
    var setupInfo;
    await Firestore.instance
        .collection(COLLECTION_SETUP)
        .where("username",
        isEqualTo: Provider
            .of<MyUserData>(context, listen: false)
            .data
            .username)
        .getDocuments()
        .then((ds) {
      ds.documents.forEach((doc) {
        setupInfo = doc.data;
        //setupRCV = doc.data;
        //print('setupRCV init : ${setupRCV}');
      });
    });
    return setupInfo;
  }

  Future<List<Map<String, dynamic>>> getMachingUser() async {
    //에러나서 한개 넣음....
    List<String> machingName = ['chnaan@hanmail.net'];
    //내가요청한거
    if (Provider
        .of<MyUserData>(context, listen: false)
        .data
        .myRequestKey != null) {
      for (var i = 0; i < Provider
          .of<MyUserData>(context, listen: false)
          .data
          .myRequestKey
          .length; i++) {
        machingName.add(Provider
            .of<MyUserData>(context, listen: false)
            .data
            .myRequestKey[i]);
      }
    }

    //이미 매칭된거
    if (Provider
        .of<MyUserData>(context, listen: false)
        .data
        .friendKey != null) {
      for (var i = 0; i < Provider
          .of<MyUserData>(context, listen: false)
          .data
          .friendKey
          .length; i++) {
        machingName.add(Provider
            .of<MyUserData>(context, listen: false)
            .data
            .friendKey[i]);
      }
    }

    //요청받은거
    if (Provider
        .of<MyUserData>(context, listen: false)
        .data
        .friendRequestKey != null) {
      for (var i = 0; i < Provider
          .of<MyUserData>(context, listen: false)
          .data
          .friendRequestKey
          .length; i++) {
        machingName.add(Provider
            .of<MyUserData>(context, listen: false)
            .data
            .friendRequestKey[i]);
      }
    }

    await Firestore.instance
        .collection(COLLECTION_USERS)
        .where("username", whereIn: machingName)
        .getDocuments()
        .then((ds) {
      ds.documents.forEach((doc) {
        machUser.add(doc.data);
      });
    });
    return machUser;
  }

  @override
  void dispose() {
    _animationController.dispose();
    setupRCV.clear();
    filterUsers.clear();
    machUser.clear();
    super.dispose();
  }

//  @override
//  Widget build(BuildContext context) {
//    menuWidth = size.width / 1.5;
//    return FutureProvider<Map<String, dynamic>>(
//      create: _getSetUp(),
//      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {  // AsyncSnapshot<Your object type>
//        if( snapshot.connectionState == ConnectionState.waiting){
//          return  Center(child: Text('Please wait its loading...'));
//        }else{
//          if (snapshot.hasError)
//            return Center(child: Text('Error: ${snapshot.error}'));
//          else
//            return buildScaffold();  // snapshot.data  :- get your object which is pass from your downloadData() function
//        }
//      },
//    );
//  }


  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarColor: Colors.pink[300],
            systemNavigationBarColor: Colors.black,
            statusBarIconBrightness: Brightness.dark
        )
    );
    //빌더시 매칭(요청)된 유저들을 가져옴
    getMachingUser();

    menuWidth = size.width / 1.5;
    return setupRCV == null ? MyProgressIndicator() : buildScaffold();
  }

  Scaffold buildScaffold() {
    return Scaffold(
      //backgroundColor: Colors.white70,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            AnimatedContainer(
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: duration),
                transform: Matrix4.translationValues(
                    _menuOpened ? -menuWidth : 0, 0, 0),
                child: getUserList()),
//            _sideMenu(),
          ],
        ),
      ),
    );
  }

  Column getUserList() {
    return Column(
      children: <Widget>[
        _appBar('Connecting'),
//        Divider(
//          height: 1,
//          color: Colors.grey[900],
//        ),
//        SizedBox(
//          height: 7,
//        ),
        Container(
          height: 1,
          color: Colors.limeAccent,
        ),
        Expanded(
          child: StreamProvider<List<User>>.value(
            value: firestoreProvider.fetchAllUsersFilter(
                Provider
                    .of<MyUserData>(context)
                    .data
                    .username, setupRCV),
            child: Consumer<List<User>>(
              builder: (context, userList, child) {
                //매칭되었거나 요청중인 유저 필터링
                //내 설정값에 따라 필터링
                filterUsers.clear();

                ///필터링~~~~~~~~
                if (userList != null) {
                  //내 셋팅 and 매칭으로 필터...아 쿼리 안되니까 죽겠넹
                  _filtering(userList);
                }

                return filterUsers == null
                    ? Container()
                    : Stack(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 2.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              width: 0.0, color: Color(0xFFFFDFDFDF)),
                          left: BorderSide(
                              width: 0.0, color: Color(0xFFFFDFDFDF)),
                          right: BorderSide(
                              width: 0.0, color: Color(0xFFFF7F7F7F)),
                          bottom: BorderSide(
                              width: 0.0, color: Color(0xFFFF7F7F7F)),
                        ),
                        color: Color(0xFFBFBFBF),
                      ),
                      //color: Colors.blueGrey,
                    ),
                    Positioned(
                      top: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Material(
                        clipBehavior: Clip.antiAlias,
                        //elevation: 5.0,
                        borderRadius: BorderRadius.only(bottomLeft: Radius
                            .circular(50), bottomRight: Radius.circular(50)),
                        child: Container(
                          height: 220,
                          width: size.width,
                          color: Colors.pink[300],
                        ),
                      ),
                    ),
                    Container(
                      //color: Colors.blueGrey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListView.builder(
                          padding: EdgeInsets.all(0.0),
                          itemCount: filterUsers == null ? 0 : filterUsers
                              .length,
                          itemBuilder: (context, index) {
                            User user = filterUsers[index];

                            return _item(user);
                          },
//                        separatorBuilder: (context, index) {
//                          return Divider(
//                            thickness: 0,
//                            color: Colors.grey[200],
//                          );
//                        },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<User> _filtering(List<User> users) {
    var existYn = 0;
    for (var i = 0; i < users.length; i++) {
      if (users[i].age >= setupRCV['beginAge'] &&
          users[i].age <= setupRCV['endAge'] &&
          users[i].tall >= setupRCV['beginTall'] &&
          users[i].tall <= setupRCV['endTall']) {
        for (var j = 0; j < machUser.length; j++) {
          if (users[i].username == machUser[j]['username']) {
            existYn = 1;
            continue;
          }
        }
        if (existYn == 0) {
          filterUsers.add(users[i]);
        }
        existYn = 0;
      }
    }
  }

  Widget _appBar(String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.pink[300],
      ),
      width: double.infinity,
      height: 50,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Text(
          '$title',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w100, fontFamily: 'lotte'),
        ),
      ),
    );
  }

//  Widget _sideMenu() {
//    return AnimatedContainer(
//      curve: Curves.easeInOut,
//      color: Colors.grey[200],
//      duration: Duration(milliseconds: duration),
//      transform: Matrix4.translationValues(
//          _menuOpened
//              ? size.width - menuWidth
//              : size.width,
//          0,
//          0),
//      child: SafeArea(
//        child: SizedBox(
//          width: menuWidth,
//          child: ProfileSideMenu(),
//        ),
//      ),
//    );
//  }

  //유저리스트 메인화면
  Widget _item(User user) {
    return Consumer<MyUserData>(builder: (context, myUserData, child) {
      //네모로 하고 싶을경우 row를 사용해야 할듯..
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: ListTile(
            // dense: true,
            /// Dialog User
            contentPadding: EdgeInsets.only(left: 8.0),
            onTap: () {
              ///TODO show Dialog
              showDialog(
                context: context,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  content: Container(
                    height: 320,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: CircleAvatar(
//                            child: Image(
//                              image: user.profileImg1.isEmpty || user.profileImg1 == null ?
//                              AssetImage('assets/placeholder.png') : NetworkImage(user.profileImg1,),
//                            ),
                            backgroundColor: Colors.white60,
                            radius: 110,
                            backgroundImage: user.profileImg1.isEmpty ||
                                user.profileImg1 == null ?
                            AssetImage('assets/placeholder.png') : NetworkImage(
                              user.profileImg1,),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        _listTileOntap('쪽지', 1, user, myUserData),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                        ),
                        _listTileOntap('데이트 신청', 2, user, myUserData),
                      ],
                    ),
                  ),
                ),
              );
            },

            //유저상세페이지로 점프
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        UserProfilePage(
                          user: user,
                        )));
              },
              child: Container(
                child: GFAvatar(
                  backgroundColor: Colors.white,
                  shape: GFAvatarShape.standard,
                  backgroundImage:
                  user.profileImg1.isEmpty || user.profileImg1 == null
                      ? AssetImage('assets/placeholder.png')
                      : NetworkImage(
                    user.profileImg1,
                  ),
                ),
              ),
            ),
            title: Text(user.username),
            subtitle: Text('${user.gender == 1 ? '남자' : '여자'}',
              style: TextStyle(fontSize: 14),),
          ),
        ),
      );
    });
  }

  Container _listTileOntap(String text, int index, User OtherUser,
      MyUserData myUserData) {
    return Container(
      child: RaisedButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        color: Colors.cyanAccent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$text', style: TextStyle(fontSize: 10)),
            SizedBox(width: 5,),
            Image(
              height: 20,
              width: 20,
              image: AssetImage(
                  index == 1 ? 'assets/loveletter.png' : 'assets/romance.png'),
            ),

          ],
        ),
        onPressed: () async {
          //대화하기
          if (index == 1) {
            if (myUserData.data.talkCount == 0) {
              Navigator.pop(context);
              showDialog(
                context: context,
                child: AlertDialog(
                  title: Text("공지"),
                  content: Text(
                    "금일 쪽지신청 수량이 모두 소진되었습니다.", style: TextStyle(fontSize: 13),),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("편지지 구매"),
                      onPressed: () {
                        //결제페이지로 이동
//                        Navigator.pushReplacement(
//                            context, MaterialPageRoute(builder: (context) =>
//                            CreditPage(myUser: myUserData.data)));
                      },
                    ),
                  ],
                ),
              );
            } else {
              //쪽지 1개 소진
              await firestoreProvider.minusTalkCount(myUserData.data);

              //대화키 생성
              await firestoreProvider.roomIDUpdate(myUserData.data, OtherUser);
              List<String> msgKey = List(2);
              msgKey[0] = myUserData.data.username;
              msgKey[1] = OtherUser.username;

              //채팅시작 (해당 다이얼로그는 없애고 페이지 띄우기)
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) =>
                  ChatScreen(myUser: myUserData.data,
                      otherUser: OtherUser,
                      roomId: msgKey)));
              //친구신청하기
            }
          } else {
            await firestoreProvider.requestFriend(
                myUserData.data, OtherUser
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
