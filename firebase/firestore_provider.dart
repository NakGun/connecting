import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecting/data/message.dart';
import 'package:connecting/data/setup_rcv.dart';
import 'package:flutter/cupertino.dart';
import 'package:connecting/contstants/firebase_keys.dart';
import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/data/user.dart';
import 'package:connecting/firebase/transformer.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreProvider with Transformer {
  final Firestore _firestore = Firestore.instance;

  //유저생성
  Future<void> attemptCreateUser(
      {String userKey, String email, BuildContext context}) async {
    print('email == > ${email}');
    final DocumentReference userRef =
    _firestore.collection(COLLECTION_USERS).document(userKey);
    final DocumentSnapshot snapshot = await userRef.get();
    return _firestore.runTransaction((Transaction tx) async {
      print('snapshot.exists : ${snapshot.exists}');
      if (!snapshot.exists) {
        await tx.set(userRef, User.getMapForCreateUser(email));
        //Provider.of<MyUserData>(context, listen: false).setNewStatus(MyUserDataStatus.progress);
      } else {
        Provider.of<MyUserData>(context, listen: false).setNewStatus(MyUserDataStatus.progress);
      }
    });
  }

  //userKey에 해당하는 유저스트림(User class 리턴)
  Stream<User> connectMyUserData(String userKey) {
    print('connectMyUserData=====================================$userKey');

    return _firestore
          .collection(COLLECTION_USERS)
          .document(userKey)
          .snapshots()
          .transform(toUser);
  }
  //userKey에 해당하는 setting
  Stream<QuerySnapshot> MySettingData(String username) {
    return _firestore
        .collection(COLLECTION_USERS)
        .where('username', isEqualTo: username)
        .snapshots();
  }

  //내 수신설정
  Future<Map<String, dynamic>> mySetupData(String myName) async {

    Map<String, dynamic> setupRCV;

    await _firestore
        .collection(COLLECTION_SETUP)
        .where("username", isEqualTo: myName)
        .getDocuments()
        .then((ds) async {
          ds.documents.forEach((doc) async {
            print('setupRCV=====================================${doc.data}');
            setupRCV = doc.data;
        });
      });
    return setupRCV;
  }

  //나를 제외한 모든 유저스트림
  Stream<List<User>> fetchAllUsersExceptMine() {
    return _firestore
        .collection(COLLECTION_USERS)
        .snapshots()
        .transform(toUsersExceptMine);
  }

//나의 수신설정에 따른 필터 조회
  Stream<List<User>> fetchAllUsersFilter(String myName, Map<String, dynamic> setup) {
    if (setup['gender'] != 0) {
      return _firestore.collection(COLLECTION_USERS).where('gender', isEqualTo: setup['gender']).snapshots().transform(toUsersExceptMine);
    } else {
      return _firestore.collection(COLLECTION_USERS).snapshots().transform(toUsersExceptMine);
    }
  }
  //나의 수신설정에 따른 필터 조회
