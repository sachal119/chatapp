// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:technolo_chat/helper/my_date.dart';
import 'package:technolo_chat/main.dart';
import 'package:technolo_chat/models/chat_users.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser currentChatUser;
  const ViewProfileScreen({super.key, required this.currentChatUser});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  CupertinoIcons.back,
                  color: Colors.black,
                )),
            title: Text(widget.currentChatUser.name),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Joined On: ',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
              Text(
                MyDate.getLastMessageTIme(
                    context: context,
                    time: widget.currentChatUser.createdAt,
                    showYear: true),
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: 200,
                      height: 200,
                      imageUrl: widget.currentChatUser.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  SizedBox(
                    // width: mq.width,
                    height: mq.height * .03,
                  ),
                  Text(
                    widget.currentChatUser.email,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  SizedBox(
                    // width: mq.width,
                    height: mq.height * .02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'About: ',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      Text(
                        widget.currentChatUser.about,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
