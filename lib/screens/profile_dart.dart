// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:technolo_chat/api/apis.dart';
import 'package:technolo_chat/helper/dialogs.dart';
import 'package:technolo_chat/main.dart';
import 'package:technolo_chat/models/chat_users.dart';
import 'package:technolo_chat/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser currentChatUser;
  const ProfileScreen({super.key, required this.currentChatUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _finalFormKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  CupertinoIcons.back,
                  color: Colors.black,
                )),
            title: const Text('Profile Screen'),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: () async {
                Dialogs.showProgressBar(context);
                await APIs.updateOnlineStatus(false);
                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    APIs.auth = FirebaseAuth.instance;
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  });
                });
              },
              icon: const Icon(
                Icons.logout,
              ),
              label: const Text('Log Out'),
            ),
          ),
          body: Form(
            key: _finalFormKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: mq.width,
                      height: mq.height * .03,
                    ),
                    Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .3),
                                child: Image.file(
                                  File(_image!),
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ))
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .3),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  width: 200,
                                  height: 200,
                                  imageUrl: widget.currentChatUser.image,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                    child: Icon(CupertinoIcons.person),
                                  ),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              _showBottomSheet();
                            },
                            shape: const CircleBorder(),
                            color: Colors.white,
                            child: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      // width: mq.width,
                      height: mq.height * .03,
                    ),
                    Text(
                      widget.currentChatUser.email,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                    SizedBox(
                      // width: mq.width,
                      height: mq.height * .05,
                    ),
                    TextFormField(
                      initialValue: widget.currentChatUser.name,
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'e.g Technolo Chat',
                          label: const Text('Name')),
                    ),
                    SizedBox(
                      // width: mq.width,
                      height: mq.height * .05,
                    ),
                    TextFormField(
                      initialValue: widget.currentChatUser.about,
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon:
                              const Icon(CupertinoIcons.exclamationmark_circle),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'e.g Feeling Good',
                          label: const Text('About')),
                    ),
                    SizedBox(
                      // width: mq.width,
                      height: mq.height * .05,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          minimumSize: Size(mq.width * 0.5, mq.height * 0.06)),
                      onPressed: () {
                        if (_finalFormKey.currentState!.validate()) {
                          _finalFormKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            Dialogs.showSnackBar(
                                context, 'User Profile Updated Successfully');
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.edit,
                        size: 28,
                      ),
                      label: const Text(
                        'Update',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.05),
            children: [
              const Text(
                'Select Profile Picture',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
// Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 50);
                        if (image != null) {
                          print(image.path);
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset(
                        'images/add_image.png',
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
// Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 50);
                        if (image != null) {
                          print(image.path);
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
