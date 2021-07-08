import 'package:chat_app/viewmodel/authentication_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthenticationViewModel>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('LOGIN'),
            SizedBox(height: 12),
            MaterialButton(
              child: Text('Login with google'),
              onPressed: vm.signInUserByGoogle,
            ),
            vm.error != null
              ? Text(vm.error!, style: TextStyle(color: Colors.red))
              : SizedBox()
          ],
        ),
      ),
    );
  }
}
