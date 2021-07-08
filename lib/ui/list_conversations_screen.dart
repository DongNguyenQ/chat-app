import 'package:chat_app/repository/user_repository.dart';
import 'package:chat_app/service/user_service.dart';
import 'package:chat_app/ui/conversation_detail_screen.dart';
import 'package:chat_app/viewmodel/authentication_viewmodel.dart';
import 'package:chat_app/viewmodel/conversation_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = UserServiceImpl();
    final repository = UserRepositoryImpl(service);
    final authenVM = Provider.of<AuthenticationViewModel>(context);
    return ChangeNotifierProvider(
      create: (context) => ConversationViewModel(repository)..getUsers(),
      child: Scaffold(
        body: Container(
          // child:
          // Consumer<ConversationViewModel>(
          //   builder: (context, model, child) {
          //     print('USER : ${model.users?.length}');
          //     print('USER NAME : ${model.users?.first.toString()}');
          //     if (model.busy) {
          //       return Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     }
          //     if (model.users == null || model.users?.length == 0) {
          //       return Center(child: Text('NO DATA'));
          //     }
          //     return ListView.builder(
          //       itemBuilder: (context, index) {
          //         return Text(model.users!.first.toString());
          //       },
          //     );
          //   },
          // )
          child: Consumer<ConversationViewModel>(
            builder: (context, model, child) {
              if (model.busy) {
                return Text('LOADING');
              }
              if (model.error != null) {
                return Text(model.error!);
              }
              return StreamBuilder(
                stream: model.users,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      if (authenVM.user != null
                          && authenVM.user!.user!.uid != snapshot.data!.docs[index].id) {
                        return builItem(context, snapshot.data!.docs[index]);
                      }
                      return SizedBox();
                    },
                  );
                },
              );
            },
          )
        )
      ),
    );
  }

  Widget builItem(BuildContext context, DocumentSnapshot? document) {
    return Container(
      child: TextButton(
        child: Row(
          children: <Widget>[
            Material(
              child: document!.get('photoUrl') != null
                  ? Image.network(
                      document.get('photoUrl'),
                      fit: BoxFit.cover,
                      width: 50.0,
                      height: 50.0,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xff203152),
                              value: loadingProgress.expectedTotalBytes != null &&
                                  loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, object, stackTrace) {
                        return Icon(
                          Icons.account_circle,
                          size: 50.0,
                          color: Color(0xffaeaeae),
                        );
                      },
                    )
                        : Icon(
                      Icons.account_circle,
                      size: 50.0,
                      color: Color(0xffaeaeae),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              'Nickname: ${document.get('nickname') ?? ''}',
                              maxLines: 1,
                              style: TextStyle(color: Color(0xff203152)),
                            ),
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                          ),
                          Container(
                            child: Text(
                              'About me: ${document.get('nickname') ?? ''}',
                              maxLines: 1,
                              style: TextStyle(color: Color(0xff203152)),
                            ),
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                          )
                        ],
                      ),
                      margin: EdgeInsets.only(left: 20.0),
                    ),
                  ),
          ],
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversationDetailScreenWrapper(
                receiverID: document.get('id'),
                receiverAvatar: document.get('photoUrl'),
              ),
            ),
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Color(0xffE8E8E8)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ),
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
    );
  }
}
