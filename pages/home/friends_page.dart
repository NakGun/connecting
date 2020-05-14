import 'package:connecting/contstants/constants.dart';
import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/data/user.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:connecting/pages/chat/chat_screen.dart';
import 'package:connecting/pages/home/home_page.dart';
import 'package:connecting/pages/home/user_profile.dart';
import 'package:connecting/widgets/side_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
//import 'package:url_launcher/url_launcher.dart';

enum TabIconGridSelected { friend, receive, wish }

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  final List<String> users = List.generate(10, (generator) {
    return 'user $generator';
  });

  AlignmentGeometry tabAlign = Alignment.centerLeft;
  TabIconGridSelected _tabIconGridSelected = TabIconGridSelected.friend;

  AnimationController _animationController;
  bool _menuOpened = false;
  double menuWidth;
  int duration = 300;

  //친구와 수락페이지를 왔다갔다 하기위한 값
  double _gridMargin = 0;
  double _myImgGridMargin = size.width;
  double _myWishGridMargin = size.width * 2;

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
    menuWidth = MediaQuery.of(context).size.width / 1.5;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            //초기화면설정 애니매이션
            AnimatedContainer(
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: duration),
              transform:
                  Matrix4.translationValues(_menuOpened ? -menuWidth : 0, 0, 0),
              child: getUserList(),
            ),
