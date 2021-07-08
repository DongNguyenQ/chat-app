import 'package:chat_app/enum/chat_message_type_enum.dart';
import 'package:chat_app/model/sticker.dart';
import 'package:chat_app/repository/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ConversationDetailViewModel extends ChangeNotifier {
  final ChatRepository _repository;

  ConversationDetailViewModel(this._repository);

  List<QueryDocumentSnapshot> _allLoadedMessages = new List.from([]);
  Stream<QuerySnapshot>? _messagesStream;
  bool _isBusy = false;
  String? _error;
  final int _defaultLimit = 20;
  final String _defaultOrder = 'timestamp';
  final bool _isDescending = true;

  // General
  String? _roomID;
  String? _receiverID;
  String? _receiverAvatar;
  String? _userID;

  // Image
  // String? _uploadedFileUrl;
  bool _isUploadingFile = false;
  String? _uploadFileError;

  // Stickers
  List<Sticker>? _stickers;

  // GETTER
  List<QueryDocumentSnapshot> get allLoadedMessages => this._allLoadedMessages;
  bool get busy => this._isBusy;
  String? get error => this._error;
  bool get uploadingFile => this._isUploadingFile;
  String? get uploadedFileError=> this._uploadFileError;
  List<Sticker>? get stickers => this._stickers;
  String? get roomID => this._roomID;
  Stream<QuerySnapshot>? get messagesStream => this._messagesStream;
  String? get userID => this._userID;
  String? get receiverAvatar => this._receiverAvatar;

  void setChatRoomInfo({
      String? receiverAvatar, required String receiverID, required String userID}) {
    print('SET CHAT ROOM INFO');
    _setBusy(true);
    final roomID = userID.hashCode <= receiverID.hashCode
        ? '$userID-$receiverID'
        : '$receiverID-$userID';

    this._roomID = roomID;
    this._receiverID = receiverID;
    this._receiverAvatar = receiverAvatar;
    this._userID = userID;
    startNewConversation();
    loadStickers();
    loadMessageHistory();
    _setBusy(false);
  }

  Future<String?> sendMessage({
    required int type, required String content
  }) async {
    this._error = null;
    _setBusy(true);
    final result = await _repository.sendMessage(
        idFrom: this._userID!,
        idTo: this._receiverID!,
        type: type,
        content: content,
        groupChatID: this._roomID!);

    if (result != null) {
      this._error = result;
    }
    _setBusy(false);
  }

  void loadStickers() async {
    print('LOAD STICKERS');
    List<Sticker> stickers = await _repository.getRemoteStickers();
    print('LOAD STICKERS : ${stickers.length}');
    this._stickers = stickers;
  }

  void startNewConversation() {
    if (this._userID != null && this._receiverID != null) {
      _repository.startNewConversation(this._userID!, this._receiverID!);
    }
  }

  void loadMessageHistory() {
    Stream<QuerySnapshot> data = _repository.getRemoteMessagesHistory(
      limit: this._defaultLimit,
      isDescending: this._isDescending,
      order: this._defaultOrder,
      roomID: this._roomID
    );
    this._messagesStream = data;
    // this._allLoadedMessages.addAll(data.map((event) => null));
    notifyListeners();
  }

  void sendImage(File file) async {
    _setUploadingFile(true);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    if (file.existsSync()) {
      print('FILE EXISTED');
      final result = await _repository.uploadImage(file, fileName);
      result.fold(
          (failure) {
            print('VIEW MODEL FAILURE : ${failure.error}');
            this._uploadFileError = failure.error;
          },
          (imageUrl) {
            // this._uploadedFileUrl = imageUrl;
            this.sendMessage(
                type: 1, content: imageUrl);
          });
    } else {
      this._uploadFileError = 'Please choose a file';
    }
    _setUploadingFile(false);
  }

  void saveNewFetchedMessage(List<QueryDocumentSnapshot> data) {
    this._allLoadedMessages.addAll(data);
    notifyListeners();
  }

  void _setUploadingFile(bool isUploading) {
    this._isUploadingFile = isUploading;
    notifyListeners();
  }

  void _setBusy(bool isBusy) {
    this._isBusy = isBusy;
    notifyListeners();
  }

  void endConversation() {
    _repository.endConversation(this._userID!);
    notifyListeners();
  }
}