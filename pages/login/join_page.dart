import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecting/contstants/constants.dart';
import 'package:connecting/data/message.dart';
import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/data/user.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:connecting/pages/home/home_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_ip/get_ip.dart';
import 'package:kopo/kopo.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class JoinPage extends StatefulWidget {
  final String pageTp;
  final User user;

  const JoinPage({Key key, @required this.pageTp, @required this.user})
      : super(key: key);

  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _city = TextEditingController();
  TextEditingController _tall = TextEditingController();

  String addressJSON = '';
  int _selectSex = 0;
  String _alarmYN = 'Y';
  String selectedAge = '30';

  final FirebaseMessaging _messaging = FirebaseMessaging();
  String token = '';

  @override
  void initState() {
    //first == main call, Profile  == Profile call
    if (widget.pageTp == 'Profile') {
      _nameController.text = widget.user.username;
      _city.text = widget.user.city;
      _tall.text = widget.user.tall.toString();
      _selectSex = widget.user.gender;
      selectedAge = widget.user.age.toString();
      _alarmYN = widget.user.alarmYN;

      if (widget.user.age == null) {
        selectedAge = '30';
      }
    }
    //알람토큰생성
    _messaging.getToken().then((deviceToken){
      token = deviceToken;
    });
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _city.dispose();
    _tall.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[100],
          title: Text(
            'PROFILE',
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w100,
                fontSize: 20),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - 80,
            child: Form(
              key: _formKey,
              child: Column(
                //mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: getName(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: sexType(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: getAge(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: getAddress(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: getTall(),
                  ),
//                  Padding(
//                    padding: const EdgeInsets.symmetric(vertical: 20.0),
//                    child: alarmYN(),
//                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        color: Colors.orange,
                        child: FlatButton(
                          child: Text(
                            '저장',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () async {
                            print('doc.data');
                            var cnt = 0;
                            var nameValidYN = 'Y';
                            if (_formKey.currentState.validate()) {
                              print('doc.data2');
                              //대화명검증
                              await Firestore.instance
                                  .collection("Users")
                                  .where('username', isEqualTo: _nameController.text)
                                  .getDocuments()
                                  .then((ds) {
                                    ds.documents.forEach((doc) async {
                                      print('doc.data4 : ${doc.data}');
                                      if(cnt == 0) {
                                        if (doc.data != null) {
                                          cnt++;
                                          Alert(
                                            context: context,
                                            //type: AlertType.info,
                                            title: "알림",
                                            desc: "이미 존재하는 명칭(이름)입니다.",
                                            buttons: [
                                              DialogButton(
                                                child: Text(
                                                  "OK",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                color: Color.fromRGBO(
                                                    0, 179, 134, 1.0),
                                                radius: BorderRadius.circular(
                                                    0.0),
                                              ),
                                            ],
                                          ).show();
                                          nameValidYN = 'N';
                                        }
                                      }
                                });
                              });

                              if(nameValidYN == 'Y'){
                                //기본인적사항 업로드
                                final Map<String, dynamic> userData =
                                User.getMapForCreateBaseInfo(
                                  _nameController.text,
                                  _city.text,
                                  int.parse(selectedAge),
                                  int.parse(_tall.text),
                                  _selectSex,
                                  widget.user.username.isNotEmpty
                                      ? widget.user.talkCount
                                      : 100,
                                  await GetIp.ipAddress,
                                  //ip
                                  'Y',
                                );

                                await firestoreProvider.userBaseUpdate(widget.user.userKey, userData);

                                ///회원가입이 아닐경우만
                                if (widget.user.username.isNotEmpty) {
                                  Navigator.pop(context);

                                  ///회원가입인 경우 수신조회 기본설정으로 셋팅(신규생성)
                                } else {
                                  Firestore.instance.collection(
                                      "SetupRCV").add({
                                    "username": _nameController.text,
                                    "token": token,
                                    "gender": 0, //0:모두, 1:남자, 2:여자
                                    "distance": 10000,
                                    "beginAge": 0,
                                    "endAge": 200,
                                    "beginTall": 0,
                                    "endTall": 300,
                                    "blockName": [],
                                    "alarmYN": 'Y',
                                  });
                                }

                                Provider.of<MyUserData>(context, listen: false).setNewStatus(MyUserDataStatus.progress);
                                //Navigator.pop(context);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row getName() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text(
            '명칭 : ',
            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 15),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width - 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey[300],
                  ),
                ),
                hintText: '별명',
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return '명칭을 넣어주세요';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Row getAge() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 15),
          child: Text(
            '나이 : ',
            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 15),
          ),
        ),
        androidDropdown(),
      ],
    );
  }

  void showSnakBar() {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('명칭을 넣어주세요.'),
      ),
    );
  }

  Row getAddress(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text(
            '주소 : ',
            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 15),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width - 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: TextFormField(
              controller: _city,
              readOnly: true,
              validator: (String value) {
                if (value.isEmpty) {
                  return '주소는 필수입니다.';
                }
                return null;
              },
              decoration: InputDecoration.collapsed(
                hintText: '서울',
              ),
            ),
          ),
        ),
        MaterialButton(
          height: 25,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.grey[300],
          child: Text(
            '주소검색',
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () async {
            KopoModel model = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Kopo(),
                ));
//                    print('11111111111${model.toJson()}');
            setState(() {
              _city.text = '${model.sido}';
            });
          },
        ),
      ],
    );
  }

  Row sexType() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            '남/녀 : ',
            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 15),
          ),
        ),
        Radio(
          value: 1,
          groupValue: _selectSex,
          activeColor: Colors.blueAccent,
          onChanged: (value) {
            setState(() {
              _selectSex = value;
            });
          },
        ),
        Text('남자'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
        Radio(
          value: 2,
          groupValue: _selectSex,
          activeColor: Colors.blueAccent,
          onChanged: (value) {
            setState(() {
              _selectSex = value;
            });
          },
        ),
        Text('여자'),
      ],
    );
  }

  Row alarmYN() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            '알람여부 : ',
            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 15),
          ),
        ),
        Radio(
          value: 'Y',
          groupValue: _alarmYN,
          activeColor: Colors.blueAccent,
          onChanged: (value) {
            setState(() {
              _alarmYN = value;
            });
          },
        ),
        Text('알람수신'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
        Radio(
          value: 'N',
          groupValue: _alarmYN,
          activeColor: Colors.blueAccent,
          onChanged: (value) {
            setState(() {
              _alarmYN = value;
            });
          },
        ),
        Text('미수신'),
      ],
    );
  }

  Row getTall() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text(
            '키 : ',
            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 15),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width - 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: TextFormField(
              controller: _tall,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey[300],
                  ),
                ),
                hintText: '키',
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return '키는 필수입니다.';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  DropdownButton<String> androidDropdown() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (String currency in ageList) {
      var newItem = DropdownMenuItem(
        child: Text(currency),
        value: currency,
      );
      dropdownItems.add(newItem);
    }

    return DropdownButton<String>(
      value: selectedAge,
      items: dropdownItems,
      onChanged: (value) {
        setState(() {
          selectedAge = value;
        });
      },
    );
  }

  InputDecoration getTextFieldDecor(String hint) {
    return InputDecoration(
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[300],
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        //포커싱되었을때 다르게 그릴수 있다 focusedBorder
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[300],
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: Colors.grey[100],
        filled: true);
  }
}
