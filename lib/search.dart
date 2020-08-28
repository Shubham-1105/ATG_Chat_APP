import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

getUserByUserName(String username) async{
   return await FirebaseFirestore.instance.collection("users").where(
     'name',isEqualTo: username
   ).get();

}

Widget searchList(){
  return searchSnapshot !=null ? ListView.builder(
    shrinkWrap: true,
    itemCount: searchSnapshot.docs.length,
    itemBuilder: (context,index){
      return SearchTile(
        userName: searchSnapshot.docs[0].get("name").toString(),
        userEmail: searchSnapshot.docs[0].get("email").toString(),

      );

    }):Container(
      child: Center(
        child:Text("No matching user..")
      ),
    );
}

QuerySnapshot searchSnapshot;
initiateSearch(){
  getUserByUserName(textEditingController.text).then(
    (val){
      setState(() {
        searchSnapshot=val;
      });
    }
    
  );




}












TextEditingController textEditingController=new TextEditingController();


@override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        centerTitle: true,
        backgroundColor: Colors.purpleAccent,
        shadowColor: Colors.grey,
        shape: Border.all(color:Colors.black26),
        title:Text("Search Users",style:TextStyle(
          fontWeight:FontWeight.bold,
          fontSize:15.0,          
        )),
        
      ),
     body:Container(
       child:Column(
         children:<Widget>[
           Container(
             padding:EdgeInsets.symmetric(horizontal:20.0,vertical:10.0),
             child:Row(
               children: [
                 Expanded(child: TextField(
                   controller: textEditingController,
                   keyboardType:TextInputType.name,
                   decoration:InputDecoration(
                     hintText:"Search for Users....",
                     hintStyle:TextStyle(
                       color:Colors.black38
                     ),
                     border: InputBorder.none
                     
                   ),
                  
                 )),
                 GestureDetector(
                   onTap: (){
                     initiateSearch();
                     },     
                              
               
                   child: Icon(Icons.search,size: 40.0,)),
               ],
             )
           ),
          searchList(),
         
          
          
         ]
       )
     ),
    );
  }
}

class SearchTile extends StatelessWidget {
  final String userName;
  final String userEmail;
  SearchTile({this.userName,this.userEmail});
  final _auth=FirebaseAuth.instance;
  
    createChatRoom(String chatRoomID,chatRoomMap){
  FirebaseFirestore.instance.collection("chatRoom").doc(chatRoomID).set(chatRoomMap).catchError((e){
    print(e.toString());
  });
}

createChatRoomandStartConverse(BuildContext context,String userName){
  String curr=_auth.currentUser.email.toString();
  print(curr);
  List<String> users=[userName,curr];
  String chatRoomID="$userName _ $curr 2";

  Map<String,dynamic> chatRoomMap={
    "users":users,
     "chatRoomID":chatRoomID
  }; 
  
  createChatRoom(chatRoomID, chatRoomMap);
  Navigator.pushNamed(context, "chat_screen");
}


 

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children:<Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal:20.0,vertical:8.0),
                      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:<Widget>[
                Text(userName,style:TextStyle(
                  fontSize:30.0
                ),),
                Text(userEmail,style: TextStyle(
                  fontSize:15.0
                ),),
                
                

              ]
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: (){
              createChatRoomandStartConverse(context,userName);
                 
            },
                      child: Padding(
              padding: EdgeInsets.all(30.0),
                        child: Container(
                    decoration: BoxDecoration(
                      color:Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(10.0)
                    ),
                    padding:EdgeInsets.symmetric(horizontal:6.0,vertical:8.0),
                    child:Text('Message')
                  ),
            ),
          )


        ]
      ),
      
    );
  }
}