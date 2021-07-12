import 'package:chat_app/const/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 2021 : Detail abour local notification : https://www.freecodecamp.org/news/local-notifications-in-flutter/
// 2021 : https://blog.logrocket.com/flutter-push-notifications-with-firebase-cloud-messaging/
// 2021 : Nice detail, IOS + Android : https://www.youtube.com/watch?v=0flR0vLRKPo
// 2021 : Nice So Detail : https://www.youtube.com/watch?v=p7aIZ3aEi2w&t=3155s
// Guideline push notification by Firebase function :
//    https://medium.com/@duytq94/flutter-chat-app-extended-push-notification-messages-a26c669f4675
//    -> Can't start function firebase because no account
// https://medium.com/flutter-community/building-a-chat-app-with-flutter-and-firebase-from-scratch-9eaa7f41782e

// Chat App Ref :
// + https://www.youtube.com/watch?v=X00Xv7blBo0
// + https://www.youtube.com/watch?v=wHIcJDQbBFs
// + Nice, provider package : https://www.youtube.com/watch?v=gU3iSH8qkVo
// + Nice, group chat : https://github.com/ahmedgulabkhan/GroupChatApp


// But if the app is in terminated state and is brought back by tapping
// on the notification, this method won’t be enough to retrieve the information.
// Define a method called checkForInitialMessage() and add the following to it:
// https://blog.logrocket.com/flutter-push-notifications-with-firebase-cloud-messaging/

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

    // Get message when the app is terminated and user click on notification,
    // Iff app is terminated, the onMessage can't be called.
    // So we need to get initMessage
    // Need to check
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _firebaseNotificationHandler(initialMessage);
      _firebaseNotiActionHandler(initialMessage);
    }

    // Handle noti when device went background
    FirebaseMessaging.onBackgroundMessage(_firebaseNotificationHandler);

    // Handle noti when device is foreground activating
    FirebaseMessaging.onMessage.listen(_firebaseNotificationHandler);

    // Hanlde when user click on noti
    FirebaseMessaging.onMessageOpenedApp.listen(_firebaseNotiActionHandler);

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

  static Future<String?> getToken() async {
    return await _fcm.getToken();
  }

}