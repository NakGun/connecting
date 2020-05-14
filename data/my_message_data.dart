import 'package:connecting/data/message.dart';
import 'package:flutter/foundation.dart';

class MyMessageData extends ChangeNotifier {
  Message _myMessageData;
  Message get data => _myMessageData;
}