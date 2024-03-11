import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:technolo_chat/main.dart';
import 'package:technolo_chat/models/chat_users.dart';
import 'package:technolo_chat/screens/chatscreen.dart';
import 'package:technolo_chat/screens/view_profile_dart.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser user;
  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChatScreen(user: user)));
                },
                child: const Icon(
                  Icons.message,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ViewProfileScreen(currentChatUser: user)));
                },
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ],
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .30,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                // borderRadius: BorderRadius.circular(mq.height * .25),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: mq.width * .5,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                user.name,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
