import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _firestore=FirebaseFirestore.instance;
User logedInUser;

class ChatScreen extends StatefulWidget {
  static const String id="chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController=TextEditingController();
  String email;
  String name;
  final _auth=FirebaseAuth.instance;
  
  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getName();

  }

  void getCurrentUser() {
    try {
      final user=  _auth.currentUser;
       if(user!=null){
      logedInUser=user;

      print(logedInUser.email);
    }
      
    } catch (e) {
      print(e);

    }
    

  }

     getName()async{
     SharedPreferences prefs=await SharedPreferences.getInstance();
     setState(() {
       email=(prefs.getString("user")??null);
     });

   }

  // void getMessages() async{
  //   final messages= await _firestore.collection("messages").get();
  //   for(var message in messages.docs){
  //     print(message.data());
  //   }
  // }

void messagesStream() async{
  await for(var snapshot in _firestore.collection("messages").snapshots()){
    for(var message in snapshot.docs){
      print(message.data());
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
                Navigator.pushNamed(context, "login");
                
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
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(

                    onPressed: () {

                      _firestore.collection("messages").add({
                        'text':messageText,
                         'sender': logedInUser.email,
                         'messageTime':DateTime.now(),
                      });
                      messageTextController.clear();
                      
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

class MessagesStream extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("messages").orderBy("messageTime",descending: true).snapshots(),
              builder:(context,snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.yellowAccent,
                    ),
                    
                  );
                }
                  final messages=snapshot.data.docs;
                  List<MessageDis> messageWidgets=[];
                  for(var message in messages){
                    final messageText=message.get('text').toString();
                    final messageSender=message.get('sender').toString();

                    final currentUser=logedInUser.email;

                    final messageWidget= MessageDis(message: messageText,sender: messageSender,isMe: currentUser==messageSender,);
                    messageWidgets.add(messageWidget);

                  }
                  return Expanded(
                    
                                      child: ListView(
                                        reverse: true,
                                        padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
                      children: messageWidgets,
                    ),
                  );

                

              } );
  }
}






class MessageDis extends StatelessWidget {
  MessageDis({this.message,this.sender,this.isMe});
 final String message;
  final String sender;
  final bool isMe;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text(sender,style: TextStyle(fontSize: 8.0,color: Colors.black54)),
          Material(
            borderRadius: isMe ?
            BorderRadius.only(
              topLeft: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(30.0)
              
            ):BorderRadius.only(
              topLeft: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(30.0)
            ),
            elevation: 8.0,
            color: isMe ?Colors.lightGreenAccent:Colors.blueAccent,

                child: Padding(
                  padding: EdgeInsets.symmetric(vertical:10.0,horizontal:20.0),
                  child: Text("$message",
                              style: TextStyle(
                                color:isMe ?Colors.white:Colors.black54,
                                fontSize: 20.0),),
                ),
          ),
        ],
      ),
    );
  }
}