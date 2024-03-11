// ignore_for_file: avoid_print, camel_case_types

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:technolo_chat/api/apis.dart';
import 'package:technolo_chat/helper/dialogs.dart';
import 'package:technolo_chat/helper/my_date.dart';
import 'package:technolo_chat/main.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:technolo_chat/models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.userNew.uid == widget.message.fromID;
    return InkWell(
        onLongPress: () {
          if (widget.message.msg != 'Message has been deleted.') {
            _showBottomSheetYet(isMe);
          }
        },
        child: isMe ? _greenMessage() : _blueMessage());
  }

//sender or other message
  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.03
                : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.03, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ? widget.message.msg == 'Message has been deleted.'
                    ? RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: widget.message.msg,
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                          const WidgetSpan(
                              child: Icon(
                            Icons.cancel_outlined,
                            color: Colors.grey,
                            size: 20,
                          )),
                        ]),
                      )
                    : Text(
                        widget.message.msg,
                        style: const TextStyle(fontSize: 15),
                      )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.01),
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: widget.message.msg,
                      placeholder: ((context, url) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
            MyDate.getFormatedTime(context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        )
      ],
    );
  }

//our message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * 0.03,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                size: 17,
                color: Colors.blue,
              ),
            const SizedBox(
              width: 2,
            ),
            Text(
              MyDate.getFormatedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.03
                : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.03, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.green),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == Type.text
                ? widget.message.msg == 'Message has been deleted.'
                    ? RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: widget.message.msg,
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                          const WidgetSpan(
                              child: Icon(
                            Icons.cancel_outlined,
                            color: Colors.grey,
                            size: 20,
                          )),
                        ]),
                      )
                    : Text(
                        widget.message.msg,
                        style: const TextStyle(fontSize: 15),
                      )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.01),
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: widget.message.msg,
                      placeholder: ((context, url) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )),
                      errorWidget: (context, url, error) =>
                          widget.message.msg != 'Message has been deleted.'
                              ? const Icon(
                                  Icons.image,
                                  size: 70,
                                )
                              : RichText(
                                  text: const TextSpan(children: [
                                    TextSpan(
                                      text: 'Image has been Deleted',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    WidgetSpan(
                                        child: Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.grey,
                                      size: 20,
                                    )),
                                  ]),
                                ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheetYet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * 0.015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20)),
              ),
              widget.message.type == Type.text
                  ? _optionItem(
                      icon: const Icon(
                        Icons.copy_all_rounded,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);
                          Dialogs.showSnackBar(context, 'Text copied!');
                        });
                      })
                  : _optionItem(
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'TechnoloChat')
                              .then((success) {
                            Navigator.pop(context);
                            if (success != null && success) {
                              Dialogs.showSnackBar(
                                  context, 'Image saved successfully.');
                            }
                          });
                        } catch (e) {
                          print('Error while saving image: $e');
                        }
                      }),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              if (widget.message.type == Type.text && isMe)
                if (widget.message.read == '')
                  _optionItem(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'Edit Message',
                      onTap: () {
                        Navigator.pop(context);
                        _showUpdateDialog();
                      }),
              if (isMe)
                if (widget.message.read == '')
                  _optionItem(
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'Delete Message for Everyone.',
                      onTap: () {
                        APIs.deleteMessage(widget.message).then((value) {
                          Navigator.pop(context);
                          Dialogs.showSnackBar(context, 'Message Deleted');
                        });
                      }),
              if (isMe)
                if (widget.message.read == '')
                  Divider(
                    color: Colors.black54,
                    endIndent: mq.width * .04,
                    indent: mq.width * .04,
                  ),
              if (!isMe)
                _optionItem(
                    icon: const Icon(
                      Icons.remove_red_eye_rounded,
                      color: Colors.red,
                      size: 26,
                    ),
                    name:
                        'Received At ${MyDate.getMessageTime(context: context, time: widget.message.sent)}',
                    onTap: () {}),
              _optionItem(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.green,
                    size: 26,
                  ),
                  name: widget.message.read.isEmpty
                      ? 'Read At: NOT SEEN YET'
                      : 'Read At: ${MyDate.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {})
            ],
          );
        });
  }

  void _showUpdateDialog() {
    String updateMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 26,
                  ),
                  Text('Update Message')
                ],
              ),
              content: TextFormField(
                initialValue: updateMsg,
                maxLines: null,
                onChanged: (value) => updateMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    APIs.updateMessage(widget.message, updateMsg).then(
                        (value) =>
                            Dialogs.showSnackBar(context, 'Message Update.'));
                  },
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                )
              ],
            ));
  }
}

class _optionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _optionItem(
      {required this.icon, required this.name, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * 0.015),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '       $name',
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ))
          ],
        ),
      ),
    );
  }
}
