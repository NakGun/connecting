import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecting/contstants/firebase_keys.dart';

class User {
  //필수사항
  final String userKey;
  final String email;
  final String username;
  final String city;
  final int age;
  final int tall;
  final int gender;
  final double lat;
  final double long;

  //추가사항
  final String blood;
  final String job;
  final String likeBook;
  final String likeStar;
  final String intro;
  final String profileImg1;
  final String profileImg2;
  final String profileImg3;
  final String profileImg4;
  final String profileImg5;
  final String profileImg6;
  final List<dynamic> friendKey;
  final List<dynamic> friendRequestKey;
  final List<dynamic> myRequestKey;
  final List<dynamic> roomId;
  final String myPosition;

  //관리자필요 유저정보
  final int talkCount;
  final List<dynamic> waringID;
  final String myIP;
  final String connectYN;
  final String alarmYN;

  final DocumentReference reference;

  //맵을 생성(그릇을 만드는듯)
  User.fromMap(Map<String, dynamic> map, this.userKey, {this.reference})
      : email = map[KEY_EMAIL],
        username = map[KEY_USERNAME],
        city = map[KEY_CITY],
        age = map[KEY_AGE],
        tall = map[KEY_TALL],
        gender = map[KEY_GENDER],
        blood = map[KEY_BLOOD],
        job = map[KEY_JOB],
        likeBook = map[KEY_LIKEBOOK],
        likeStar = map[KEY_LIKESTAR],
        intro = map[KEY_INTRO],
        profileImg1 = map[KEY_PROFILEIMG1],
        profileImg2 = map[KEY_PROFILEIMG2],
        profileImg3 = map[KEY_PROFILEIMG3],
        profileImg4 = map[KEY_PROFILEIMG4],
        profileImg5 = map[KEY_PROFILEIMG5],
        profileImg6 = map[KEY_PROFILEIMG6],
        friendKey = map[KEY_FRIENDKEY],
        friendRequestKey = map[KEY_FRIENDREQUESTKEY],
        myRequestKey = map[KEY_MYREQUESTKEY],
        roomId = map[KEY_ROOMID],
        //나와 채팅중인 상대방ID
        myPosition = map[KEY_MYPOSITION],
        //내가 위치중인 채팅방[채팅중인 상대방ID]
        lat = map[KEY_LAT],
        long = map[KEY_LONG],
        talkCount = map[KEY_TALKCOUNT],
        waringID = map[KEY_WARINGID],
        myIP = map[KEY_MYIP],
        connectYN = map[KEY_CONNECTYN],
        alarmYN = map[KEY_ALARMYN];

  //documentsSnapshot 데이터 받아와서 fromMap() 을 통해 User(Class) 데이터로 담는다.
  User.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, snapshot.documentID,
            reference: snapshot.reference);

  //email을 받아와서 User(map) 데이터를 생성한 후 리턴
  static Map<String, dynamic> getMapForCreateUser(String email) {
    print('email : ${email}');
    Map<String, dynamic> map = Map();
    //map[KEY_USERKEY] = '';
    map[KEY_EMAIL] = email;
    map[KEY_USERNAME] = '';
    map[KEY_CITY] = '';
    map[KEY_AGE] = 0;
    map[KEY_TALL] = 0;
    map[KEY_GENDER] = 0;
    map[KEY_BLOOD] = '';
    map[KEY_JOB] = '';
    map[KEY_LIKEBOOK] = '';
    map[KEY_LIKESTAR] = '';
    map[KEY_INTRO] = '';
    map[KEY_FRIENDKEY] = [];
    map[KEY_FRIENDREQUESTKEY] = [];
    map[KEY_MYREQUESTKEY] = [];
    map[KEY_PROFILEIMG1] = '';
    map[KEY_PROFILEIMG2] = '';
    map[KEY_PROFILEIMG3] = '';
    map[KEY_PROFILEIMG4] = '';
    map[KEY_PROFILEIMG5] = '';
    map[KEY_PROFILEIMG6] = '';
    map[KEY_ROOMID] = [];
    map[KEY_MYPOSITION] = '';
    map[KEY_TALKCOUNT] = 100;
    map[KEY_WARINGID] = [];
    map[KEY_MYIP] = '';
    map[KEY_CONNECTYN] = 'Y';
    map[KEY_ALARMYN] = 'Y';
    map[KEY_LAT] = 0.0;
    map[KEY_LONG] = 0.0;

    return map;
  }

  //기본정보를 받아와서 유저정보 업데이트 하기위한 데이터셋 생성
  static Map<String, dynamic> getMapForCreateBaseInfo(
      String username,
      String city,
      int age,
      int tall,
      int gender,
      int talkCount,
      String myIP,
      String connectYN,) {
    Map<String, dynamic> map = Map();
    //map[KEY_USERKEY] = '';
    map[KEY_USERNAME] = username;
    map[KEY_CITY] = city;
    map[KEY_AGE] = age;
    map[KEY_TALL] = tall;
    map[KEY_GENDER] = gender;
    map[KEY_TALKCOUNT] = talkCount;
    map[KEY_MYIP] = myIP;
    map[KEY_CONNECTYN] = connectYN;

    return map;
  }

  //추가정보를 받아와서 유저정보 업데이트 하기위한 데이터셋 생성
  static Map<String, dynamic> getMapForCreateAddInfo(
      String blood, String job, String book, String star, String intro) {
    Map<String, dynamic> map = Map();
    map[KEY_BLOOD] = blood;
    map[KEY_JOB] = job;
    map[KEY_LIKEBOOK] = book;
    map[KEY_LIKESTAR] = star;
    map[KEY_INTRO] = intro;

    return map;
  }

  //앱 구동시 현재위치 저정
  static Map<String, dynamic> getMapForCreatePosition(double lat, double long) {
    Map<String, dynamic> map = Map();
    map[KEY_LAT] = lat;
    map[KEY_LONG] = long;

    return map;
  }
}
