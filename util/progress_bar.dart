import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

void progressBar(BuildContext context){
  ProgressDialog pr;
  pr = new ProgressDialog(context);
  pr.style(
      message: 'Please Waiting...',
      borderRadius: 5.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 10.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w600)
  );

  pr.show();
}


