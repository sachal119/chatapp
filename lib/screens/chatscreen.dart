// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:technolo_chat/api/apis.dart';
import 'package:technolo_chat/helper/my_date.dart';
import 'package:technolo_chat/main.dart';
import 'package:technolo_chat/models/chat_users.dart';
import 'package:technolo_chat/models/message.dart';
import 'package:technolo_chat/screens/view_profile_dart.dart';
import 'package:technolo_chat/widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final _texteditingcontrolller = TextEditingController();
  bool _showEmoji = false, _isUploading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: WillPopScope(
            onWillPop: () {
              if (_showEmoji) {
                setState(() {
                  _showEmoji = !_showEmoji;
                });
                return Future.value(false);
              } else {
                return Future.value(true);
              }
            },
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                flexibleSpace: _appBar(),
              ),
              backgroundColor: const Color.fromARGB(255, 234, 248, 255),
              body: Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    // width: MediaQuery.of(context).size.width,
                    child: StreamBuilder(
                      stream: APIs.GetAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(
                              child: SizedBox(),
                            );
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            // print('Data: ${jsonEncode(data![0].data())}');
                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                reverse: true,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                itemCount: _list.length,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                    message: _list[index],
                                  );
                                },
                              );
                            } else {
                              return const Center(
                                child: Text(
                                  'Say Hello! 👋',
                                  style: TextStyle(fontSize: 20),
                                ),
                              );
                            }
                        }
                      },
                    ),
                  ),
                  if (_isUploading)
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  Align(alignment: Alignment.bottomCenter, child: _chatInput()),
                  if (_showEmoji)
                    EmojiPicker(
                      textEditingController: _texteditingcontrolller,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 7,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ), // Needs to be const Widget
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      ViewProfileScreen(currentChatUser: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(CupertinoIcons.back)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online Now'
                                : MyDate.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDate.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                ],
              );
            }));
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * 0.01, vertical: mq.height * 0.025),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SizedBox(
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                      )),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextField(
                      controller: _texteditingcontrolller,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji) {
                          setState(() => _showEmoji = !_showEmoji);
                        }
                      },
                      decoration: const InputDecoration(
                          hintText: 'Type something...!',
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image.
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 80);
                        for (var i in images) {
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          setState(() => _isUploading = true);

                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blueAccent,
                      ))
                ],
              ),
            ),
          ),
          MaterialButton(
            shape: const CircleBorder(),
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
            color: Colors.green,
            onPressed: () {
              if (_texteditingcontrolller.text.isNotEmpty) {
                //on getting first message
                if (_list.isEmpty) {
                  APIs.sendFirstMessage(
                      widget.user, _texteditingcontrolller.text, Type.text);
                  _texteditingcontrolller.text = '';
                } else {
                  APIs.sendMessage(
                      widget.user, _texteditingcontrolller.text, Type.text);
                  _texteditingcontrolller.text = '';
                }
              }
            },
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
