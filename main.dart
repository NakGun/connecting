import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecting/data/message.dart';
import 'package:connecting/pages/home/home_page.dart';
import 'package:connecting/pages/login/auth_page.dart';
import 'package:connecting/pages/login/join_page.dart';
import 'package:connecting/pages/login/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:connecting/contstants/constants.dart';
import 'package:connecting/data/connecting_option.dart';
import 'package:connecting/data/my_user_data.dart';
import 'package:connecting/firebase/firestore_provider.dart';
import 'package:connecting/l10n/gallery_localizations.dart';
import 'package:connecting/themes/gallery_theme_data.dart';
import 'package:connecting/widgets/my_progress_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';


void setOverrideForDesktop() {
  if (kIsWeb) return;

  if (Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  } else if (Platform.isFuchsia) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setOverrideForDesktop();
  GoogleFonts.config.allowHttp = false;
  runApp(ChangeNotifierProvider<MyUserData>(
      create: (context) => MyUserData(), child: LayoutApp()));
}

class LayoutApp extends StatelessWidget {
  ProgressDialog pr;

  final FirebaseMessaging _messaging = FirebaseMessaging();
  final List<Message> messages = [];
  init(){
    _messaging.getToken().then((token){
      print('token=======================================${token}');
    });
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
      },
    );
    _messaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  @override
  Widget build(BuildContext context) {
    init();
    return ModelBinding(
      initialModel: ConnectingOptions(
        themeMode: ThemeMode.system,
        textScaleFactor: systemTextScaleFactorOption,
        customTextDirection: CustomTextDirection.localeBased,
        locale: null,
        timeDilation: timeDilation,
        platform: defaultTargetPlatform,
      ),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'Connecting',
            debugShowCheckedModeBanner: false,
            themeMode: ConnectingOptions
                .of(context)
                .themeMode,
            theme: GalleryThemeData.lightThemeData.copyWith(
              platform: ConnectingOptions
                  .of(context)
                  .platform,
            ),
            darkTheme: GalleryThemeData.darkThemeData.copyWith(
              platform: ConnectingOptions
                  .of(context)
                  .platform,
            ),
            localizationsDelegates: [
              ...GalleryLocalizations.localizationsDelegates,
              LocaleNamesLocalizationsDelegate()
            ],
            supportedLocales: GalleryLocalizations.supportedLocales,
            locale: ConnectingOptions
                .of(context)
                .locale,
            localeResolutionCallback: (locale, supportedLocales) {
              deviceLocale = locale;
              return locale;
            },

            home: Consumer<MyUserData>(
              builder: (context, myUserData, child) {
                //myUserData.setNewStatus(MyUserDataStatus.none);

                //print('11111111111111111111111111111111111${myUserData.status}');
                switch (myUserData.status) {
                  case MyUserDataStatus.progress:
                    FirebaseAuth.instance.currentUser().then((firebaseUser) {
//                      Provider.of<MyUserData>(context, listen: false).clearUser();
//                      FirebaseAuth.instance.signOut();
                      if (firebaseUser == null) {
                        myUserData.setNewStatus(MyUserDataStatus.none);
                      } else {
                        firestoreProvider.connectMyUserData(firebaseUser.uid).listen((user) async {
                          await myUserData.setUserData(user);
                        });
                      }
                    });
                    return MyProgressIndicator();

                  case MyUserDataStatus.exist:
                    if(myUserData.data.username.isNotEmpty){
                      return ApplyTextOptions(
                        child: HomePage(),
                      );
                    }else{
                      return ApplyTextOptions(
                        child: AuthPage(),
                      );
                    }
                    return MyProgressIndicator();

                  case MyUserDataStatus.first:
                    return ApplyTextOptions(
                      child: JoinPage(pageTp:'First', user: myUserData.data,),
                    );
                  default:
                    print('LoginPage~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!');
                    return ApplyTextOptions(
                      child: AuthPage(),
                    );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
