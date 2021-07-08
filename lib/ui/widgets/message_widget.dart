import 'package:chat_app/const/colors.dart';
import 'package:chat_app/enum/chat_message_type_enum.dart';
import 'package:chat_app/ui/widgets/photo_fullscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Message extends StatelessWidget {
  final DocumentSnapshot message;
  final int index;
  final bool messFromUser;
  final String? notUserAvatar;
  const Message({Key? key, required this.message, required this.index, required this.messFromUser, this.notUserAvatar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (messFromUser) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          message.get('type') == 0
            ? _buildText(message.get('content'))
            : message.get('type') == 2
              ? _buildSticker(message.get('content'))
              : _buildImage(message.get('content'), 'assets/stickers/img_not_available.jpeg', context)
        ],
      );
    }
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              isLastMessageLeft(index)
                  ? _buildAvatar(notUserAvatar!)
                  : Container(width: 35.0),
              message.get('type') == 0
                  ? _buildText(message.get('content'))
                  : message.get('type') == 1
                    ? _buildImage(message.get('content'), 'assets/stickers/img_not_available.jpeg', context)
                    : _buildSticker(message.get('content')),
              isLastMessageLeft(index)
                  ? _buildTime(message.get('timestamp'))
                  : SizedBox()
            ],
          ),
        ],
      )
    );
  }

  Widget _buildTime(String time) {
    return Container(
      child: Text(
        DateFormat('dd MMM kk:mm')
            .format(DateTime.fromMillisecondsSinceEpoch(int.parse(time))),
        style: TextStyle(color: kcGreyColor, fontSize: 12.0, fontStyle: FontStyle.italic),
      ),
      margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
    );
  }

  Widget _buildText(String text) {
    return Container(
      child: Text(text,
        style: TextStyle(color: kcPrimaryColor),
      ),
      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      width: 200.0,
      decoration: BoxDecoration(color: kcGreyColor2, borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
    );
  }

  Widget _buildSticker(String url) {
    return Container(
      child: Image.asset(
        url,
        width: 100.0,
        height: 100.0,
        fit: BoxFit.cover,
      ),
      margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
    );
  }

  Widget _buildImage(String url, String placeholder, BuildContext context) {
    return Container(
      child: OutlinedButton(
        child: Material(
          child: Image.network(
            url,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                decoration: BoxDecoration(
                  color: kcGreyColor2,
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
                width: 200.0,
                height: 200.0,
                child: Center(
                  child: CircularProgressIndicator(
                    color: kcPrimaryColor,
                    value: loadingProgress.expectedTotalBytes != null &&
                        loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, object, stackTrace) {
              return Material(
                child: Image.asset(
                  placeholder,
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                clipBehavior: Clip.hardEdge,
              );
            },
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          clipBehavior: Clip.hardEdge,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoFullScreen(
                url: url,
              ),
            ),
          );
        },
        style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
      ),
      margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
    );
  }

  bool isLastMessageRight(int index) {
    return true;
    // if ((index > 0 && listMessage[index - 1].get('idFrom') != id) || index == 0) {
    //   return true;
    // } else {
    //   return false;
    // }
  }

  bool isLastMessageLeft(int index) {
    // if ((index > 0 && listMessage[index - 1].get('idFrom') == id) || index == 0) {
    //   return true;
    // } else {
    //   return false;
    // }
    return false;
  }

  Widget _buildAvatar(String url) {
    return Image.network(
      url,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: kcPrimaryColor,
            value: loadingProgress.expectedTotalBytes != null &&
                loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, object, stackTrace) {
        return Icon(
          Icons.account_circle,
          size: 35,
          color: kcGreyColor,
        );
      },
      width: 35,
      height: 35,
      fit: BoxFit.cover,
    );
  }
}
