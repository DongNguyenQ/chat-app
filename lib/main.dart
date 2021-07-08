import 'package:chat_app/repository/authentication_repository.dart';
import 'package:chat_app/service/authentication_service.dart';
import 'package:chat_app/ui/home_screen.dart';
import 'package:chat_app/viewmodel/authentication_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
