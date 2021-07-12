import 'dart:io';
import 'package:chat_app/const/colors.dart';
import 'package:chat_app/enum/chat_message_type_enum.dart';
import 'package:chat_app/model/sticker.dart';
import 'package:chat_app/repository/chat_repository.dart';
import 'package:chat_app/service/chat_service.dart';
import 'package:chat_app/service/file_service.dart';
import 'package:chat_app/ui/widgets/common_ui.dart';
import 'package:chat_app/ui/widgets/message_widget.dart';
import 'package:chat_app/ui/widgets/photo_fullscreen.dart';
import 'package:chat_app/viewmodel/authentication_viewmodel.dart';
import 'package:chat_app/viewmodel/conversation_detail_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ConversationDetailScreenWrapper extends StatelessWidget {
  final String receiverID;
  final String receiverAvatar;

  const ConversationDetailScreenWrapper({
    Key? key, required this.receiverID, required this.receiverAvatar}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final chatService = ChatServiceImpl();
    final fileService = FileServiceImpl();
    final repository = ChatRepositoryImpl(chatService, fileService);
    final userID = Provider.of<AuthenticationViewModel>(context).user!.user!.uid;
    return ChangeNotifierProvider<ConversationDetailViewModel>(
      create: (context) => ConversationDetailViewModel(
          repository, receiverID, receiverAvatar, userID)
            ..setChatRoomInfo(receiverID: receiverID, userID: userID,
                receiverAvatar: receiverAvatar),
      child: ConversationDetailScreen(
        receiverAvatar: receiverAvatar, receiverID: receiverID, userID: userID),
    );
  }
}

class ConversationDetailScreen extends StatefulWidget {
  final String receiverID;
  final String receiverAvatar;
  final String userID;
  const ConversationDetailScreen({
    Key? key, required this.receiverID,
    required this.receiverAvatar, required this.userID}) : super(key: key);

  @override
  _ConversationDetailScreenState createState() => _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {

  final FocusNode focusNode = FocusNode();
  final TextEditingController chatController = TextEditingController();
  final ScrollController messagesScrollController = ScrollController();
  bool isShowStickerPanel = false;

  _scrollListener() {
    if (messagesScrollController.offset >= messagesScrollController.position.maxScrollExtent
      && !messagesScrollController.position.outOfRange) {
      setState(() {

      });
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    messagesScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    chatController.dispose();
    messagesScrollController.dispose();
    // getViewModel(isListen: false).endConversation();
    super.dispose();
  }

  @override
  void didChangeDependencies() {

    super.didChangeDependencies();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowStickerPanel = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          'CHAT',
          style: TextStyle(color: Color(0xff203152), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Spacer(),
              !getViewModel().busy && getViewModel().roomID != null
                  ? Expanded(child: _buildListMessage())
                  : _buildLoading(),
              isShowStickerPanel
                  ? StickersPanel(
                      onSendMessage: onSendMessage,
                      stickers: getViewModel().stickers!
                    )
                  : SizedBox(),
              _buildInput()
            ],
          ),
          Positioned(
            child: getViewModel().uploadingFile ? const Loading() : Container(),
          )
        ],
      )
    );
  }

  void showStickersPanel() {
    focusNode.unfocus();
    setState(() {
      isShowStickerPanel = !isShowStickerPanel;
    });
  }

  Widget _buildListMessage() {
    return getViewModel().roomID != null
        ? StreamBuilder<QuerySnapshot>(
            stream: getViewModel().messagesStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // getViewModel().saveNewFetchedMessage(snapshot.data!.docs);
                return ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemCount: snapshot.data?.docs.length,
                  reverse: true,
                  controller: messagesScrollController,
                  itemBuilder: (context, index) {
                    return Message(
                      index: index,
                      notUserAvatar: getViewModel().receiverAvatar,
                      message: snapshot.data!.docs[index],
                      messFromUser: snapshot.data!.docs[index].get('idFrom') == getViewModel().userID,
                    );
                  }
                );
              }
              // return _buildLoading();
              return Text('NO DATA');
            },
          )
        : _buildLoading();
  }

  Widget _buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: onSendImage,
                color: kcPrimaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                onPressed: showStickersPanel,
                color: kcPrimaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(chatController.text, 0);
                },
                style: TextStyle(color: kcPrimaryColor, fontSize: 15.0),
                controller: chatController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: kcGreyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(chatController.text, 0),
                color: kcPrimaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: kcGreyColor2, width: 0.5)), color: Colors.white),
    );
  }

  void onSendMessage(String content, int type) {
    if (content.trim() != '') {
      chatController.clear();
      getViewModel(isListen: false).sendMessage(type: type, content: content);
      // Scroll to the bottom to newest message
      messagesScrollController.animateTo(
          0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Please insert new message');
    }
  }

  Future onSendImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;
    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // getViewModel(isListen: false).sendImage(File(pickedFile.path));
      context.read<ConversationDetailViewModel>().sendImage(File(pickedFile.path));
    }
    if (getViewModel().uploadedFileError != null) {
      Fluttertoast.showToast(msg: getViewModel().uploadedFileError!);
    }
  }

  ConversationDetailViewModel getViewModel({bool? isListen}) {
    return Provider.of<ConversationDetailViewModel>(context, listen: isListen ?? true);
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(kcPrimaryColor),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    // This case handle when user press back to close stickers panel
    if (this.isShowStickerPanel) {
      setState(() {
        this.isShowStickerPanel = false;
      });
    } else {
      // If stickers panel is not showing, it mean that user want to go back to previous page
      getViewModel().endConversation();
      Navigator.pop(context);
    }
    return Future.value(false);
  }
}

class StickersPanel extends StatelessWidget {
  final Function onSendMessage;
  final List<Sticker> stickers;
  const StickersPanel({Key? key, required this.onSendMessage, required this.stickers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ...stickers.map((stick) {
          return TextButton(
            onPressed: () => onSendMessage(stick.url, 2),
            child: Image.asset(
              stick.url,
              width: 50.0,
              height: 50.0,
              fit: BoxFit.cover,
            ),
          );
        }).toList()
      ],
    );
  }
}

class HeaderInformation extends StatelessWidget {
  final String url;
  final String name;
  final String? lastActive;
  const HeaderInformation({
    Key? key, required this.url, 
    required this.name, this.lastActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Image.network('https://ged.com/wp-content/uploads/Online-GED-Test-Illustration-Mobile.svg'),
            Text(name)
          ],
        ),
        Text('Active now')
      ],
    );
  }
}
