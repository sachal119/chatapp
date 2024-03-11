import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:technolo_chat/api/apis.dart';
import 'package:technolo_chat/helper/my_date.dart';
import 'package:technolo_chat/main.dart';
import 'package:technolo_chat/models/chat_users.dart';
import 'package:technolo_chat/models/message.dart';
import 'package:technolo_chat/screens/chatscreen.dart';
import 'package:technolo_chat/widgets/dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0.5,
      child: InkWell(
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: ((context, snapshot) {
                final data = snapshot.data?.docs;

                final list = data
                        ?.map((e) =>
                            Message.fromJson(e.data() as Map<String, dynamic>))
                        .toList() ??
                    [];
                if (list.isNotEmpty) {
                  _message = list[0];
                  // _message = Message.fromJson(
                  //     data.first.data() as Map<String, dynamic>);
                }
                return ListTile(
                    onTap: () {
                      Navigator.push(
                          (context),
                          MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                    user: widget.user,
                                  )));
                    },
                    leading: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ProfileDialog(
                                  user: widget.user,
                                ));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .03),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          imageUrl: widget.user.image,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            child: Icon(CupertinoIcons.person),
                          ),
                        ),
                      ),
                    ),
                    title: Text(widget.user.name),
                    subtitle: Text(
                      _message != null
                          ? _message!.type == Type.image
                              ? '📷 Image'
                              : _message!.msg
                          : widget.user.about,
                      maxLines: 1,
                    ),
                    trailing: _message == null
                        ? null
                        : _message!.read.isEmpty &&
                                _message!.fromID != APIs.userNew.uid
                            ? Column(
                                children: [
                                  Text(
                                    MyDate.getLastMessageTIme(
                                        context: context, time: _message!.sent),
                                    style: TextStyle(
                                        color: Colors.greenAccent.shade400),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.greenAccent.shade400,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Center(
                                      child: Text(
                                        'N',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                MyDate.getLastMessageTIme(
                                    context: context, time: _message!.sent),
                                style: const TextStyle(color: Colors.black54),
                              )
                    // trailing: const Text(
                    //   '12:00 PM',
                    //   style: TextStyle(color: Colors.black54),
                    // ),
                    );
              }))),
    );
  }
}
