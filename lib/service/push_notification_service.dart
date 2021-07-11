import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


// https://www.freecodecamp.org/news/local-notifications-in-flutter/
class PushNotificationService {
  static FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin _localNotification
      = FlutterLocalNotificationsPlugin();
  static AndroidNotificationChannel _androidChannel
      = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static Future initialize() async {
    String? token = await _getToken();
    print('TOKEN : ${token ?? 'NO TOKEN'}');
    var initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    _localNotification.initialize(InitializationSettings(android: initSettingsAndroid));
    _localNotification.resolvePlatformSpecificImplementation
              <AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(_androidChannel);

    // Handle noti when device went background
    FirebaseMessaging.onBackgroundMessage(_firebaseNotificationHandler);

    // Handle noti when device is foreground activating
    FirebaseMessaging.onMessage.listen(_firebaseNotificationHandler);

    // Hanlde when user click on noti
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('USER CLICK');
      FlutterAppBadger.removeBadge();
    });

  }

  static Future<String?> _getToken() async {
    return await _fcm.getToken();
  }

  static Future<void> _firebaseNotificationHandler(RemoteMessage message) async {
    print('HANDLING MESSAGE : ${message.notification!.body} \n '
        'TITLE : ${message.notification!.title} \n '
        'URL : ${message.notification!.android!.imageUrl}');
    FlutterAppBadger.updateBadgeCount(1);
    RemoteNotification notification = message.notification!;
    AndroidNotification android = message.notification!.android!;
    print('SHOW LOCAL NOTI');
    // _localNotification.
    _localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              _androidChannel.description,
              icon: android.smallIcon,
              priority: Priority.high,
              importance: Importance.max,
              showWhen: true
            )
        )
    );
  }

  static void _firebaseNotiActionHandler(RemoteMessage message) {
    print('USER CLICKED ON MESSAGE');
    // return null;
    FlutterAppBadger.removeBadge();
  }

}