//  Stream<List<User>> fetchAllUsersFilter(
//      String myName, Map<String, dynamic> setup) {
//    //이것저것 다 필터링해서 줄려고 했으나....firestore는 병신이다 그냥 flutter에서 필터링 또 해.....아오...한 6시간 했나보다
//    //여러필드에 범위 조건을 걸수 없다.
//    //각각 쿼리를 만들어서 병합(conbine) 했으나 각각 쿼리에서 중복이 발생
//    //중복제거 했으나 각각 쿼리별로 조회하다보니 필요없는게 다 조회됨 (or조회)
//    //포기...
//
//    final CollectionReference = _firestore.collection(COLLECTION_USERS);
//
//    List<Stream<List<User>>> streams = [];
//
////    streams.add(CollectionReference.where('tall', isGreaterThanOrEqualTo: setup['beginTall'])
////                                   .where('tall', isLessThanOrEqualTo: setup['endTall'])
////                                   .snapshots()
////                                   .transform(toUsersExceptMine));
////    streams.add(CollectionReference.where('age', isGreaterThanOrEqualTo: setup['beginAge'])
////                                   .where('age', isLessThanOrEqualTo: setup['endAge'])
////                                   .snapshots()
////                                   .transform(toUsersExceptMine));
//
//    if (setup['gender'] != 0) {
//      streams.add(
//          CollectionReference.where('gender', isEqualTo: setup['gender'])
//              .snapshots()
//              .transform(toUsersExceptMine));
//    } else {
//      streams.add(CollectionReference.snapshots().transform(toUsersExceptMine));
//    }
//
//    return Rx.combineLatest(streams, (listOfPosts) {
//      List<User> commbinedPosts = [];
//      for (List<User> users in listOfPosts) {
//        commbinedPosts.addAll(users);
//      }
//
//      Map<String, User> mp = {};
//      for (var item in commbinedPosts) {
//        mp[item.username] = item;
//      }
//
//      return mp.values.toList();
//    });
//  }

  Stream<List<Message>> fetchMessage(List<String> roomId) {
    final CollectionReference = _firestore.collection(COLLECTION_MESSAGE);

    List<Stream<List<Message>>> streams = [];

    streams.add(CollectionReference.where('receiver', isEqualTo: roomId[0])
        .where('sender', isEqualTo: roomId[1])
        .snapshots()
        .transform(toMessages));

    streams.add(CollectionReference.where('sender', isEqualTo: roomId[0])
        .where('receiver', isEqualTo: roomId[1])
        .snapshots()
        .transform(toMessages));

    return Rx.combineLatest(streams, (listOfPosts) {
      List<Message> commbinedPosts = [];
      for (List<Message> msgs in listOfPosts) {
        commbinedPosts.addAll(msgs);
      }

      return commbinedPosts;
    });
  }

  //모든 유저스트림
  Stream<List<User>> fetchAllUsers() {
    return _firestore
        .collection(COLLECTION_USERS)
        .snapshots()
        .transform(toUsers);
  }

  //나와 대화중인 유저 목록
  Stream<List<User>> fetchMyChatUsers(List<dynamic> roomIds) {
    //roomIds : 상대방이 요청해서 자리잡고 있는애들 + 내가 요청해서 받은 상대방 키
    final CollectionReference collectionReference =
        _firestore.collection(COLLECTION_USERS);

    List<Stream<List<User>>> streams = [];

    for (int i = 0; i < roomIds.length; i++) {
//      streams.add(collectionReference.where(KEY_USERNAME, arrayContains: roomIds[i]).snapshots().transform(toUsersExceptMine));
      streams.add(collectionReference
          .where(KEY_USERNAME, isEqualTo: roomIds[i])
          .snapshots()
          .transform(toUsersExceptMine));
    }

    if (streams.length == 0) {
      return null;
    } else {
      return Rx.combineLatest(streams, (listOfUsers) {
        List<User> commbinedUsers = [];
        for (List<User> users in listOfUsers) {
          commbinedUsers.addAll(users);
        }
        return commbinedUsers;
      });
    }
  }

  //user 기본정보를 업데이트 함.
  Future<Map<String, dynamic>> userBaseUpdate(
      String userKey, Map<String, dynamic> userData) async {
    final DocumentReference userRef =
        _firestore.collection(COLLECTION_USERS).document(userKey);
    //final DocumentSnapshot userSnapshot = await userRef.get();

    return _firestore.runTransaction((Transaction tx) async {
      await tx.update(userRef, {
        KEY_USERNAME: userData[KEY_USERNAME],
        KEY_CITY: userData[KEY_CITY],
        KEY_AGE: userData[KEY_AGE],
        KEY_TALL: userData[KEY_TALL],
        KEY_GENDER: userData[KEY_GENDER],
        KEY_TALKCOUNT: userData[KEY_TALKCOUNT],
        KEY_MYIP: userData[KEY_MYIP],
        KEY_CONNECTYN: userData[KEY_CONNECTYN]
      });
    });
  }

  //user 추가정보를 업데이트 함.
  Future<Map<String, dynamic>> userAddUpdate(
      String userKey, Map<String, dynamic> userData) async {
    final DocumentReference userRef =
        _firestore.collection(COLLECTION_USERS).document(userKey);
    //final DocumentSnapshot userSnapshot = await userRef.get();

    return _firestore.runTransaction((Transaction tx) async {
      await tx.update(userRef, {
        KEY_BLOOD: userData[KEY_BLOOD],
        KEY_JOB: userData[KEY_JOB],
        KEY_LIKEBOOK: userData[KEY_LIKEBOOK],
        KEY_LIKESTAR: userData[KEY_LIKESTAR],
        KEY_INTRO: userData[KEY_INTRO]
      });
    });
  }

  //user 위치정보를 업데이트 함.
  Future<Map<String, dynamic>> userPositionUpdate(
      String userKey, Map<String, dynamic> userData) async {
    final DocumentReference userRef =
        _firestore.collection(COLLECTION_USERS).document(userKey);

    return _firestore.runTransaction((Transaction tx) async {
      await tx.update(
          userRef, {KEY_LAT: userData[KEY_LAT], KEY_LONG: userData[KEY_LONG]});
    });
  }

  //user RoomID 업데이트 함.
  Future<Map<String, dynamic>> roomIDUpdate(User user, User otherUser) async {
    final DocumentReference userRef =
        _firestore.collection(COLLECTION_USERS).document(user.userKey);
    final DocumentReference otherUserRef =
        _firestore.collection(COLLECTION_USERS).document(otherUser.userKey);

    return _firestore.runTransaction((Transaction tx) async {
      await tx.update(userRef, {
        KEY_ROOMID: FieldValue.arrayUnion([otherUser.username])
      });

      await tx.update(otherUserRef, {
        KEY_ROOMID: FieldValue.arrayUnion([user.username])
      });
    });
  }

  //user 셋팅정보를 업데이트 함.
  Future<Map<String, dynamic>> userSetUpdate(String username, Map<String, dynamic> setupRCV) async {
    String settingKey;
    await _firestore.collection(COLLECTION_SETUP).where('username', isEqualTo: username).getDocuments().then((ds) {
      ds.documents.forEach((doc) async {
        print('doc : ${doc.documentID}');
        settingKey = doc.documentID ;
      });
    });

    DocumentReference setupRef = _firestore.collection(COLLECTION_SETUP).document(settingKey);

    return _firestore.runTransaction((Transaction tx) async {
      await tx.update(setupRef, {
        KEY_DISTANCE: setupRCV[KEY_DISTANCE],
        KEY_BEGINAGE: setupRCV[KEY_BEGINAGE],
        KEY_ENDAGE: setupRCV[KEY_ENDAGE],
        KEY_BEGINTALL: setupRCV[KEY_BEGINTALL],
        KEY_ENDTALL: setupRCV[KEY_ENDTALL],
        KEY_GENDER: setupRCV[KEY_GENDER],
        KEY_ALARMYN: setupRCV[KEY_ALARMYN],
      });
    });
  }

  //대화목록삭제하기
  Future<Map<String, dynamic>> deleteRoomID(User myUser, User otherUser) async {
    final DocumentReference userRef =
        _firestore.collection(COLLECTION_USERS).document(myUser.userKey);

    return _firestore.runTransaction((Transaction tx) async {
      await tx.update(userRef, {
        KEY_ROOMID: FieldValue.arrayRemove([otherUser.username])
      });
    });
  }

  //친구삭제
  Future<Map<String, dynamic>> deleteFriend(
      String myUserKey, String friendName) async {
    final DocumentReference userRef =
        _firestore.collection(COLLECTION_USERS).document(myUserKey);

    return _firestore.runTransaction((Transaction tx) async {
      await tx.update(userRef, {
        KEY_FRIENDKEY: FieldValue.arrayRemove([friendName])
      });
    });
  }

  //친구요청한 상대방 필드에 자기 id를 추가
  Future<Map<String, dynamic>> requestFriend(
      User myData, User otherUser) async {
    final DocumentReference otherUserRef = _firestore.collection(COLLECTION_USERS).document(otherUser.userKey);
    final DocumentReference myRef = _firestore.collection(COLLECTION_USERS).document(myData.userKey);

    return _firestore.runTransaction((Transaction tx) async {
      //매칭요청한 상대방의 이름을 나한테 등록
      await tx.update(myRef, {
        KEY_MYREQUESTKEY: FieldValue.arrayUnion([otherUser.username])
      });
      //매칭요청한 상대에게 내이름을 등록
      await tx.update(otherUserRef, {
        KEY_FRIENDREQUESTKEY: FieldValue.arrayUnion([myData.username])
      });
    });
  }

  //친구수락하기
  Future<Map<String, dynamic>> acceptFriend(
      User myUser, User otherUser) async {
    //수락하는사람
    final DocumentReference myRef = _firestore.collection(COLLECTION_USERS).document(myUser.userKey);
    //요청한사람
    final DocumentReference otherRef = _firestore.collection(COLLECTION_USERS).document(otherUser.userKey);

    return _firestore.runTransaction((Transaction tx) async {
      //상대방이 요청한 상대방 이름을 친구로 등록
      await tx.update(myRef, {
        KEY_FRIENDKEY: FieldValue.arrayUnion([otherUser.username])
      });

      //상대방이 요청한 상대방 이름을 삭제
      await tx.update(myRef, {
        KEY_FRIENDREQUESTKEY: FieldValue.arrayRemove([otherUser.username])
      });

      //상대방의 요청목록에서 내이름을 삭제
      await tx.update(otherRef, {
        KEY_MYREQUESTKEY: FieldValue.arrayRemove([myUser.username])
      });

      //상대방의 친구로 등록
      await tx.update(otherRef, {
        KEY_FRIENDKEY: FieldValue.arrayUnion([myUser.username])
      });
    });
  }

  //쪽지 1개 소진
  Future<Map<String, dynamic>> minusTalkCount( User myData) async {
    final DocumentReference myRef = _firestore.collection(COLLECTION_USERS).document(myData.userKey);
    final DocumentSnapshot mySnapshot = await myRef.get();

    int talkCount = mySnapshot.data[KEY_TALKCOUNT];

    return _firestore.runTransaction((Transaction tx) async {
      //매칭요청한 상대방의 이름을 나한테 등록
      await tx.update(myRef, {
        KEY_TALKCOUNT: talkCount - 1
      });
    });
  }

  //친구목록(stream)
  Stream<List<User>> fetchFriendList(List<dynamic> followings) {
    //print('===============fetchFriendList===================${followings}');
    final CollectionReference collectionReference =
        _firestore.collection(COLLECTION_USERS);

    List<Stream<List<User>>> streams = [];

    for (int i = 0; i < followings.length; i++) {
      streams.add(collectionReference
          .where(KEY_USERNAME, isEqualTo: followings[i])
          .snapshots()
          .transform(toUsers));
    }

    if (streams.length == 0) {
      return null;
    } else {
      return Rx.combineLatest(streams, (listOfUsers) {
        List<User> commbinedUsers = [];
        for (List<User> users in listOfUsers) {
          commbinedUsers.addAll(users);
        }
        return commbinedUsers;
      });
    }
  }

  //친구 / 친구요청 목록(list)
  Stream<List<User>> fetchFriends(List<dynamic> followings) {
    final CollectionReference collectionReference =
        _firestore.collection(COLLECTION_USERS);

    return _firestore
        .collection(COLLECTION_USERS)
        .where(KEY_USERNAME, isEqualTo: followings)
        .snapshots()
        .transform(toUsers);
  }

  //친구요청목록(stream)
  Stream<List<User>> fetchRequestUsers(List<dynamic> followings) {
    //print('===============RequestUsers===================${followings}');
    final CollectionReference collectionReference =
        _firestore.collection(COLLECTION_USERS);
    List<Stream<List<User>>> streams = [];

    for (int i = 0; i < followings.length; i++) {
      streams.add(collectionReference
          .where(KEY_USERNAME, isEqualTo: followings[i])
          .snapshots()
          .transform(toUsers));
    }

    // null을 던저주지 않으면 친구 List<user> 계속 바라봄...일단 이케 했는데 맞는지 원..
    if (streams.length == 0) {
      return null;
    } else {
      return Rx.combineLatest(streams, (listOfUsers) {
        List<User> commbinedUsers = [];
        for (List<User> users in listOfUsers) {
          commbinedUsers.addAll(users);
        }
        return commbinedUsers;
      });
    }
  }

  //안읽은 메시지목록
  Stream<List<Message>> fetchNotReadMsg(String username) {
    return _firestore
        .collection(COLLECTION_MESSAGE)
        .where(KEY_RECEIVER, isEqualTo: username)
        .snapshots()
        .transform(toMessages);
  }
