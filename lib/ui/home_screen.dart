import 'package:chat_app/ui/authentication_screen.dart';
import 'package:chat_app/ui/list_conversations_screen.dart';
import 'package:chat_app/viewmodel/authentication_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthenticationViewModel>(context);
    if (vm.busy) {
      return Center(child: CircularProgressIndicator());
    }
    if (vm.user == null) {
      return AuthenticationScreen();
    }
    return ConversationsScreen();
    // return Scaffold(
    //   body: SingleChildScrollView(
    //     child: (() {
    //       if (vm.busy)
    //       if (vm.user == null)
    //
    //     }()),
    //   ),
    // );
  }
}
