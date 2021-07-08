import 'package:chat_app/service/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserRepository {
  Stream<QuerySnapshot> getUsersRemote();
}

class UserRepositoryImpl extends UserRepository {

  final UserService _service;

  UserRepositoryImpl(this._service);

  @override
  Stream<QuerySnapshot<Object?>> getUsersRemote() {
    return _service.getUsersList();
  }

}