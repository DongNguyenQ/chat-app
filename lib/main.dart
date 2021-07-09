import 'dart:io';

import 'package:chat_app/repository/authentication_repository.dart';
import 'package:chat_app/service/authentication_service.dart';
import 'package:chat_app/ui/home_screen.dart';
import 'package:chat_app/viewmodel/authentication_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initFirebaseNotification();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _authenService = AuthenticationServiceImpl();
    final _authenRepo = AuthenticationRepositoryImpl(_authenService);
    return ChangeNotifierProvider(
      create: (context) => AuthenticationViewModel(_authenRepo),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              }
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent
          )
        ),
        home: HomeScreen(),
      ),
    );
  }
}


Future<void> initFirebaseNotification() async {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  NotificationSettings settings = await firebaseMessaging.requestPermission(
    alert: true, announcement: false, badge: true, carPlay: false,
    criticalAlert: false, provisional: false, sound: true
  );
  print('User granted permission: ${settings.authorizationStatus}');
  print('settings : ${settings.toString()}');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // if (message.notification != null) {
    //   print('Message also contained a notification: ${message.notification}');
    // }
    // Platform.isAndroid
    //     ? showNotification()
  });
}