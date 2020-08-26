import 'package:atg_chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  final _auth=FirebaseAuth.instance;
  final emailcontroller=TextEditingController() ;
  final passcontroller=TextEditingController();
  String email;
  String password;
  bool showSpinner=false;

   @override
 void initState(){
   super.initState();

 }
 void getDetails() async{
  SharedPreferences prefs=await SharedPreferences.getInstance();
  email=prefs.getString("user");
  password=prefs.getString("pass");

 }




  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
           inAsyncCall: showSpinner,
              child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 48.0,
              ),
              TextFormField(
                controller: emailcontroller,
                onChanged: (value) {
                  email=value;
                  
                },
                validator:(value){
                    if(value.isEmpty && value==email){
                      return "Enter your E-Mail";
                    }
                    return null;
                  },

                decoration: kTextFieldDecoration.copyWith(hintText:"Enter your Email"),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextFormField(
                controller: passcontroller,
                obscureText: true,
                onChanged: (value) {
                  password=value;
                  
                },
                validator: (val) => val.length < 6 ? 'Password too short.' : null,
                decoration: kTextFieldDecoration.copyWith(hintText:"Enter your Password",icon: const Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: const Icon(Icons.lock))),
              ),
              SizedBox(
                height: 24.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Material(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    onPressed: () async{
                      setState(() {
                        showSpinner=true;
                      });
                      try {
                        final user= await _auth.signInWithEmailAndPassword(email: email, password: password);
                        if(user!=null){
                          Navigator.pushNamed(context, ChatScreen.id);
                        }
                        
                       
                        setState(() {
                          showSpinner=false;
                        });
                      } catch (e) {
                        print(e);
                      }
                      
                      
                    },
                    minWidth: 200.0,
                    height: 42.0,
                    child: Text(
                      'Log In',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}