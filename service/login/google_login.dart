import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecting/data/my_user_data.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<FirebaseUser> GoogleLogin(BuildContext context) async {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  //FirebaseUser user = await _auth.currentUser();
  AuthResult result = await _auth.signInWithCredential(
    GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken)
  );

  FirebaseUser user = result.user;
  return user;
}