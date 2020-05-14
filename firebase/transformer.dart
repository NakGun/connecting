import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecting/data/message.dart';
import 'package:connecting/data/setup_rcv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecting/data/user.dart';

class Transformer {
  final toUser = StreamTransformer<DocumentSnapshot, User>.fromHandlers(
    handleData: (snapshot, sink) async {
      if(snapshot.data != null) {
        sink.add(User.fromSnapshot(snapshot));
      }else{
        FirebaseAuth.instance.signOut();
      }
    }
  );

  final toSetup = StreamTransformer<DocumentSnapshot, SetupRCV>.fromHandlers(
    handleData: (snapshot, sink) async {
      sink.add(SetupRCV.fromSnapshot(snapshot));
    }
  );

  final toUsers = StreamTransformer<QuerySnapshot, List<User>>.fromHandlers(
      handleData: (snapshot, sink) async {
        List<User> users = [];

        snapshot.documents.forEach((documentSnapshot){
          users.add(User.fromSnapshot(documentSnapshot));
        });
        sink.add(users);
      }
  );

  final toMessages = StreamTransformer<QuerySnapshot, List<Message>>.fromHandlers(
      handleData: (snapshot, sink) async {
        List<Message> messages = [];

        snapshot.documents.forEach((documentSnapshot){
          messages.add(Message.fromSnapshot(documentSnapshot));
        });
        sink.add(messages);
      }
  );
//  final toPosts = StreamTransformer<QuerySnapshot, List<Post>>.fromHandlers(
//      handleData: (snapshot, sink) async {
//        List<Post> posts = [];
//        snapshot.documents.forEach((documentSnapshot){
//          posts.add(Post.fromSnapshot(documentSnapshot));
//        });
//        sink.add(posts);
//      }
//  );

  final toUsersExceptMine = StreamTransformer<QuerySnapshot, List<User>>.fromHandlers(
      handleData: (snapshot, sink) async {
        List<User> users = [];
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        snapshot.documents.forEach((documentSnapshot){
          if(documentSnapshot.documentID != user.uid){
            users.add(User.fromSnapshot(documentSnapshot));
          }
        });
        sink.add(users);
      }
  );

  //comment model로 transform
//  final toComments = StreamTransformer<QuerySnapshot, List<CommentModel>>.fromHandlers(
//      handleData: (snapshot, sink) async {
//        List<CommentModel> comments = [];
//        snapshot.documents.forEach((documentSnapshot){
//          comments.add(CommentModel.fromSnapshot(documentSnapshot));
//        });
//        sink.add(comments);
//      }
//  );
}