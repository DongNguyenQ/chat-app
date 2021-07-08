import 'package:chat_app/core/failure.dart';
import 'package:chat_app/service/authentication_service.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, UserCredential>> signInByGoogle();
  Future<void> signOut();
}

class AuthenticationRepositoryImpl extends AuthenticationRepository {
  final AuthenticationService _service;

  AuthenticationRepositoryImpl(this._service);

  @override
  Future<Either<Failure, UserCredential>> signInByGoogle() {
    final result = _service.signInByGoogle();
    return result;
  }

  @override
  Future<void> signOut() async {
    _service.signOutFirebase();
  }
}
