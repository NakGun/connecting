import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/data/user.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:connecting/pages/login/join_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseInfo extends StatelessWidget {
  final bool crudTp;
  final User user;

  const BaseInfo({Key key, this.crudTp, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                    child: Text(
                      '${user.username}',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 5, 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          height: 20,
                          width: 40,
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Image(
                                  width: 12,
                                  height: 12,
                                  image: user.gender == 1
                                      ? AssetImage('assets/male.png')
                                      : AssetImage('assets/female.png'),
                                ),
                              ),
                              Text(
                                '${user.age}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          height: 20,
                          width: 40,
                          child: Center(
                              child: Text(
                            '${user.city}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12),
                          )),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              child: FlatButton(
                onPressed: () {
                  crudTp == true
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => JoinPage(pageTp: 'Profile', user: user)))
                      : null;
                },

                ///userid가 본인일 경우만 아이콘 생성
                child: crudTp == true ? Icon(Icons.arrow_forward) : null,
              ),
            ),
          ],
        ),
      );
  }
}
