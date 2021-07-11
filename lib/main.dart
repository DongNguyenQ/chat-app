import 'package:chat_app/repository/authentication_repository.dart';
import 'package:chat_app/service/authentication_service.dart';
import 'package:chat_app/service/push_notification_service.dart';
import 'package:chat_app/ui/home_screen.dart';
import 'package:chat_app/viewmodel/authentication_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService.initialize();

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

