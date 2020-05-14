import 'package:bubble/bubble.dart';
import 'package:connecting/contstants/firebase_keys.dart';
import 'package:connecting/data/message.dart';
import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/data/user.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connecting/contstants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";
  final User myUser;
  final User otherUser;
  final List<String> roomId;

  const ChatScreen(
      {Key key,
      @required this.myUser,
      @required this.otherUser,
      @required this.roomId})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final messageTextContoller = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getCurrentUser();
    //채팅방 입성을 표시
    setMyPostion();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    exitMyPositon();
    super.dispose();
  }

  AppLifecycleState _notification;

  //destroy event가 없어서 아래와 같이 찾아서 함...
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.toString() == 'AppLifecycleState.paused') {
      exitMyPositon();
    } else if (state.toString() == 'AppLifecycleState.resumed') {
      setMyPostion();
    }
    setState(() {
      _notification = state;
    });
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  //접속유저에서의 채팅방위치설정
  void setMyPostion() {
    try {
      //채팅방에 입성한 유저의 위치 설정
      _firestore
          .collection("Users")
          .document(widget.myUser.userKey)
          .updateData({"myPosition": widget.otherUser.username});
      //입성한 상대 메시지 전부 읽은 것으로 update
      _firestore
          .collection("Message")
          .where('sender', isEqualTo: widget.otherUser.username)
          .where('receiver', isEqualTo: widget.myUser.username)
          .getDocuments()
          .then((ds) {
        ds.documents.forEach((doc) {
          _firestore
              .collection("Message")
              .document(doc.documentID)
              .updateData({"readYN": 0});
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void exitMyPositon() {
    try {
      _firestore
          .collection("Users")
          .document(widget.myUser.userKey)
          .updateData({"myPosition": ''});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        title: Text('${widget.otherUser.username}', style: TextStyle(fontSize: 20),),//Text('⚡️Chat'),
        backgroundColor: Colors.pink[300],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ///메시지 창
            MessagesStream(roomID: widget.roomId, otherUser: widget.otherUser),

            ///SEND 창
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextContoller,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  IconButton(
                    // 아이콘 버튼에 전송 아이콘 추가
                    icon: Icon(Icons.send),
                    // 입력된 텍스트가 존재할 경우에만 _handleSubmitted 호출
                    onPressed: () async {
                      //sender(결국본인이지만..)입장에서 상대방 채팅방 위치를 가져옴
                      //print('widget.otherUser.userKey==== : ${widget.otherUser.userKey}');
                      String myPosition;
                      await _firestore
                          .collection("Users")
                          .document(widget.otherUser.userKey)
                          .get()
                          .then((ds) {
                        myPosition = ds.data['myPosition'];
                      });

                      messageTextContoller.clear();
                      _firestore.collection("Message").add({
                        "roomid": widget.myUser.userKey,
                        "sender": widget.myUser.username,
                        "receiver": widget.otherUser.username,
                        "text": messageText,
                        "readYN": myPosition == widget.myUser.username ? 0 : 1,
                        "time": DateTime.now()
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final List<String> roomID;
  final User otherUser;

  const MessagesStream({Key key, @required this.roomID, @required this.otherUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
//    List<Stream<List<User>>> streams;
//    for(var i = 0; i < roomID.length; i++){
//      streams: _firestore.collection("Message").where("roomid", arrayContains: roomID).snapshots(),
//    }
    return StreamProvider<List<Message>>.value(
      value: firestoreProvider.fetchMessage(roomID),
      child: Consumer<List<Message>>(
        builder: (context, msgs, child) {
          if (msgs == null) {
            return Center(child: Text('Please wait its loading...'));
          }
          List<MessageBubble> messageBubbles = [];

          for (var i = 0; i < msgs.length; i++) {
            final messageText = msgs[i].text;
            final messageSender = msgs[i].sender;
            final messageTime = msgs[i].time;
            final currentUsser = Provider.of<MyUserData>(context).data.username;
            final messageBubble = MessageBubble(
              sender: messageSender,
              text: messageText,
              time: messageTime,
              isMe: currentUsser == messageSender,
              otherUser: otherUser,
            );
            messageBubbles.add(messageBubble);
            messageBubbles.sort((a, b) => b.time.compareTo(a.time));
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
              children: messageBubbles,
            ),
          );
        },
      ),
    );
  }

//  Stream<QuerySnapshot> _createStream() {
//    List<Stream<QuerySnapshot>> streams;
//
//    streams.add(_firestore.collection('Message')
//        .where('receiver', isEqualTo: roomID[0])
//        .where('sender', isEqualTo: roomID[1])
//        .snapshots());
//
//    streams.add(_firestore.collection('Message')
//        .where('sender', isEqualTo: roomID[0])
//        .where('receiver', isEqualTo: roomID[1])
//        .snapshots());
//
//    return MergeStream(streams);
//  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final Timestamp time;
  final bool isMe;
  final User otherUser;

  MessageBubble({this.sender, this.text, this.isMe, this.time, this.otherUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              isMe == false
                  ? Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: otherUser.profileImg1.isEmpty ||otherUser.profileImg1 == null
                            ? AssetImage('assets/placeholder.png')
                            : NetworkImage(otherUser.profileImg1,),
                      ),
                    )
                  : Text(''),
              Expanded(
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      //"$sender ${time.toDate()}",
                      sender,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Bubble(
                      margin: BubbleEdges.only(top: 4),
                      alignment: isMe == true ? Alignment.topRight : Alignment.topLeft,
                      nip: isMe == true ? BubbleNip.rightTop : BubbleNip.leftTop,
                      nipWidth: 5,
                      nipHeight: 5,
                      color: isMe == true ? Color.fromRGBO(225, 255, 199, 1.0) : Colors.white,
                      child: Text(
                        text,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              isMe == true
                  ? Text('') : Text(''),
            ],
          ),
        ],
      ),
    );
  }
}
