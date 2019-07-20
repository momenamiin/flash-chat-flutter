import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
FirebaseUser loggedUser;
final _firestore = Firestore.instance ;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText ;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
        getCurrentUser();
  }

  void getCurrentUser() async{
    try{
    final user = await _auth.currentUser();
    if (user != null){
      loggedUser = user ;
      print(loggedUser.email);
    }}catch(e){
      print(e);
    }
  }



  void messagesStream ()async{
    await for( var snapshot in _firestore.collection('messages').snapshots()){
      for(var message in snapshot.documents) {

      }
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              // ignore: missing_return
              builder: (context, snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                  final messages = snapshot.data.documents.reversed;
                  List<MessageBubble > messageWedgit = [];
                  for(var message in messages){
                    final messageText = message.data['text'];
                    final messageSender = message.data['Sender'];
                    final currentUser = loggedUser.email;

                    final messagesWideget = MessageBubble(messageSender: messageSender, messageText: messageText , isMe: currentUser == messageSender,);
                    messageWedgit.add(messagesWideget);
                  }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                      children: messageWedgit,
                    ),
                  );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value ;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text' : messageText,
                        'sender' : loggedUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {

  MessageBubble({this.messageText, this.messageSender, this.isMe});
  final bool isMe ;
  final messageSender ;
  final messageText ;
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text (messageSender != null ? messageSender : 'hidden '),
          Material(
              borderRadius: isMe ? BorderRadius.only(topLeft: Radius.circular(30.0), bottomLeft:Radius.circular(30.0),bottomRight: Radius.circular(30.0)):BorderRadius.only(topRight: Radius.circular(30.0), bottomLeft:Radius.circular(30.0),bottomRight: Radius.circular(30.0)) ,
              elevation: 5.0,
              color: isMe ? Colors.lightBlueAccent :Colors.white ,
              child: Padding(
                padding:  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text('$messageText ',style: TextStyle(fontSize: 15.0, color: isMe ? Colors.white : Colors.black54),),
              ),),
        ],
      ),
    );
  }
}
