// ignore_for_file: avoid_print, deprecated_member_use
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:technolo_chat/api/apis.dart';
import 'package:technolo_chat/helper/dialogs.dart';
import 'package:technolo_chat/main.dart';
import 'package:technolo_chat/models/chat_users.dart';
import 'package:technolo_chat/screens/auth/login_screen.dart';
import 'package:technolo_chat/screens/profile_dart.dart';
import 'package:technolo_chat/widgets/chat_user_card.dart';
// import 'package:technolo_chat/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearch = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateOnlineStatus(true);
        }

        if (message.toString().contains('pause')) {
          APIs.updateOnlineStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearch) {
            setState(() {
              _isSearch = !_isSearch;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              bottom: const TabBar(
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                tabs: [
                  Tab(
                    child: Text(
                      'Chats',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Moments',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              title: _isSearch
                  ? TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Name,Enail...'),
                      autofocus: true,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          letterSpacing: 0.5),
                      onChanged: (val) {
                        _searchList.clear();
                        for (var i in _list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchList.add(i);
                            setState(() {
                              _searchList;
                            });
                          }
                        }
                      },
                    )
                  : const Text(
                      'Technolo Chat',
                    ),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearch = !_isSearch;
                      });
                    },
                    icon: Icon(
                      _isSearch
                          ? CupertinoIcons.clear_circled_solid
                          : Icons.search,
                      color: Colors.black,
                    )),
                PopupMenuButton(
                  offset: Offset(0.0, AppBar().preferredSize.height),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  )),
                  icon: const Icon(
                    Icons.more_vert_outlined,
                    color: Colors.black,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.person_2,
                              color: Colors.black,
                            ),
                            Text(
                              'Profile',
                              style: TextStyle(color: Colors.black),
                            )
                          ],
                        )),
                    const PopupMenuItem(
                        value: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.black,
                            ),
                            Text(
                              'Log Out',
                              style: TextStyle(color: Colors.black),
                            )
                          ],
                        )),
                  ],
                  onSelected: (int menu) async {
                    if (menu == 1) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileScreen(
                                    currentChatUser: APIs.me,
                                  )));
                    } else if (menu == 2) {
                      Dialogs.showProgressBar(context);
                      await APIs.updateOnlineStatus(false);
                      await APIs.auth.signOut().then((value) async {
                        await GoogleSignIn().signOut().then((value) {
                          Navigator.pop(context);
                          APIs.auth = FirebaseAuth.instance;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()));
                        });
                      });
                    }
                  },
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () async {
                  _addChatUserDialog();
                },
                child: const Icon(
                  Icons.add_box_rounded,
                ),
              ),
            ),
            body: TabBarView(
              children: [
                StreamBuilder(
                  stream: APIs.GetMyUsers(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.active:
                      case ConnectionState.done:
                        return StreamBuilder(
                            stream: APIs.GetAllUser(
                                snapshot.data?.docs.map((e) => e.id).toList() ??
                                    []),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                case ConnectionState.none:
                                // return const Center(
                                //   child: CircularProgressIndicator(),
                                // );
                                case ConnectionState.active:
                                case ConnectionState.done:
                                  final data = snapshot.data?.docs;
                                  _list = data
                                          ?.map((e) =>
                                              ChatUser.fromJson(e.data()))
                                          .toList() ??
                                      [];

                                  if (_list.isNotEmpty) {
                                    return ListView.builder(
                                      padding:
                                          EdgeInsets.only(top: mq.height * .01),
                                      itemCount: _isSearch
                                          ? _searchList.length
                                          : _list.length,
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return ChatUserCard(
                                          user: _isSearch
                                              ? _searchList[index]
                                              : _list[index],
                                        );
                                        // return Text('Name: ${list[index]}');
                                      },
                                    );
                                  } else {
                                    return const Center(
                                      child: Text(
                                        'No Connections Found !',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    );
                                  }
                              }
                            });
                    }
                  },
                ),
                //moments
                const Center(
                  child: Text('Moments Coming Soon'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';
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
                    Icons.person_2_rounded,
                    color: Colors.blue,
                    size: 26,
                  ),
                  Text('Add User')
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email ID',
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.blue,
                    ),
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
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackBar(context, 'User does not exists');
                        }
                      });
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                )
              ],
            ));
  }
}
