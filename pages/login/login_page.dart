import 'dart:ui';

import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:connecting/service/login/google_login.dart';
import 'package:connecting/util/siimple_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connecting/widgets/onboardingImageclipper.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Form(
          key: _formKey,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0.0,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width + 25,
                child: Image(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/loginImage.jpg'),
                ),
              ),
              ListView(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 445,
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              left: 10,
                              top: 40,
                              child: Text(
                                'CONNECT',
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            Positioned(
                              top: 70,
                              left: 20,
                              child: Text(
                                'PEOPLE',
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              top: 120,
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: 'Oniyuni ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' Stduio',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF4A4A4A),
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  buildUserName(),
                  buildUserPassWord(),
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FlatButton(
                      child: Center(
                        child: Text(
                          '로그인',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w100),
                        ),
                      ),
//              color: Colors.red,
//              shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.circular(6),
//              ),
//              disabledColor: Colors.blue[100],
                      onPressed: () {
                        //이벤트시마다 모든 폼필드의 vaildate를 실행함.
                        if (_formKey.currentState.validate()) {
                          _login;
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FlatButton(
                          textColor: Colors.white,
                          onPressed: () async {
                            FirebaseUser user = await GoogleLogin(context);
                            await firestoreProvider.attemptCreateUser(userKey: user.uid, email: user.email,context: context);
                            Provider.of<MyUserData>(context, listen: false).setNewStatus(MyUserDataStatus.progress);
                          },
                          child: Center(
                            child: Text(
                              'Google',
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.black
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  get _login async {
    AuthResult result;
    try {
      result = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text, password: _pwController.text);
    }catch (e) {
      print('${e.message}');
      if(e.message == 'There is no user record corresponding to this identifier. The user may have been deleted.'){
        simpleSnackbar(context, '사용자 정보가 없습니다.');
      }else{
        simpleSnackbar(context, e.message);
      }
      //return null;
    }

    final FirebaseUser user = result.user;

    if (user == null) {
      simpleSnackbar(context, 'ID or Password is wrong..');
    } else {
      Provider.of<MyUserData>(context, listen: false)
          .setNewStatus(MyUserDataStatus.progress);
    }
  }

  Widget buildUserName() {
    return Container(
      width: double.infinity,
      height: 58,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: EdgeInsets.only(top: 4, left: 24, right: 16),
        child: TextFormField(
          style: TextStyle(
            color: Colors.white
          ),
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
          validator: (String value) {
            if (value.isEmpty || !value.contains('@')) {
              Text('Please enter your email address!');
            }
            return null;
          },
          decoration: InputDecoration(
            fillColor: Colors.white,
            hoverColor: Colors.white,
            hintText: 'UserName',
            hintStyle: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70
            ),
            //enabledBorder: InputBorder.none,
            suffixIcon: Icon(Icons.person),
          ),
        ),
      ),
    );
  }

  Widget buildUserPassWord() {
    return Container(
      width: double.infinity,
      height: 58,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: EdgeInsets.only(top: 4, left: 24, right: 16),
        child: TextFormField(
          obscureText: true,
          style: TextStyle(
              color: Colors.white
          ),
          controller: _pwController,
          validator: (String value) {
            if (value.isEmpty) {
              Text('Please enter your any password!');
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'PassWord',
            hintStyle: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70
            ),
            //enabledBorder: InputBorder.none,
            suffixIcon: Icon(Icons.remove_red_eye),
          ),
        ),
      ),
    );
  }
}
