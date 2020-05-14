import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:connecting/pages/home/manage_page.dart';
import 'package:connecting/pages/home/profile_page.dart';
import 'package:connecting/widgets/my_setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connecting/data/my_user_data.dart';
import 'package:provider/provider.dart';

class ProfileSideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: Colors.grey[300]))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              'My Menu',
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            color: Colors.grey[300],
            height: 1,
          ),
          FlatButton.icon(
              onPressed: () async {
                Map<String, dynamic> setInfo = await firestoreProvider
                    .mySetupData(Provider.of<MyUserData>(context, listen: false)
                        .data
                        .username);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MySetting(setInfo: setInfo)));
              },
              icon: ImageIcon(
                AssetImage('assets/setting.png'),
                size: 15,
              ),
              label: Text(
                '데이트설정',
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w500),
              )),
          FlatButton.icon(
              onPressed: () {
                //clear 후 notice함
                Provider.of<MyUserData>(context, listen: false).clearUser();
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(
                Icons.exit_to_app,
                size: 15,
              ),
              label: Text(
                'Log out',
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w500),
              )),
          FlatButton.icon(
              onPressed: () async {
                var userKey = Provider.of<MyUserData>(context, listen: false).data.userKey;
                //clear 후 logout 함
                Provider.of<MyUserData>(context, listen: false).clearUser();
                FirebaseAuth.instance.signOut();
                //delete
                Firestore.instance.collection("Users").document(userKey).delete();
              },
              icon: ImageIcon(
                AssetImage('assets/exit.png'),
                size: 15,
              ),
              label: Text(
                '회원탈퇴',
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w500),
              )),
          Provider.of<MyUserData>(context, listen: false).data.email ==
                  'chnaan@gmail.com'
              ? FlatButton.icon(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ManagePage()));
                  },
                  icon: Icon(
                    Icons.settings,
                    size: 15,
                  ),
                  label: Text(
                    '관리자메뉴',
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.w500),
                  ))
              : Container(),
//          FlatButton.icon(
//              onPressed: () {
////                Navigator.pushAndRemoveUntil(context,
////                    MaterialPageRoute(builder: (context) => HomePage(number: 1)),
////                    ModalRoute.withName('/'));
//              },
//              icon: ImageIcon(
//                AssetImage('assets/heart_selected.png'), size: 15,),
//              label: Text('친구목록', style: TextStyle(
//                  color: Colors.black87, fontWeight: FontWeight.w500),)
//          ),
//          FlatButton.icon(
//              onPressed: () {
//                //Navigator.of(context).pop();
//                //Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage(number: 2,)));
////                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePage(number: 2,)));
//              //현재 화면만 없어지고 다음화면을 전화면 다음 화면으로 오픈함.
////              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage(number: 2,)));
//              //Navigator.pushAndRemoveUtil << 이동하는 화면을 첫페이지로 다른화면 모두 삭제
//
////                Navigator.pushAndRemoveUntil(context,
////                    MaterialPageRoute(builder: (context) => HomePage(number: 2)),
////                    ModalRoute.withName('/'));
//              },
//              icon: ImageIcon(
//                AssetImage('assets/profile_selected.png'), size: 15,),
//              label: Text('프로필', style: TextStyle(
//                  color: Colors.black87, fontWeight: FontWeight.w500),)
//          ),
        ],
      ),
    );
  }
}
