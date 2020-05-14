import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecting/contstants/firebase_keys.dart';

class Message{
  //필수사항
  final String messageKey;
  final int readYN;
  final String receiver;
  final String roomid;
  final String sender;
  final String text;
  final Timestamp time;

  final DocumentReference reference;

  //맵을 생성(그릇을 만드는듯)
  Message.fromMap(Map<String, dynamic> map, this.messageKey, {this.reference})
      : readYN = map[KEY_READYN],
        receiver = map[KEY_RECEIVER],
        roomid = map[KEY_ROOMID],
        sender = map[KEY_SENDER],
        text = map[KEY_TEXT],
        time = map[KEY_TIME];

  //documentsSnapshot 데이터 받아와서 fromMap() 을 통해 User(Class) 데이터로 담는다.
  Message.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, snapshot.documentID, reference: snapshot.reference);
}