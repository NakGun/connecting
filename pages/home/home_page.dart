import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecting/contstants/constants.dart';
import 'package:connecting/data/message.dart';
import 'package:connecting/data/my_message_data.dart';
import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/data/user.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:connecting/pages/home/friends_page.dart';
import 'package:connecting/pages/home/galley_page.dart';
import 'package:connecting/pages/home/profile_page.dart';
import 'package:connecting/pages/home/users_page.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'my_chat_page.dart';

final _firestore = Firestore.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  String addressJSON = '';
  int cnt = 0;
  int totalCount = 0;

  /** 위치정보 */
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;


  static List<Widget> _widgetOptions = [
    UsersPage(),
    GalleryPage(),
    MyChatPage(),
    FriendsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  //앱 접속시 유저 위치 가져와서 업데이트
  void setPosition (BuildContext context) async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    print('_locationData : ${_locationData.latitude}');
    print('_locationData : ${_locationData.longitude}');

    //위치정보 업로드
    final Map<String, dynamic> userData =
    User.getMapForCreatePosition(
        _locationData.latitude,
        _locationData.longitude);
    await firestoreProvider.userPositionUpdate(
        Provider.of<MyUserData>(context, listen: false).data.userKey, userData);
    print('update : ${userData}');
  }
//  void didChangeDependencies() {
//    //안 읽은 메시지 합계를 구함
//    int readCount = 0;
//    _getReadCount(readCount).then((data){
//      print('data-----------------${data}');
//      setState(() {
//        totalCount = data;
//      });
//    });
//    super.didChangeDependencies();
//  }
//
//  Future<int> _getReadCount(int readCount) async {
//    await _firestore
//        .collection("Message")
//        .where("receiver", isEqualTo: Provider.of<MyUserData>(context).data.username)
//        .getDocuments()
//        .then((ds) async {
//      await ds.documents.forEach((doc) async {
//        int count = await doc.data['readYN'];
//        readCount = readCount + count;
//      });
//    });
//    return readCount;
//  }

  //광고 object
  BannerAd myBanner;
  InterstitialAd myInterstitial;

  @override
  Widget build(BuildContext context) {
//    //테스트 디바이스 설정
//    List<String> testDeviceIds = ['A46C7C415106C4522A61FD2FFC201887'];
//
//    //광고
//    FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-9139460788663966~8085011297');
//
//    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//      keywords: <String>['game', 'lol'],
//      contentUrl: 'https://flutter.io',
//      childDirected: false,
//      testDevices: testDeviceIds, // 출시시 내 테스트폰 id를 넣어야지 불상사가 안생긴댄다..
//    );
//
//    BannerAd createBn() => BannerAd(
//      adUnitId: 'ca-app-pub-9139460788663966/8172162276',
//      size: AdSize.smartBanner,
//      targetingInfo: targetingInfo,
//      listener: (MobileAdEvent event) {
//        print("BannerAd event is $event");
//      },
//    );
//
//    InterstitialAd createAll() => InterstitialAd(
//      adUnitId: 'ca-app-pub-9139460788663966/5071356211',
//      targetingInfo: targetingInfo,
//      listener: (MobileAdEvent event) {
//        print("InterstitialAd event is $event");
//      },
//    );
//
//    if(selectedIndex == 0){
//      if(myBanner == null) myBanner = createBn()..load();
//      myBanner.show(anchorOffset: 0.0, horizontalCenterOffset: 0.0);
//    }else if(selectedIndex == 4){
//      if(myInterstitial == null) myInterstitial = createAll()..load();
//      myInterstitial.show();
//
//      if(myBanner != null){
//        myBanner.dispose();
//        myBanner = createBn()..load();
//      }
//    }else{
//      if(myBanner != null){
//        myBanner.dispose();
//        myBanner = createBn()..load();
//      }
//      if(myInterstitial != null){
//        myInterstitial.dispose();
//        myInterstitial = createAll()..load();
//      }
//    }

    if (size == null) {
      size = MediaQuery.of(context).size;
    }

    //위치정보 업데이트
    setPosition(context);
    return StreamProvider<List<Message>>.value(
      value: firestoreProvider.fetchNotReadMsg(Provider.of<MyUserData>(context).data.username),
      child: Consumer<List<Message>>(
        builder: (context, msg, child){
          //초기화
          cnt = 0;
          totalCount = 0;
          //나한테 수신된 메시지 전체를 가져와서 그중에 안읽은거만 합계를 구함
          if(msg != null) {
            for (int i = 0; i < msg.length; i++) {
              cnt = msg[i].readYN;
              totalCount = totalCount + cnt;
            }
          }

          return Scaffold(
            body: IndexedStack(
              index: selectedIndex,
              children: _widgetOptions,
            ),
            bottomNavigationBar: Padding(
//              padding: selectedIndex == 0 ? const EdgeInsets.only(bottom: 90.0) : const EdgeInsets.only(bottom: 0.0),
              padding: const EdgeInsets.only(bottom: 0.0),
              child: BottomNavigationBar(
                showSelectedLabels: false,
                showUnselectedLabels: false,
                unselectedItemColor: Colors.grey[900],
                selectedItemColor: Colors.black,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Color.fromRGBO(249, 249, 249, 1),
                items: <BottomNavigationBarItem>[
                  _buildBottomNavigationBarItem(activeIconPath: 'assets/home_selected.png',iconPath: 'assets/home.png',index: 1),
                  _buildBottomNavigationBarItem(activeIconPath: 'assets/selected_gallery.png',iconPath: 'assets/gallery.png',index: 2),
                  _buildBottomNavigationBarItem(activeIconPath: 'assets/mychat.png',iconPath: 'assets/mychat_selected.png',index: 3),
                  _buildBottomNavigationBarItem(activeIconPath: 'assets/heart_selected.png',iconPath: 'assets/heart.png',index: 4),
                  _buildBottomNavigationBarItem(activeIconPath: 'assets/profile_selected.png',iconPath: 'assets/profile.png',index: 5),
                ],
                currentIndex: selectedIndex,
                onTap: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      {String activeIconPath, String iconPath, int index}) {
    return BottomNavigationBarItem(
      activeIcon:
          activeIconPath == null ? null : Stack(
            children: <Widget>[
              ImageIcon(AssetImage(activeIconPath)),
              index == 3
                  ? Positioned(
                top: 0,
                right: 0,
                child: totalCount == 0 ? Text('') : Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$totalCount',
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              )
                  : Text(''),
            ],
          ),
      icon: Stack(
        children: <Widget>[
          ImageIcon(AssetImage(iconPath)),
          index == 3
              ? Positioned(
                  top: 0,
                  right: 0,
                  child: totalCount == 0 ? Text('') : Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$totalCount',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : Text(''),
        ],
      ),
      title: Text(''),
    );
  }
}
