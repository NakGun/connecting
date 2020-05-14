import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/data/setup_rcv.dart';
import 'package:connecting/data/user.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MySetting extends StatefulWidget {

  final Map<String, dynamic> setInfo;

  const MySetting({Key key, this.setInfo}) : super(key: key);

  @override
  _MySettingState createState() => _MySettingState();
}

class _MySettingState extends State<MySetting> {
  RangeValues age = RangeValues(10.0, 40.0);
  double distance = 10.0;
  RangeValues tall = RangeValues(100.0, 300.0);
  int selectSex = 0;
  String revYN = 'Y';

  @override
  void initState() {
    //SetupRCV setInfo = firestoreProvider.MySettingData(Provider.of<MyUserData>(context).data.username);
    print('setInfo : ${widget.setInfo}');
    age = RangeValues(widget.setInfo['beginAge'].toDouble(), widget.setInfo['endAge'].toDouble());
    tall = RangeValues(widget.setInfo['beginTall'].toDouble(), widget.setInfo['endTall'].toDouble());
    distance = widget.setInfo['distance'].toDouble();
    selectSex = widget.setInfo['gender'];
    revYN = widget.setInfo['alarmYN'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        'Date Setting',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(thickness: 1,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text('성별', style: TextStyle(fontWeight: FontWeight.bold),)),
                  selectSex == 1 ? Text('남자와 데이트') : selectSex == 2 ? Text('여자와 데이트') : selectSex == 0 ? Text('모두와 데이트') : Text('선택하세요'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  Radio(
                    value: 0,
                    groupValue: selectSex,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) {
                      setState(() {
                        selectSex = value;
                      });
                    },
                  ),
                  Text('모두'),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  Radio(
                    value: 1,
                    groupValue: selectSex,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) {
                      setState(() {
                        selectSex = value;
                      });
                    },
                  ),
                  Text('남자'),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  Radio(
                    value: 2,
                    groupValue: selectSex,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) {
                      setState(() {
                        selectSex = value;
                      });
                    },
                  ),
                  Text('여자'),
                ],
              ),
            ),
            Container(height: 10, color: Colors.grey[200],),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text('AGE', style: TextStyle(fontWeight: FontWeight.bold),)),
                  Text('${age.start.round()} ~ ${age.end.round()}'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: RangeSlider(
                values: age,
                min: 0,
                max: 200,
                divisions: 100,
                activeColor: Colors.pinkAccent,
                onChanged: (value){
                  setState(() {
                    age = value;
                  });
                },
              ),
            ),
            Container(height: 10, color: Colors.grey[200],),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text('DISTANCE', style: TextStyle(fontWeight: FontWeight.bold),)),
                  Text('${distance.round()} Km'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Slider(
                value: distance,
                min: 0,
                max: 100000,
                divisions: 100,
                activeColor: Colors.pinkAccent,
                onChanged: (value){
                  setState(() {
                    distance = value;
                  });
                },
              ),
            ),
            Container(height: 10, color: Colors.grey[200],),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text('키', style: TextStyle(fontWeight: FontWeight.bold),)),
                  Text('${tall.start.round()} ~ ${tall.end.round()} Cm' ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: RangeSlider(
                values: tall,
                min: 0,
                max: 500,
                divisions: 50,
                activeColor: Colors.pinkAccent,
                onChanged: (value){
                  setState(() {
                    tall = value;
                  });
                },
              ),
            ),
            Container(height: 10, color: Colors.grey[200],),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text('알람수신여부', style: TextStyle(fontWeight: FontWeight.bold),)),
                  revYN == 'Y' ? Text('알람수신') : Text('알람수신거부'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  Radio(
                    value: 'Y',
                    groupValue: revYN,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) {
                      setState(() {
                        revYN = value;
                      });
                    },
                  ),
                  Text('수신'),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60),
                  ),
                  Radio(
                    value: 'N',
                    groupValue: revYN,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) {
                      setState(() {
                        revYN = value;
                      });
                    },
                  ),
                  Text('미수신'),
                ],
              ),
            ),
            Align(
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
                    ///추가정보 업데이트
                    final Map<String, dynamic> settingData =
                    SetupRCV.getMapForSettingInfo(
                        distance,
                        age.start,
                        age.end,
                        tall.start,
                        tall.end,
                        selectSex,
                        revYN);
                    await firestoreProvider.userSetUpdate(
                        Provider.of<MyUserData>(context, listen: false).data.username, settingData);

                    Navigator.pop(context);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
