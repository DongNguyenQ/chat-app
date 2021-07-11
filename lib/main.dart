import 'dart:io';

import 'package:chat_app/repository/authentication_repository.dart';
import 'package:chat_app/service/authentication_service.dart';
import 'package:chat_app/service/push_notification_service.dart';
import 'package:chat_app/ui/home_screen.dart';
import 'package:chat_app/viewmodel/authentication_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';


//
// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel', // id
//   'High Importance Notifications', // title
//   'This channel is used for important notifications.', // description
//   importance: Importance.high,
// );
// final FlutterLocalNotificationsPlugin local = FlutterLocalNotificationsPlugin();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService().initialise();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await local.resolvePlatformSpecificImplementation
  //         <AndroidFlutterLocalNotificationsPlugin>()
  //         ?.createNotificationChannel(channel);

  runApp(MyApp());
}

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print('HANDLING A BACKGROUND MESSAGE : ${message.messageId}');
//   RemoteNotification notification = message.notification!;
//   AndroidNotification android = message.notification!.android!;
//   print('SHOW LOCAL NOTI');
//   local.show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       NotificationDetails(
//           android: AndroidNotificationDetails(
//               channel.id,
//               channel.name,
//               channel.description,
//               icon: android.smallIcon,
//             priority: Priority.high,
//             importance: Importance.max,
//             // showWhen: false
//           )
//       )
//   );
// }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    // var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    //
    // messaging = FirebaseMessaging.instance;
    // messaging.getToken().then((value) =>
    //   print('INITIAL TOKEN : $value')
    // );
    // messaging.onTokenRefresh.listen((String refreshedToken) {
    //   print('TOKEN WAS REFRESHED : $refreshedToken');
    // });
    // local.initialize(initializationSettings);
    //
    // // Handle Message in foreground
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('MESSAGE FOREGROUND RECEIVED : ${message.notification!.body}');
    //   RemoteNotification notification = message.notification!;
    //   AndroidNotification android = message.notification!.android!;
    //
    //   // if (notification != null && android != null) {
    //     print('SHOW LOCAL NOTIFICATION');
    //     local.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //           android: AndroidNotificationDetails(
    //             channel.id,
    //             channel.name,
    //             channel.description,
    //             icon: android.smallIcon
    //           )
    //         )
    //     );
    //   // }
    // });
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print('USER CLICKED ON MESSAGE');
    // });
  }


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