//  //사진조회
//  Stream<List<String>> getPhoto(String userKey) {
//    print('===============myUserKey===================${userKey}');
//    final DocumentReference userRef = _firestore.collection(COLLECTION_USERS).document(userKey);
//
//    Stream<List<String>> streams;
//    List<String> list = List(6);
//
//    for(int i = 0; i < 6; i++) {
//      streams.add(collectionReference.where(KEY_USERNAME, isEqualTo: followings[i]).snapshots().transform(toUsers));
//      userRef.snapshots().da
//      return _firestore.collection('smartphone').where('deviceName', isEqualTo: deviceName).snapshots();
//    }
//
//
//
//    // null을 던저주지 않으면 친구 List<user> 계속 바라봄...일단 이케 했는데 맞는지 원..
//    if(streams.length == 0){
//      return null;
//    }else{
//      return Rx.combineLatest(streams, (listOfUsers) {
//        List<User> commbinedUsers = [];
//        for(List<User> users in listOfUsers){
//          commbinedUsers.addAll(users);
//        }
//        return commbinedUsers;
//      });
//    }
//  }

//아 씨발 async 못쓰것다 then 도 이상하고 씨벌
//  List<Stream<List<User>>> fetchRequestUsers(String userKey) {
//    List<Stream<List<User>>> streams = [];
//    DocumentSnapshot snapshot;
//    List<dynamic> requestName = [];
//
//    final CollectionReference collectionReference = _firestore.collection(COLLECTION_USERS);
//    final DocumentReference userRef = _firestore.collection(COLLECTION_USERS).document(userKey);
//
//    void getList() async {
//      snapshot = await userRef.get();
//      requestName = snapshot.data[KEY_FRIENDREQUESTKEY];
//
//      for (var i = 0; i < requestName.length; i++) {
//        streams.add(
//            collectionReference.where(KEY_USERKEY, isEqualTo: requestName[i])
//                .snapshots()
//                .transform(toUsers));
//      }
//    }
//
//    getList();
//    return streams;
//  }
//
//     print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${snapshot.data[KEY_FRIENDREQUESTKEY]}');
//      //requestName = snapshot.data[KEY_FRIENDREQUESTKEY];
//
////    _firestore.collection(COLLECTION_USERS).document(userKey).get().then((DocumentSnapshot userRef) {
////      requestName = userRef.data[KEY_FRIENDREQUESTKEY];
//////    });
//
//    snapshot = await getList();
//    requestName = snapshot.data[KEY_FRIENDREQUESTKEY];
//    print(requestName.length);
//
//
//    for(var i = 0; i < requestName.length; i++){
//      streams.add(collectionReference.where(KEY_USERKEY, isEqualTo: requestName[i]).snapshots().transform(toUsers));
//    }
//
//    return Rx.combineLatest(streams, (listOfUsers) {
//      List<User> commbinedUsers = [];
//      for(List<User> users in listOfUsers){
//        commbinedUsers.addAll(users);
//      }
//      return commbinedUsers;
//    });
//  }

