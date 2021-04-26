import 'dart:io';

import 'package:chat/components/chat_message.dart';
import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currentUser != null ? _currentUser.displayName : 'Chat do Will'),
        elevation: 0,
        centerTitle: true,
        actions: [
          _currentUser != null ? IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              googleSignIn.signOut();

              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Você saiu com sucesso!', style: TextStyle(color: Colors.amber)),
                  )
              );
            }
          ) : Container()
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('messagesFindr').orderBy('time').snapshots(),
              builder: (context, snapshot) {
                switch(snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents = snapshot.data.docs.reversed.toList();
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ChatMessage(
                          documents[index].data(),
                          documents[index].data()['uid'] == _currentUser?.uid
                        );
                      }
                    );
                }
              },
            )
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage)
        ],
      ),
    );
  }

  void _sendMessage({String text, File imgFile}) async {

    final User user = await _getUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível fazer o login. Tente Novamente!'),
          backgroundColor: Colors.red,
        )
      );
    }

    firebase_core.Firebase.initializeApp();

    final formatData = DateFormat('dd/MM/yyyy hh:mm');

    Map<String, dynamic> data = {
      'uid': user.uid,
      'senderName': user.displayName,
      'senderPhotoUrl': user.photoURL,
      'time': Timestamp.now(),
      'dateTime': formatData.format(Timestamp.now().toDate())
    };
    
    if(imgFile != null) {

      firebase_storage.TaskSnapshot uploadTask;

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString());

      setState(() {
        _isLoading = true;
      });

      final metadata = firebase_storage.SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': imgFile.path});

          uploadTask = await ref.putFile(File(imgFile.path), metadata);
          data['imgUrl'] = await uploadTask.ref.getDownloadURL();
          print(data['imgUrl']);

          setState(() {
            _isLoading = false;
          });
    }

    if (text != null && text.isNotEmpty) {
      data['texto'] = text;
    }

    FirebaseFirestore.instance.collection('messagesFindr').add(data);
  }

  Future<User> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      final User user = userCredential.user;

      return user;
    } catch (error) {
      return null;
    }
  }
}
