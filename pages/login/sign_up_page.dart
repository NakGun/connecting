import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:connecting/service/login/google_login.dart';
import 'package:connecting/util/siimple_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connecting/widgets/onboardingImageclipper.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  TextEditingController _cpwController = TextEditingController();

  @override
  void dispose(){
    _emailController.dispose();
    _pwController.dispose();
    _cpwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipPath(
                    clipper: OnBoardingImageClipper(),
                    child: Container(
                      width: double.infinity,
                      height: 445,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            width: MediaQuery.of(context).size.width,
                            child: Image(
                              image: AssetImage('assets/joinImage2.jpg'),
                            )
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: double.infinity,
                              height: 340,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.8),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
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
                                    color: Colors.black,
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
                  ),
                  Positioned(
                    right: 30,
                    bottom: 0,
                    child: Text(
                      'REGISTER',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                ],
              ),
              buildUserName(),
              buildUserPassWord(),
              buildUserPassWordConfirm(),
              FlatButton(
                child: Text('가입신청', style: TextStyle(color: Colors.grey[700]),),
//              color: Colors.red,
//              shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.circular(6),
//              ),
//              disabledColor: Colors.blue[100],
                onPressed: (){
                  //이벤트시마다 모든 폼필드의 vaildate를 실행함.
                  if(_formKey.currentState.validate()) {
                    _resister;
                  }
                },
              ),
//            Padding(
//              padding: const EdgeInsets.symmetric(vertical: 100.0),
//              child: Column(
//                children: <Widget>[
//                  FlatButton(
//                    textColor: Colors.white,
//                    onPressed: () async {
//                      FirebaseUser user = await GoogleLogin(context);
//                      await firestoreProvider.attemptCreateUser(
//                          userKey: user.uid,
//                          email: user.email,
//                          context: context);
//                    },
//                    child: Container(
//                      width: 300,
//                      height: 30,
//                      decoration: BoxDecoration(
//                        color: Colors.redAccent,
//                        borderRadius: BorderRadius.circular(10),
//                      ),
//                      child: Center(
//                        child: Text(
//                          'Google',
//                          style: TextStyle(
//                            fontSize: 20,
//                          ),
//                        ),
//                      ),
//                    ),
//                  ),
//                ],
//              ),
//            )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserName(){
    return Container(
      width: double.infinity,
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(0,4),
            )
          ]
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 4, left: 24, right: 16),
        child: TextFormField(
          decoration: InputDecoration(
            errorStyle: TextStyle(fontSize: 11),
            hintText: 'UserName',
            hintStyle: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 10,
            ),
            //enabledBorder: InputBorder.none,
            suffixIcon: Icon(Icons.person, size: 15, ),
          ),
          controller: _emailController,
          validator: (String value) {
            if (value.isEmpty || !value.contains('@')) {
              return 'Please enter your email address!';
            }
            return null;
          },
        ),
      ),
    );
  }
  Widget buildUserPassWord(){
    return Container(
      width: double.infinity,
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(0,4),
            )
          ]
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 4, left: 24, right: 16),
        child: TextFormField(
          obscureText: true,
          controller: _pwController,
          validator: (String value){
            if(value.isEmpty){
              return 'Please enter your any password!';
            }
            return null;
          },
          decoration: InputDecoration(
            errorStyle: TextStyle(fontSize: 11),
            hintText: 'PassWord',
            hintStyle: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 10,
            ),
            //enabledBorder: InputBorder.none,
            //suffixIcon: Icon(Icons.remove_red_eye),
          ),
        ),
      ),
    );
  }

  Widget buildUserPassWordConfirm(){
    return Container(
      width: double.infinity,
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(0,4),
            )
          ]
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 4, left: 24, right: 16),
        child: TextFormField(
          obscureText: true,
          controller: _cpwController,
          validator: (String value){
            if(_pwController.text != value||value.isEmpty){
              return 'Diffrent password and passwrdConfirm!';
            }
            return null;
          },
          decoration: InputDecoration(
            errorStyle: TextStyle(fontSize: 11),
            hintText: 'PassWordConfirm',
            hintStyle: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 10,
            ),
            //enabledBorder: InputBorder.none,
            //suffixIcon: Icon(Icons.remove_red_eye),
          ),
        ),
      ),
    );
  }

  get _resister async {
    AuthResult result;
    try{
      result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _pwController.text
      );
    } catch (e){
      simpleSnackbar(context, e.message);
      //return null;
    }

    final FirebaseUser user = result.user;

    if(user == null){
      simpleSnackbar(context, 'Please try again later');
    }else{
      await firestoreProvider.attemptCreateUser(userKey: user.uid, email: user.email);
      Provider.of<MyUserData>(context, listen: false).setNewStatus(MyUserDataStatus.progress);
    }
  }
}