//  final DocumentReference myUserRef = _firestore.collection(COLLECTION_USERS).document(myUserKey);
//    final DocumentSnapshot myUserSnapshot = await myUserRef.get();
//
//    final DocumentReference otherUserRef = _firestore.collection(COLLECTION_USERS).document(otherUserKey);
//    final DocumentSnapshot otherUserSnapshot = await otherUserRef.get();
//
//    return _firestore.runTransaction((Transaction tx)  {
//      if (myUserSnapshot.exists && otherUserSnapshot.exists) {
//        await tx.update(myUserRef, <String, dynamic> {
//          KEY_FOLLOWINGS: FieldValue.arrayRemove([otherUserKey])
//        });
//
//        int currentFollowers = otherUserSnapshot.data[KEY_FOLLOWERS];
//        await tx.update(otherUserRef, <String, dynamic>{
//          KEY_FOLLOWERS: currentFollowers - 1
//        });

//  Future<void> sendData(){
//    return Firestore.instance.collection('Users').document('123123123').setData({'email':'testing@test.com','author':'author'});
//  }

  ///사진url 유저에 업로드
//  Future<Map<String, dynamic>> imageUrlUpload(
//    {String userKey, List<String> imgUrl}) async {
//    final DocumentReference myUserRef = _firestore.collection(COLLECTION_USERS).document(userKey);
//    final DocumentSnapshot myUserSnapshot = await myUserRef.get();
//
//    return _firestore.runTransaction((Transaction tx) async {
//
//      if (myUserSnapshot.exists) {
//
//
//        for(var i = 0; i < imgUrl.length; i++){
//          ///TODO 한방에 삭제가 안대나...
//          //await tx.update(myUserRef, <String, dynamic> {
//          //  KEY_PROFILEIMG: FieldValue.(imgUrl[i])
//          //});
//
//          print('처리건수===${i}');
//          print('imgUrl.length===${imgUrl[i].toString()}');
//          ///사진 6개 업로드
//          await tx.update(myUserRef, <String, dynamic> {
//            KEY_PROFILEIMG: FieldValue.arrayUnion([imgUrl[i]])
//          });
//        }
//      }
//    });
//  }

  ///사진url 유저에 업로드
