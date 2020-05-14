import 'package:connecting/pages/home/home_page.dart';
import 'package:connecting/pages/home/users_page.dart';
import 'package:flutter/material.dart';
import 'package:connecting/data/user.dart' as MyUser;
import 'package:bootpay_api/bootpay_api.dart';
import 'package:bootpay_api/model/payload.dart';
import 'package:bootpay_api/model/extra.dart';
import 'package:bootpay_api/model/user.dart';
import 'package:bootpay_api/model/item.dart';

class CreditPage extends StatefulWidget {
  final MyUser.User myUser;

  const CreditPage({Key key, this.myUser}) : super(key: key);
  @override
  _CreditPageState createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    goBootpayRequest(context);
    return CircularProgressIndicator();
//    return Scaffold(
//        appBar: AppBar(
//          title: const Text('Plugin example app'),
//        ),
//        body: Container(
//          child:  RaisedButton(
//            onPressed: () {
//              goBootpayRequest(context);
//            },
//            child: Text("부트페이 결제요청"),
//          ),
//        )
//    );
  }

  void goBootpayRequest(BuildContext context) async {
    Payload payload = Payload();
    payload.androidApplicationId = '5eb9555a02f57e00291ee2f5';
    //payload.iosApplicationId = '5b8f6a4d396fa665fdc2b5e9';

    payload.pg = 'kcp';
    //payload.method = 'Method.CARD';
    payload.methods = ['card', 'phone', 'vbank', 'bank'];
    payload.name = 'testUser';
    payload.price = 7000.0;
    payload.orderId = DateTime.now().millisecondsSinceEpoch.toString();

    User user = User();
    user.username = widget.myUser.username;
    user.email = widget.myUser.email;
    user.area = widget.myUser.city;
   // user.phone = "010-1234-4567";

    Extra extra = Extra();
    extra.appScheme = 'bootpayFlutterSample';

    Item item1 = Item();
    item1.itemName = '쪽지';
    item1.qty = 1; // 해당 상품의 주문 수량
    item1.unique = "ConnectingMemoCount"; // 해당 상품의 고유 키
    item1.price = 7000; // 상품의 가격

//    Item item2 = Item();
//    item2.itemName = "키보드"; // 주문정보에 담길 상품명
//    item2.qty = 1; // 해당 상품의 주문 수량
//    item2.unique = "ITEM_CODE_KEYBOARD"; // 해당 상품의 고유 키
//    item2.price = 1000; // 상품의 가격
//    List<Item> itemList = [item1, item2];
    List<Item> itemList = [item1];

    BootpayApi.request(
      context,
      payload,
      extra: extra,
      user: user,
      items: itemList,
      onDone: (String json) {
        print('onDone: $json');
      },
      onReady: (String json) {
        print('onReady: $json');
      },
      onCancel: (String json) {
        print('onCancel: $json');
        //Navigator.push(context, MaterialPageRoute(builder: (context)=>UsersPage()));
        Navigator.pop(context);
      },
      onError: (String json) {
        print('onError: $json');
      },
    );
  }
}
