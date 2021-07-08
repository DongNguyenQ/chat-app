import 'package:chat_app/const/firestore.dart';
import 'package:chat_app/core/failure.dart';
import 'package:chat_app/enum/chat_message_type_enum.dart';
import 'package:chat_app/model/sticker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

abstract class ChatService {
  Future uploadFile();
  Future<String?> sendMessage({
    required String idFrom,
    required String idTo,
    required int type,
    required String content,
    required String groupChatID
  });
  Stream<QuerySnapshot> getMessagesHistory({
    required String roomID, String? order, bool? isDescending, int? limit});
  void startNewConversation(String userID, String receiverID);
  Future<List<Sticker>> getStickers();
  void endConversation(String userID);
}

class ChatServiceImpl extends ChatService {
  @override
  Future uploadFile() {
    throw UnimplementedError();
  }

  @override
  Future<String?> sendMessage({
    required String idFrom, required String idTo, required int type,
    required String content, required String groupChatID}) async {
    try {
      final fireStoreInstance = FirebaseFirestore.instance;

      CollectionReference messageCollection
      = fireStoreInstance.collection(chatCollection);
      var chatRef = fireStoreInstance
          .collection(chatCollection)
          .doc(groupChatID)
          .collection(groupChatID)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      fireStoreInstance.runTransaction((transaction) async {
        await transaction.set(
            chatRef,
            {
              'idFrom': idFrom,
              'idTo': idTo,
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
              'content': content,
              'type': type
            }
        );
      });
      return null;
    } on FirebaseException catch (e) {
      print('ERROR SEND MESSAGE : ${e.message}');
      return e.message;
    } catch (e) {
      print('ERROR SEND MESSAGE : ${e.toString()}');
      return e.toString();
    }
  }

  @override
  Stream<QuerySnapshot> getMessagesHistory({
      required String roomID, String? order, bool? isDescending, int? limit}) {
    Stream<QuerySnapshot>? data;
    try {
      final messageRef = FirebaseFirestore.instance.collection(chatCollection);
      data = messageRef.doc(roomID).collection(roomID).orderBy(
          order!, descending: isDescending!).limit(limit!).snapshots();
    } on FirebaseException catch (e) {
      print('ERROR FIREBASE DETECTED : ${e.message}');
    } catch (e) {
      print('ERROR UNDETECTED : ${e.toString()}');
    }
    return data!;
  }

  @override
  void startNewConversation(String userID, String receiverID) {
    FirebaseFirestore.instance.collection(userDocument).doc(userID).update({'chattingWith': receiverID});
  }

  @override
  Future<List<Sticker>> getStickers() {
    final stickers = [
      Sticker('mimi1', 'assets/stickers/mimi1.gif'),
      Sticker('mimi2', 'assets/stickers/mimi2.gif'),
      Sticker('mimi3', 'assets/stickers/mimi3.gif'),
      Sticker('mimi4', 'assets/stickers/mimi4.gif'),
      Sticker('mimi5', 'assets/stickers/mimi5.gif'),
      Sticker('mimi6', 'assets/stickers/mimi6.gif'),
      Sticker('mimi7', 'assets/stickers/mimi7.gif'),
      Sticker('mimi8', 'assets/stickers/mimi8.gif'),
      Sticker('mimi9', 'assets/stickers/mimi9.gif'),
    ];
    return Future.value(stickers);
  }

  @override
  void endConversation(String userID) {
    FirebaseFirestore.instance
        .collection(userDocument)
        .doc(userID)
        .update({'chattingWith': null});
  }

}