//  Future<Map<String, dynamic>> firstUrlUpload(
//      {String userKey}) async {
//    final DocumentReference myUserRef = _firestore.collection(COLLECTION_USERS).document(userKey);
//    final DocumentSnapshot myUserSnapshot = await myUserRef.get();
//
//    return _firestore.runTransaction((Transaction tx) async {
//
//      if (myUserSnapshot.exists) {
//        for(var i = 0; i < 6; i++){
//          ///사진 6개 업로드
//          await tx.update(myUserRef, <String, dynamic> {
//            KEY_PROFILEIMG: FieldValue.arrayUnion(['http://192.168.219.105:8887/addFace${i+1}.png'])
//          });
//        }
//      }
//    });
//  }
//  Future<Map<String, dynamic>> unfollowUser(
//      {String myUserKey, String otherUserKey}) async {
//    final DocumentReference myUserRef = _firestore.collection(COLLECTION_USERS).document(myUserKey);
//    final DocumentSnapshot myUserSnapshot = await myUserRef.get();
//
//    final DocumentReference otherUserRef = _firestore.collection(COLLECTION_USERS).document(otherUserKey);
//    final DocumentSnapshot otherUserSnapshot = await otherUserRef.get();
//
//    return _firestore.runTransaction((Transaction tx) async {
//      if (myUserSnapshot.exists && otherUserSnapshot.exists) {
//        await tx.update(myUserRef, <String, dynamic> {
//          KEY_FOLLOWINGS: FieldValue.arrayRemove([otherUserKey])
//        });
//
//        int currentFollowers = otherUserSnapshot.data[KEY_FOLLOWERS];
//        await tx.update(otherUserRef, <String, dynamic>{
//          KEY_FOLLOWERS: currentFollowers - 1
//        });
//      }
//    });
//  }
//  Stream<List<Post>> fetchAllPostFromFollowers(List<dynamic> followings) {
//    final CollectionReference collectionReference = _firestore.collection(COLLECTION_POSTS);
//
//    List<Stream<List<Post>>> streams = [];
//
//    for(int i = 0; i < followings.length; i++) {
//      streams.add(collectionReference.where(KEY_USERKEY, isEqualTo: followings[i]).snapshots().transform(toPosts));
//    }
//
//    return Rx.combineLatest(streams, (listOfPosts) {
//      List<Post> commbinedPosts = [];
//      for(List<Post> posts in listOfPosts){
//        commbinedPosts.addAll(posts);
//      }
//      return commbinedPosts;
//    });
//  }

