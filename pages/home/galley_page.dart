import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecting/contstants/firebase_keys.dart';
import 'package:connecting/data/user.dart';
import 'package:connecting/pages/chat/chat_screen.dart';
import 'package:connecting/pages/home/gallery_detail.dart';
import 'package:connecting/pages/home/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:connecting/contstants/constants.dart';
import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/firebase/firebase_storage.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:connecting/widgets/my_progress_indicator.dart';
import 'package:connecting/firebase/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import 'credit_page.dart';

class GalleryPage extends StatefulWidget {

  //나의 기본수신설정
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  Map<String, dynamic> setupRCV;

  List<User> filterUsers = [];
  List<Map<String, dynamic>> machUser = [];
  Geolocator _geoLocator = Geolocator();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if(Provider.of<MyUserData>(context, listen: false).data != null) {
      _getSetUp().then((data) => setState((){setupRCV = data;}));
      super.didChangeDependencies();
    }
  }

  Future<Map<String, dynamic>> _getSetUp() async {
    // await wait(1);
    var setupInfo;
    await Firestore.instance
        .collection(COLLECTION_SETUP)
        .where("username",
        isEqualTo: Provider.of<MyUserData>(context, listen: false).data.username)
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
    if(Provider.of<MyUserData>(context, listen: false).data.myRequestKey != null){
      for(var i = 0; i<Provider.of<MyUserData>(context, listen: false).data.myRequestKey.length; i++){
        machingName.add(Provider.of<MyUserData>(context, listen: false).data.myRequestKey[i]);
      }
    }

    //이미 매칭된거
    if(Provider.of<MyUserData>(context, listen: false).data.friendKey != null) {
      for(var i = 0; i<Provider.of<MyUserData>(context, listen: false).data.friendKey.length; i++){
        machingName.add(Provider.of<MyUserData>(context, listen: false).data.friendKey[i]);
      }
    }

    //요청받은거
    if(Provider.of<MyUserData>(context, listen: false).data.friendRequestKey != null) {
      for(var i = 0; i<Provider.of<MyUserData>(context, listen: false).data.friendRequestKey.length; i++){
        machingName.add(Provider.of<MyUserData>(context, listen: false).data.friendRequestKey[i]);
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
    print('55555555555555555555555555555555555');
    setupRCV.clear();
    filterUsers.clear();
    machUser.clear();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarColor: Colors.pink[300],
            //systemNavigationBarColor: Colors.pink[300],
            statusBarIconBrightness: Brightness.dark
        )
    );
    //빌더시 매칭(요청)된 유저들을 가져옴
    getMachingUser();

    return setupRCV == null ? MyProgressIndicator() : buildScaffold();
  }

  Scaffold buildScaffold() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamProvider<List<User>>.value(
        value: firestoreProvider.fetchAllUsersFilter(Provider.of<MyUserData>(context).data.username, setupRCV),
        child: Consumer<List<User>>(
          builder: (context, userList, child){
            filterUsers.clear();
            if(userList != null){
              _filtering(userList); ///필터링~~~~~~~~
            }
            return filterUsers == null ? MyProgressIndicator() : SafeArea(
              child: Column(
                children: <Widget>[
                  _appBar('GALLARY'),
                  Divider(
                    height: 1,
                    color: Colors.grey[900],
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount:MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
                      shrinkWrap: true,
                      children: filterUsers.map((user) {
                        //_getDistance(user, Provider.of<MyUserData>(context).data);
                        //distance = await _geoLocator.distanceBetween(Provider.of<MyUserData>(context).data.lat, Provider.of<MyUserData>(context).data.long, user.lat, user.long);
                        return FutureProvider.value(
                          value: _getDistance(user, Provider.of<MyUserData>(context).data),
                          child: Consumer<double>(
                            builder: (context, distance, child){
                              //유저와의 거리 유효체크 및 거리km로 변환
                              if(distance == null) distance = 0.0;
                              distance = (distance.round() / 1000).round().toDouble();
                              return Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: InkWell(
                                  splashColor: Colors.yellow,
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (BuildContext context) => UserProfilePage(
                                          user: user,
                                        )));
                                  },
                                  child: Material(
                                    clipBehavior: Clip.antiAlias,
                                    elevation: 0.0,
                                    //borderRadius: BorderRadius.circular(20),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: <Widget>[
                                        //imageStack(user.profileImg1),
                                        user.profileImg1.isEmpty || user.profileImg1 == null ?
                                        Image.asset('assets/placeholder.png') : Image.network(user.profileImg1, fit: BoxFit.cover,),
                                        user.username == null ? Center(child: Text('N/A')):descStack(user, distance, context),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );}
                      ).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<User> _filtering(List<User> users) {
    var existYn = 0;
    for (var i = 0; i < users.length; i++) {
      if (users[i].age >= setupRCV['beginAge'] &&
          users[i].age <= setupRCV['endAge'] &&
          users[i].tall >= setupRCV['beginTall'] &&
          users[i].tall <= setupRCV['endTall']) {
        for(var j = 0; j<machUser.length; j++){
          if(users[i].username == machUser[j]['username']){
            existYn = 1;
            continue;
          }
        }
        if(existYn == 0){
          filterUsers.add(users[i]);
        }
        existYn = 0;
      }
    }
  }

  Future<double> _getDistance(User galleryUser, User myuser) async {
    var _geoLocator = Geolocator();
    double userLat = galleryUser.lat;
    double userLong = galleryUser.long;
    double myLat = myuser.lat;
    double myLong = myuser.long;

    return await _geoLocator.distanceBetween(myLat, myLong, userLat, userLong);
  }

  Widget imageStack(String img) => Image.network(
    img,
    fit: BoxFit.cover,
  );

  Widget descStack(User user, double distance, BuildContext context) => Positioned(
    bottom: 0.0,
    left: 0.0,
    right: 0.0,
    child: Container(
      height: 40,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black])),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8,top:12.0),
                  child: Text(
                    user.username,
                    //softWrap: true,
                    //overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0, top: 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Image(
                        width: 8,
                        height: 8,
                        color: user.gender == 1 ? Colors.blueAccent : Colors.redAccent,
                        image: user.gender == 1
                            ? AssetImage('assets/male.png')
                            : AssetImage('assets/female.png'),
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        '${user.age}',
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
//            Expanded(
//              child: Text(
//                distance.toString(),
//                softWrap: true,
//                overflow: TextOverflow.ellipsis,
//                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
//              ),
//            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top:16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(distance.round() == 0 ? '-': '${distance.round().toString()}',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.only(top:2.0),
                      child: Text(' Km',
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: 8.0,
                              fontWeight: FontWeight.bold)),
                    ),
                    InkWell(
                       onTap: (){
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
                                   CircleAvatar(
                                     radius: 110,
                                     backgroundImage: user.profileImg1.isEmpty || user.profileImg1 == null ?
                                     AssetImage('assets/placeholder.png') : NetworkImage(user.profileImg1,),
                                   ),
                                   Padding(
                                     padding: EdgeInsets.symmetric(vertical: 10),
                                   ),
                                   _listTileOntap('쪽지', 1, user, Provider.of<MyUserData>(context, listen: false).data, context),
                                   Padding(
                                     padding: EdgeInsets.symmetric(vertical: 4),
                                   ),
                                   _listTileOntap('데이트 신청', 2, user, Provider.of<MyUserData>(context, listen: false).data, context),
                                 ],
                               ),
                             ),
                           ),
                         );
                       },
                      child: Image(
                        image: AssetImage('assets/menu.png'),
                        color: Colors.white60,
                        height: 20,
                        width: 32,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );

  Container _listTileOntap(String text, int index, User OtherUser, User myUserData, BuildContext context) {
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
              image: AssetImage(index == 1 ? 'assets/loveletter.png' : 'assets/romance.png' ),
            ),

          ],
        ),
        onPressed: () async {
          //대화하기
          if(index == 1){
            if(myUserData.talkCount == 0){
              Navigator.pop(context);
              showDialog(
                context: context,
                child: AlertDialog(
                  title: Text("공지"),
                  content: Text("금일 쪽지신청 수량이 모두 소진되었습니다.",style: TextStyle(fontSize: 13),),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("편지지 구매"),
                      onPressed: (){
                        //결제페이지로 이동
//                        Navigator.pushReplacement(
//                            context, MaterialPageRoute(builder: (context) =>
//                            CreditPage(myUser: myUserData)));
                      },
                    ),
                  ],
                ),
              );
            } else {
              //쪽지 1개 소진
              await firestoreProvider.minusTalkCount(myUserData);

              //대화키 생성
              await firestoreProvider.roomIDUpdate(myUserData, OtherUser);
              List<String> msgKey = List(2);
              msgKey[0] = myUserData.username;
              msgKey[1] = OtherUser.username;

              //채팅시작 (해당 다이얼로그는 없애고 페이지 띄우기)
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) =>
                  ChatScreen(myUser: myUserData,
                      otherUser: OtherUser,
                      roomId: msgKey)));
            }
          //친구신청하기
          }else{
            await firestoreProvider.requestFriend(
                myUserData, OtherUser
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _appBar(String title) {
    return Container(
      color: Colors.pink[300],
      width: double.infinity,
      height: 50,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '$title',
            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 20, fontFamily: 'lotte'),
          ),
        ],
      ),
    );
  }
}


