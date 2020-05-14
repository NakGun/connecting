import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManagePage extends StatefulWidget {
  @override
  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FlatButton(
              ///todo 와 루프돌면서 밖에 안돼 어이가 없네.......
              color: Colors.greenAccent,
              child: Text('대화갯수초기화'),
              onPressed: (){
//                WriteBatch batch = Firestore.instance.batch();
//                final CollectionReference collectionReference = Firestore.instance.collection('Users');
//                batch.updateData(collectionReference, {'talkCount':50});

                Firestore.instance.collection("Users").getDocuments().then((ds){
                  ds.documents.forEach((doc){
                    doc.reference.updateData({'talkCount':100});
                  });
                });
              },
            ),
//            FlatButton(
//              color: Colors.greenAccent,
//              child: Text('대화목록삭제'),
//              onPressed: (){
//                Firestore.instance.collection("Message").getDocuments().then((ds){
//                  ds.documents.forEach((doc){
//                    doc.reference.delete();
//                  });
//                });
//              },
//            ),
            FlatButton(
              color: Colors.greenAccent,
              child: Text('신고대상ip차단'),
              onPressed: (){
                ///todo firebase에서 필터링 및 정렬할수 있다 거기서 하자.....
              },
            ),
          ],
        ),
      ),
    );
  }
}
