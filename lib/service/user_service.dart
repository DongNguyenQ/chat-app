import 'package:chat_app/const/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz_unsafe.dart';

abstract class UserService {
  Stream<QuerySnapshot> getUsersList();
}

class UserServiceImpl extends UserService {
  @override
  Stream<QuerySnapshot> getUsersList() {
    final query = FirebaseFirestore.instance.collection(userDocument).snapshots();
    final collectionRef = FirebaseFirestore.instance.collection(userDocument);
    final queryData = collectionRef.get().then((QuerySnapshot snapshot){
      snapshot.docs.forEach((element) {
        print('ELEMENT : ${element.toString()} - ${element['nickname']}');
      });
    });
    final oneData = collectionRef.doc('1TBXyHdqnOcMKovorAy3WxfKqZa2').get().then((value)
        => print('VALUE 1 DATA : ${value.toString()} - ${value['photoUrl']}'));
    return query;
  }

}

