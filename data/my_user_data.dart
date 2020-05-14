import 'package:flutter/foundation.dart';
import 'package:connecting/data/user.dart';

class MyUserData extends ChangeNotifier{
  User _myUserData;
  User get data => _myUserData;

  //default progress로 설정
  MyUserDataStatus _myUserDataStatus = MyUserDataStatus.progress;
  MyUserDataStatus get status => _myUserDataStatus;

  //하위위젯(provider를 통헤 공유되는위젯) 에 유저데이터가 바뀔경우 전체공지하여 실시간 반영하게끔 해줌
  Future<void> setUserData(User user) async {

    _myUserData = user;
    print('_myUserData.username.length : ${_myUserData.username.length}');
    // 명칭이 있으면 바로 홈
    if(_myUserData.username.length > 0){
      _myUserDataStatus = MyUserDataStatus.exist;
    }else{
      _myUserDataStatus = MyUserDataStatus.first; //인적사항기재페이지로 이동
    }

    notifyListeners();
  }

  Future<void> setNewStatus(MyUserDataStatus status) async {
    _myUserDataStatus = status;
    print('setNewStatus>>>>>>>>>>>>>>>$_myUserDataStatus');
    notifyListeners();
  }

  Future<void> clearUser() async {
    _myUserData = null;
    _myUserDataStatus = MyUserDataStatus.none;
    notifyListeners();
  }

//  bool amIFollowingThisUsre(String userKey){
//    return _myUserData.followings.contains(userKey);
//  }
}

enum MyUserDataStatus { progress, none, exist, first }