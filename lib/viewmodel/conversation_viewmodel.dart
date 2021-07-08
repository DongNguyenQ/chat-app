import 'package:chat_app/repository/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConversationViewModel extends ChangeNotifier {
  final UserRepository _repository;
  ConversationViewModel(this._repository);

  Stream<QuerySnapshot>? _users;
  bool _isBusy = false;
  String? _error;

  Stream<QuerySnapshot>? get users => this._users;
  bool get busy => this._isBusy;
  String? get error => this._error;

  void getUsers() {
    _setBusy(true);
    this._users = _repository.getUsersRemote();
    _setBusy(false);
  }

  void _setBusy(bool isBusy) {
    this._isBusy = isBusy;
    notifyListeners();
  }
}