import 'package:connecting/pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:connecting/pages/login/sign_up_page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  Widget currrentWidget = LoginPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: currrentWidget),
            _goToSignUpPageBtn(context),
          ],
        ),
      ),
    );
  }

  Positioned _goToSignUpPageBtn(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 40,
      child: FlatButton(
        color: Colors.white70,
        shape: Border(top: BorderSide(color: Colors.grey[300])),
        onPressed: (){
          setState(() {
            if(currrentWidget is LoginPage){
              currrentWidget = SignUpPage();
            }else{
              currrentWidget = LoginPage();
            }
          });
        },
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            //style: const TextStyle(),
              children:  <TextSpan>[
                TextSpan(
                    text: (currrentWidget is LoginPage)?"   아직 계정이 없으신가요?":"   이미 계정이 있으신가요?",
                    style:  TextStyle(fontWeight: FontWeight.w300, color: Colors.black54)
                ),
                TextSpan(
                    text: (currrentWidget is LoginPage)?"  회원가입":"   로그인",
                    style:  TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[600])
                ),
              ]
          ),
        ),
      ),
    );
  }
}
