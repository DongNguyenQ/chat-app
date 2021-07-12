import 'package:chat_app/core/failure.dart';
import 'package:chat_app/repository/authentication_repository.dart';
import 'package:chat_app/service/push_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationViewModel extends ChangeNotifier {
  final AuthenticationRepositoryImpl _repository;

  AuthenticationViewModel(this._repository);

  UserCredential? _user;
  String? _error;
  bool _isBusy = false;

  UserCredential? get user => this._user;
  String? get error => this._error;
  bool get busy => this._isBusy;

  void signInUserByGoogle() async {
    _setBusy(true);
    final result = await _repository.signInByGoogle();
    result.fold((failure) => this._error = failure.error,
        (success) {
          this._user = success;
          print('RESULT : ${success.user!.displayName}');
        });
    String? token = await PushNotificationService.getToken();
    _setBusy(false);
  }

  void _setBusy(bool isBusy) {
    this._isBusy = isBusy;
    notifyListeners();
  }

  void signOut() {
    _setBusy(true);
    _repository.signOut();
    this._user = null;
    this._error = null;
    _setBusy(false);
  }

  @override
  void dispose() {
    print('AUTHENTICATION VIEWMODEL DISPOSED');
    super.dispose();
  }
}
