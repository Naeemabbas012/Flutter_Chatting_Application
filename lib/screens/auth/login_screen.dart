import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/screens/home_screen.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 2000), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    // for showing progress bar
    Dialogs.showProgressbar(context);

    _signInWithGoogle().then((user) async {
      // for hiding progress bar
      Navigator.pop(context);

      if(user != null){
        log('\nUser : ${user.user}');
        log('\nUserAdditionalInfo : ${user.additionalUserInfo}');

        if((await APIs.userExists())){
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));

        }else{
         await APIs.createUser().then((value) {
           Navigator.pushReplacement(
               context, MaterialPageRoute(builder: (_) => const HomeScreen()));
         });
        }
      }
    });
  }
   Future<UserCredential?> _signInWithGoogle() async {
   try{
     await InternetAddress.lookup('google.com');
     // Trigger the authentication flow
     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

     // Obtain the auth details from the request
     final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

     // Create a new credential
     final credential = GoogleAuthProvider.credential(
       accessToken: googleAuth?.accessToken,
       idToken: googleAuth?.idToken,
     );

     // Once signed in, return the UserCredential
     return await APIs.auth.signInWithCredential(credential);
   }catch(e){
     log('\n_signInWithGoogle: $e');
     Dialogs.showSnackbar(context, 'Something Went Wrong (Check Internet!)');
     return null;
   }
  }

  // sign out function
  // _signOut() async{
  // await FirebaseAuth.instance.signOut();
  // await GoogleSignIn.signOut();
  // }
  @override
  Widget build(BuildContext context) {
   // mq =MediaQuery.of(context).size;
    return Scaffold(
      // app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Welcome to We Chat'),
      ),
      // body
      body: Stack(children: [
        // app logo
        AnimatedPositioned(
          top: mq.height * .15,
            right: _isAnimate ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            duration: Duration(seconds: 1),
            child: Image.asset('images/icon.png')),

        // google login button
        Positioned(
            bottom: mq.height * .15,
            left: mq.width * .08,
            width: mq.width * .8,
            height: mq.height * .05,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen, elevation: 1),
                onPressed: (){
                _handleGoogleBtnClick();
                },

                // google icon
                icon: Image.asset('images/google.png', height: mq.height * .03),
                label: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                        children: [
                  TextSpan(text: 'Login with '),
                  TextSpan(text: 'Google', style: TextStyle(fontWeight: FontWeight.w500)),
                ])))),
      ]),

    );
  }
}
