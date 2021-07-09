import 'package:chat_app/core/failure.dart';
import 'package:chat_app/enum/chat_message_type_enum.dart';
import 'package:chat_app/model/sticker.dart';
import 'package:chat_app/service/chat_service.dart';
import 'package:chat_app/service/file_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:dartz/dartz.dart';

abstract class ChatRepository {
  Future<String?> sendMessage({
    required String idFrom,
    required String idTo,
    required int type,
    required String content,
    required String groupChatID
  });
  Stream<QuerySnapshot> getRemoteMessagesHistory({
    String? roomID, String? order, bool? isDescending, int? limit});
  Future<Either<Failure, String>> uploadImage(File file, String fileName);
  void startNewConversation(String userID, String receiverID);
  Future<List<Sticker>> getRemoteStickers();
  void endConversation(String userID);
}

class ChatRepositoryImpl extends ChatRepository {

  final ChatService _service;
  final FileService _fileService;

  ChatRepositoryImpl(this._service, this._fileService);

  @override
  Future<String?> sendMessage({
    required String idFrom, required String idTo, required int type,
    required String content, required String groupChatID}) {
    final result = _service.sendMessage(
        idFrom: idFrom, idTo: idTo, type: type,
        content: content, groupChatID: groupChatID);
    return result;
  }

  @override
  Stream<QuerySnapshot> getRemoteMessagesHistory({
      String? roomID, String? order, bool? isDescending, int? limit}) {
    return _service.getMessagesHistory(
        roomID: roomID!, order: order,
        isDescending: isDescending, limit: limit);
  }

  @override
  Future<Either<Failure, String>> uploadImage(File file, String fileName) {
    return _fileService.uploadFile(file, fileName);
  }

  @override
  void startNewConversation(String userID, String receiverID) {
    _service.startNewConversation(userID, receiverID);
  }

  @override
  Future<List<Sticker>> getRemoteStickers() {
    return _service.getStickers();
  }

  @override
  void endConversation(String userID) {
    _service.endConversation(userID);
  }

}