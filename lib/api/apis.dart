// ignore_for_file: non_constant_identifier_names, avoid_types_as_parameter_names, unnecessary_brace_in_string_interps, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:technolo_chat/models/chat_users.dart';
import 'package:technolo_chat/models/message.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage firestorage = FirebaseStorage.instance;
  static FirebaseMessaging Fmessaging = FirebaseMessaging.instance;
  static late ChatUser me;
  static User get userNew => auth.currentUser!;
  static Future<bool> userExists() async {
    return (await firestore.collection('user').doc(auth.currentUser!.uid).get())
        .exists;
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('user')
        .where('email', isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != userNew.uid) {
      firestore
          .collection('user')
          .doc(userNew.uid)
          .collection('my_Users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  static getSelfInfo() async {
    await firestore
        .collection('user')
        .doc(userNew.uid)
        .get()
        .then((User) async => {
              if (User.exists)
                {
                  me = ChatUser.fromJson(User.data()!),
                  await getFirebaseMessaging(),
                  APIs.updateOnlineStatus(true)
                }
              else
                {await createUser().then((value) => getSelfInfo())}
            });
  }

  static Future<void> getFirebaseMessaging() async {
    await Fmessaging.requestPermission();
    await Fmessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        print('Push Token: ${t}');
      }
    });
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  static Future<void> sendPushNotification(
      ChatUser chatuser, String msg) async {
    try {
      final body = {
        "to": chatuser.pushToken,
        "notification": {
          "title": me.name,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };
      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAA35n5Oek:APA91bHkERNYE6_BF_yWkp6crSmtEj7cgxd5_lTFdiPemBpN5pOfZgHWA4WTk6u7mDyilbbxf2asp5Cxsfr83WRdE6zG1xWHGcVLXJyXiyxX1IEaikrd65eLgBn9-BwVC2Fyk2dNgPdU'
              },
              body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('\nsendPushNotification Error: $e');
    }
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: userNew.photoURL.toString(),
        about: 'Hey! I am useing TechnoloChat',
        name: userNew.displayName.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        id: userNew.uid,
        pushToken: '',
        email: userNew.email.toString());
    return await firestore
        .collection('user')
        .doc(userNew.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> GetAllUser(
      List<String> userIDs) {
    return firestore
        .collection('user')
        .where('id', whereIn: userIDs)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> GetMyUsers() {
    return firestore
        .collection('user')
        .doc(userNew.uid)
        .collection('my_Users')
        .snapshots();
  }

//add user on getting first message
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    (await firestore
        .collection('user')
        .doc(chatUser.id)
        .collection('my_Users')
        .doc(userNew.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type)));
  }

  static Future<void> updateUserInfo() async {
    (await firestore
        .collection('user')
        .doc(auth.currentUser!.uid)
        .update({'name': me.name, 'about': me.about}));
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = firestorage.ref().child('profilepictures/${userNew.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'images/$ext'))
        .then((p0) {});
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('user')
        .doc(auth.currentUser!.uid)
        .update({'image': me.image});
  }

  //for getting
  static getConversationId(String id) => userNew.uid.hashCode <= id.hashCode
      ? '${userNew.uid}_${id}'
      : '${id}_${userNew.uid}';

  //ChatScreen related APIs
  static Stream<QuerySnapshot<Map<String, dynamic>>> GetAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        toID: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        sent: time,
        fromID: userNew.uid);
    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : '📷 Image'));
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.fromID)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot> getLastMessage(ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = firestorage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'images/$ext'))
        .then((p0) {});
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('user')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateOnlineStatus(bool isOnline) async {
    firestore.collection('user').doc(userNew.uid).update({
      'isOnline': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationId(message.toID)}/messages/')
        .doc(message.sent)
        .update({'msg': 'Message has been deleted.'});
    if (message.type == Type.image) {
      firestorage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessage(
      Message message, String updateMessage) async {
    await firestore
        .collection('chats/${getConversationId(message.toID)}/messages/')
        .doc(message.sent)
        .update({'msg': updateMessage});
  }
}
