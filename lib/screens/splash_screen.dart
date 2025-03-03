import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/screens/auth/login_screen.dart';
import 'package:we_chat/screens/home_screen.dart';
import '../main.dart';

 // splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {

      // exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(systemNavigationBarColor: Colors.white, statusBarColor: Colors.white));

      if(APIs.auth.currentUser != null){
        log('\nUser : ${APIs.auth.currentUser}');
        // navigate to home screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      }else{
        // navigate to login screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }


    });
  }
  @override
  Widget build(BuildContext context) {
    // initializing media query
    mq =MediaQuery.of(context).size;
    return Scaffold(
      // body
      body: Stack(children: [
        // app logo
        Positioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset('images/icon.png')),

        // google login button
        Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: Text('Developed by Naeem Abbas ❤️',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16,
                color: Colors.black87,
            ))),
      ]),
    );
  }
}