//  Future<void> sendData(){
//    return Firestore.instance.collection('Users').document('123123123').setData({'email':'testing@test.com','author':'author'});
//  }
//
//  Future<dynamic> getData(){
//    Firestore.instance.collection('Users').document('123123123').get().then(
//            (DocumentSnapshot ds){
//              print(ds.data);
//            });
//  }
//}
//  Future<Map<String, dynamic>> createNewPost(String postKey,
//      Map<String, dynamic> postData) async {
//    final DocumentReference postRef = _firestore.collection(COLLECTION_POSTS).document(postKey);
//    final DocumentSnapshot postSnapshot = await postRef.get();
//    final DocumentReference userRef = _firestore.collection(COLLECTION_USERS).document(postData[KEY_USERKEY]);
//
//    return _firestore.runTransaction((Transaction tx) async {
//      await tx.update(userRef, {
//        KEY_MYPOSTS: FieldValue.arrayUnion([postKey])
//      });
//
//      if (!postSnapshot.exists){
//        await tx.set(postRef, postData);
//      }
//    });
//  }
//

//
//  //comment를 post 하위 collection (comment collection)에 저장하고 post 컬럼값들을 update함
//  Future<Map<String, dynamic>> createNewComment(String postKey,
//      Map<String, dynamic> commentData) async {
//    final DocumentReference postRef = _firestore.collection(COLLECTION_POSTS).document(postKey);
//    final DocumentSnapshot postSnapshot = await postRef.get();
//    final DocumentReference commentRef = postRef.collection(COLLECTION_COMMENTS).document();
//
//    return _firestore.runTransaction((Transaction tx) async {
//      if(postSnapshot.exists) {
//        await tx.set(commentRef, commentData);
//
//        int numOfComments = postSnapshot.data[KEY_NUMOFCOMMENTS];
//        await tx.update(postRef, {
//          KEY_LASTCOMMENT: commentData[KEY_LASTCOMMENT],
//          KEY_LASTCOMMENTOR: commentData[KEY_LASTCOMMENTOR],
//          KEY_LASTCOMMENTTIME: commentData[KEY_LASTCOMMENTTIME],
//          KEY_NUMOFCOMMENTS: numOfComments + 1
//        });
//      }
//    });
//  }

//모든 comments
//  Stream<List<CommentModel>> fetchAllComments(String postKey) {
//    return _firestore.collection(COLLECTION_POSTS)
//        .document(postKey)
//        .collection(COLLECTION_COMMENTS)
//        .orderBy(KEY_COMMENTTIME)
//        .snapshots()
//        .transform(toComments);
//  }

//  Future<void> toggleLike(String postKey, String userKey) async {
//    final DocumentReference postRef = _firestore.collection(COLLECTION_POSTS).document(postKey);
//    final DocumentSnapshot postSnapshot = await postRef.get();
//
//    if(postSnapshot.exists) {
//      if(postSnapshot.data[KEY_NUMOFLIKES].contains(userKey)){
//        postRef.updateData({
//          KEY_NUMOFLIKES: FieldValue.arrayRemove([userKey])
//        });
//      } else {
//        postRef.updateData({
//          KEY_NUMOFLIKES: FieldValue.arrayUnion([userKey])
//        });
//      }
//    }
//  }
}

FirestoreProvider firestoreProvider = FirestoreProvider();
