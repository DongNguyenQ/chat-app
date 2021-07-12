import 'package:chat_app/const/firestore.dart';
import 'package:chat_app/core/failure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthenticationService {
  Future<Either<Failure, UserCredential>> signInByGoogle({String? pushNotiToken});
  Future<Either<Failure, UserCredential>> signInByFacebook();
  Future<void> signOutFirebase();
}

class AuthenticationServiceImpl extends AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<Either<Failure, UserCredential>> signInByFacebook() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserCredential>> signInByGoogle({String? pushNotiToken}) async {
    try {
      final GoogleSignInAccount? account = await GoogleSignIn().signIn();
      if (account != null) {
        final GoogleSignInAuthentication googleAuth =
            await account.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential user =
            await _firebaseAuth.signInWithCredential(credential);
        print('USER CREDENTIAL : ${user.user!.displayName}');
        if (user.user != null) {
          _saveUserToDocument(user, token: pushNotiToken);
        }
        return Right(user);
      }
      return Left(Failure('Not found user'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<bool> _saveUserToDocument(UserCredential user, {String? token}) async {
    print('TOKEN : $token');
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection(userDocument)
          .where('id', isEqualTo: user.user!.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.length == 0) {
        FirebaseFirestore.instance
            .collection(userDocument)
            .doc(user.user!.uid)
            .set({
          'nickname': user.user!.displayName,
          'photoUrl': user.user!.photoURL,
          'id': user.user!.uid,
          'pushToken': token
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> signOutFirebase() async {
    _firebaseAuth.signOut();
  }
}
