import 'package:connecting/contstants/constants.dart';
import 'package:connecting/data/message.dart';
import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/data/user.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:connecting/pages/chat/chat_screen.dart';
import 'package:connecting/pages/home/user_profile.dart';
import 'package:connecting/widgets/side_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:getflutter/getflutter.dart';
import 'package:provider/provider.dart';

class MyChatPage extends StatefulWidget {
  @override
  _MyChatPageState createState() => _MyChatPageState();
}

class _MyChatPageState extends State<MyChatPage> with SingleTickerProviderStateMixin {

  AnimationController _animationController;
  bool _menuOpened = false;
  double menuWidth;
  int duration = 300;

  int cnt = 0;
  int totalCount = 0;
  int userCount = 0;

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

  @override
  Widget build(BuildContext context) {
    menuWidth = size.width / 1.5;
    return Scaffold(
      backgroundColor: Colors.white,
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
        _appBar('TALK'),
        Divider(
          height: 1,
          color: Colors.grey[900],
        ),
//        SizedBox(
//          height: 7,
//        ),
        Expanded(
          child: StreamProvider<List<User>>.value(
            value: firestoreProvider.fetchMyChatUsers(Provider.of<MyUserData>(context).data.roomId),
            child: Consumer<List<User>>(
              builder: (context, userList, child) {
                return userList == null ? Container() : MediaQuery.removePadding(
                  context: context,
                  removeTop: true, //color: Colors.blueGrey,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      User user = userList[index];
                      return _item(user);
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        height: 1,
                        color: Colors.red,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _appBar(String title) {
    return Container(
      width: double.infinity,
      color: Colors.pink[300],
      height: 50,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
              '$title',
              style: TextStyle(fontWeight: FontWeight.w100, fontSize:20, fontFamily: 'lotte'),
            ),
          ),
//          IconButton(
//            icon: AnimatedIcon(
//              icon: AnimatedIcons.menu_close,
//              progress: _animationController,
//              semanticLabel: 'Show Menu',
//            ),
//            onPressed: () {
//              _menuOpened
//                  ? _animationController.reverse()
//                  : _animationController.forward();
//              setState(() {
//                _menuOpened = !_menuOpened;
//              });
//            },
//          ),
        ],
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
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListTile(
          contentPadding: EdgeInsets.only(left: 8.0),
          /// Dialog User
          onTap: () {
            showDialog(
              context: context,
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                content: Container(
                  height: 320,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      GFAvatar(
                        size: 140,
                        shape: GFAvatarShape.standard,
                        backgroundColor: Colors.white,
                        backgroundImage: user.profileImg1.isEmpty || user.profileImg1 == null ?
                        AssetImage('assets/placeholder.png') : NetworkImage(user.profileImg1,),
                      ),
//                      CircleAvatar(
//                        radius: 110,
//                        backgroundImage: user.profileImg1.isEmpty || user.profileImg1 == null ?
//                        AssetImage('assets/placeholder.png') : NetworkImage(user.profileImg1,),
//                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      _listTileOntap('대화하기', 1, user, myUserData),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                      ),
                      _listTileOntap('대화삭제', 2, user, myUserData),
                    ],
                  ),
                ),
              ),
            );
          },

          //유저상세페이지로 점프
          leading: Container(
            child: GFAvatar(
              shape: GFAvatarShape.standard,
              size: 40,
              backgroundColor: Colors.white,
              backgroundImage: user.profileImg1.isEmpty || user.profileImg1 == null ?
              AssetImage('assets/placeholder.png') : NetworkImage(user.profileImg1,),
            ),
          ),
          title: Text(user.username, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black),),
          subtitle: Text('${user.age}', style: TextStyle(fontSize:12, fontWeight: FontWeight.bold, color: Colors.grey[700]),),
          trailing: StreamProvider<List<Message>>.value(
            value: firestoreProvider.fetchNotReadMsg(Provider.of<MyUserData>(context).data.username),
            child: Consumer<List<Message>>(
              builder: (context, msg, child){
                //초기화
                cnt = 0;
                totalCount = 0;
                //나한테 수신된 메시지 전체를 가져와서 그중에 안읽은거만 합계를 구함
                if(msg != null) {
                  for (int i = 0; i < msg.length; i++) {
                    if (user.username == msg[i].sender) {
                      cnt = msg[i].readYN;
                      totalCount = totalCount + cnt;
                    }
                  }
                }
                return totalCount == 0 ? Text('') : Padding(
                  padding: const EdgeInsets.only(right:15.0),
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$totalCount',
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }

  Container _listTileOntap(String text, int index, User otherUser, MyUserData myUserData) {
    return Container(
      child: RaisedButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        color: Colors.cyanAccent,
        child: Text('$text', style: TextStyle(fontSize: 10)),
        onPressed: () async {

          //대화하기
          if(index == 1){

//            String roomId;
//
//            if(myUserData.data.userKey.hashCode > otherUser.userKey.hashCode){
//              roomId = myUserData.data.userKey + otherUser.userKey;
//            }else{
//              roomId = otherUser.userKey + myUserData.data.userKey;
//            }

            //대화키 생성
            List<String> msgKey = List(2);
            msgKey[0] = myUserData.data.username;
            msgKey[1] = otherUser.username;

            //채팅창으로 이동
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                ChatScreen(myUser: myUserData.data, otherUser: otherUser, roomId: msgKey)));

          //대화삭제하기
          }else{

//            String roomId;
//
//            if(myUserData.data.userKey.hashCode > otherUser.userKey.hashCode){
//              roomId = myUserData.data.userKey + otherUser.userKey;
//            }else{
//              roomId = otherUser.userKey + myUserData.data.userKey;
//            }

            await firestoreProvider.deleteRoomID(myUserData.data, otherUser);
            Navigator.pop(context);
          }



          //Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatScreen()));
        },
      ),
    );
  }
}
