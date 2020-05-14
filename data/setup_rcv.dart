import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecting/contstants/firebase_keys.dart';

class SetupRCV{
  //필수사항
  final String setupRCVKey;
  final String username;
  final String token;
  final int gender;
  final int distance;
  final int beginAge;
  final int endAge;
  final int beginTall;
  final int endTall;
  final List<dynamic> blockName;
  final String alarmYN;

  final DocumentReference reference;

  //맵을 생성(그릇을 만드는듯)
  SetupRCV.fromMap(Map<String, dynamic> map, this.setupRCVKey, {this.reference})
    : username = map[KEY_USERNAME],
      token = map[KEY_TOKEN],
      gender = map[KEY_GENDER],
      distance = map[KEY_DISTANCE],
      beginAge = map[KEY_BEGINAGE],
      endAge = map[KEY_ENDAGE],
      beginTall = map[KEY_BEGINTALL],
      endTall = map[KEY_ENDTALL],
      blockName = map[KEY_BLOCKNAME],
      alarmYN = map[KEY_ALARMYN];

  //documentsSnapshot 데이터 받아와서 fromMap() 을 통해 User(Class) 데이터로 담는다.
  SetupRCV.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data, snapshot.documentID, reference: snapshot.reference);

  //추가정보를 받아와서 유저정보 업데이트 하기위한 데이터셋 생성
  static Map<String, dynamic> getMapForSettingInfo(double distance, double beginAge, double endAge, double beginTall, double endTall, int gender, String alarmYN){
    Map<String, dynamic> map = Map();
    map[KEY_DISTANCE] = distance.round();
    map[KEY_BEGINAGE] = beginAge.round();
    map[KEY_ENDAGE] = endAge.round();
    map[KEY_BEGINTALL] = beginTall.round();
    map[KEY_ENDTALL] = endTall.round();
    map[KEY_GENDER] = gender;
    map[KEY_ALARMYN] = alarmYN;

    return map;
  }
}