//            _sideMenu(),
          ],
        ),
      ),
    );
  }

  Widget getUserList() {
    return Column(
      children: <Widget>[
        //헤더
        _appBar(),
        Divider(
          height: 1,
          color: Colors.grey[900],
        ),

        //친구/수릭 토글아이콘
        _getTabIconButtons,
        _getAnimatedSelectedBar,
//        SizedBox(
//          height: 7,
//        ),
        //친구/수락 페이지
        Expanded(
          child: Container(
            //color: Colors.blueGrey,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Stack(
                children: <Widget>[
                  AnimatedContainer(
                    //height: MediaQuery.of(context).size.height - 200,
                    transform: Matrix4.translationValues(_gridMargin, 0, 0),
                    duration: Duration(milliseconds: duration),
                    curve: Curves.easeInOut,
                    child: _friendList(),
                  ),
                  AnimatedContainer(
                    //height: MediaQuery.of(context).size.height - 200,
                    transform: Matrix4.translationValues(_myImgGridMargin, 0, 0),
                    duration: Duration(milliseconds: duration),
                    curve: Curves.easeInOut,
                    child: _friendRequestList(),
                  ),
                  AnimatedContainer(
                    //height: MediaQuery.of(context).size.height - 200,
                    transform: Matrix4.translationValues(_myWishGridMargin, 0, 0),
                    duration: Duration(milliseconds: duration),
                    curve: Curves.easeInOut,
                    child: _myRequestList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _friendList() {
    return StreamProvider<List<User>>.value(
      value: firestoreProvider.fetchFriendList(Provider.of<MyUserData>(context).data.friendKey),
      child: Consumer<List<User>>(
        builder: (context, userList, child) {
          return userList == null ? Container() : ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.all(0.0),
            itemCount: userList == null ? 0 : Provider.of<MyUserData>(context).data.friendKey.length,
            itemBuilder: (context, index) {
              User user = userList[index];
              return _item(user);
            },
            separatorBuilder: (context, index) {
              return Divider(
                thickness: 1,
                color: Colors.red[200],
              );
            },
          );
        },
      ),
    );
  }

  Widget _friendRequestList() {
    return StreamProvider<List<User>>.value(
      value: firestoreProvider.fetchRequestUsers(Provider.of<MyUserData>(context).data.friendRequestKey),
      child: Consumer<List<User>>(
        builder: (context, userList, child) {
          return ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.all(0.0),
            itemCount: userList == null ? 0 : Provider.of<MyUserData>(context).data.friendRequestKey.length,
            itemBuilder: (context, index) {
              User user = userList[index];
              return _item(user);
            },
            separatorBuilder: (context, index) {
              return Divider(
                thickness: 1,
                color: Colors.grey[200],
              );
            },
          );
        },
      ),
    );
  }

  Widget _myRequestList() {
    return StreamProvider<List<User>>.value(
      value: firestoreProvider.fetchRequestUsers(Provider.of<MyUserData>(context).data.myRequestKey),
      child: Consumer<List<User>>(
        builder: (context, userList, child) {
          //print('userList ==> ${userList.length}');
          return ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.all(0.0),
            itemCount: userList == null ? 0 : Provider.of<MyUserData>(context).data.myRequestKey.length,
            itemBuilder: (context, index) {
              User user = userList[index];
              return _item(user);
            },
            separatorBuilder: (context, index) {
              return Divider(
                thickness: 1,
                color: Colors.grey[200],
              );
            },
          );
        },
      ),
    );
  }

  Widget _appBar() {
    return Container(
      color: Colors.pink[300],
      width: double.infinity,
      height: 50,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'MATCH',
            style: TextStyle(fontWeight: FontWeight.w100, fontSize:20, fontFamily: 'lotte'),
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
//              ? MediaQuery.of(context).size.width - menuWidth
//              : MediaQuery.of(context).size.width,
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

  Widget _item(User user) {
    //print('user ===> ${user}');
    return Consumer<MyUserData>(builder: (context, myUserData, child) {
      return ListTile(
        onLongPress: (){
          setState(() {
            ///친구탭 아이템 클릭
            if (_gridMargin == 0) {
              showDialog(
                context: context,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  content: Container(
                    child: RaisedButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      color: Colors.cyanAccent,
                      child: Text('${user.username} 을[를] 친구에서 삭제하시겠습니까?',
                          style: TextStyle(fontSize: 10)),
                      onPressed: () async {
                        await firestoreProvider.deleteFriend(
                            myUserData.data.userKey, user.username);
                        Navigator.of(context).pop();
                        myUserData.setNewStatus(MyUserDataStatus.progress);
                      },
                    ),
                  ),
                ),
              );

              ///친구요청 탭 아이템 클릭
            } else {

            }
          });
        },
        onTap: () async {
          if (_gridMargin == 0) {
            await firestoreProvider.roomIDUpdate(myUserData.data, user);

            //대화키 생성
            List<String> msgKey = List(2);
            msgKey[0] = myUserData.data.username;
            msgKey[1] = user.username;
            //채팅시작 (해당 다이얼로그는 없애고 페이지 띄우기)
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                ChatScreen(
                    myUser: myUserData.data, otherUser: user, roomId: msgKey)));
          }
        },
        leading: GestureDetector(
          onTap: (){
            //상세페이지로 점프
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    UserProfilePage(
                      user: user,
                    )));
          },
          child: CircleAvatar(
            radius: 30,
            backgroundImage: user.profileImg1.isEmpty || user.profileImg1 == null
                ? AssetImage('assets/placeholder.png')
                : NetworkImage(
                    user.profileImg1,
                  ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical:20.0),
          child: Text(user.username),
        ),
        //subtitle: Text(user.email),
        trailing: GestureDetector(
          onTap: () async {
            ///통화하기
            if (_gridMargin == 0) {
              await firestoreProvider.roomIDUpdate(myUserData.data, user);

              //대화키 생성
              List<String> msgKey = List(2);
              msgKey[0] = myUserData.data.username;
              msgKey[1] = user.username;
              //채팅시작 (해당 다이얼로그는 없애고 페이지 띄우기)
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  ChatScreen(
                      myUser: myUserData.data, otherUser: user, roomId: msgKey)));
            ///수락하기
            } else {
              setState(() {
                firestoreProvider.acceptFriend(myUserData.data, user);
                //myUserData.setNewStatus(MyUserDataStatus.progress);
              });
            }
          },
          child: _myWishGridMargin == 0 ? SizedBox() : Container(
            height: 25,
            width: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.black54, width: 0.5),
                borderRadius: BorderRadius.circular(6)),
            child: Text(
              _gridMargin == 0 ? '대화하기' : _gridMargin == -size.width ? '수락하기' : '',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget get _getTabIconButtons => Row(
        children: <Widget>[
          Expanded(
            child: FlatButton.icon(
              icon: ImageIcon(
                AssetImage('assets/friends.png'),
                color: _tabIconGridSelected == TabIconGridSelected.friend ? Colors.black : Colors.black26,
              ),
              label: Text(
                'Date',
                style: TextStyle(fontSize: 10),
              ),
              onPressed: () {
                _setTab(1);
              },
            ),
          ),
          Expanded(
            child: FlatButton.icon(
              icon: ImageIcon(
                AssetImage('assets/trust.png'),
                color: _tabIconGridSelected == TabIconGridSelected.receive ? Colors.black : Colors.black26,
              ),
              label: Text(
                'Date+',
                style: TextStyle(fontSize: 10),
              ),
              onPressed: () {
                _setTab(2);
              },
            ),
          ),
          Expanded(
            child: FlatButton.icon(
              icon: ImageIcon(
                AssetImage('assets/selected_wish.png'),
                color: _tabIconGridSelected == TabIconGridSelected.wish ? Colors.black : Colors.black26,
              ),
              label: Text(
                'Wish',
                style: TextStyle(fontSize: 10),
              ),
              onPressed: () {
                _setTab(3);
              },
            ),
          ),
        ],
      );

  Widget get _getAnimatedSelectedBar => AnimatedContainer(
        alignment: tabAlign,
        duration: Duration(milliseconds: duration),
        curve: Curves.easeInOut,
        color: Colors.transparent,
        height: 3,
        width: MediaQuery.of(context).size.width,
        child: Container(
          height: 3,
          width: MediaQuery.of(context).size.width / 3,
          color: Colors.yellow,
        ),
      );

  Widget _setTab(int tabCount) {
    setState(() {
      if (tabCount == 1) {
        this.tabAlign = Alignment.centerLeft;
        this._tabIconGridSelected = TabIconGridSelected.friend;
        this._gridMargin = 0;
        this._myImgGridMargin = size.width;
        this._myWishGridMargin = size.width * 2;
      } else if (tabCount == 2) {
        this.tabAlign = Alignment.center;
        this._tabIconGridSelected = TabIconGridSelected.receive;
        this._gridMargin = -size.width;
        this._myImgGridMargin = 0;
        this._myWishGridMargin = size.width;
      } else {
        this.tabAlign = Alignment.centerRight;
        this._tabIconGridSelected = TabIconGridSelected.wish;
        this._gridMargin = -size.width * 2;
        this._myImgGridMargin = -size.width;
        this._myWishGridMargin = 0;
      }
    });
  }

  //전화걸기 기능
//  void _phoneCall(String number) async {
//    if (await canLaunch(number)) {
//      await launch((number));
//    } else {
//      throw 'Fail!!';
//    }
//  }
}
