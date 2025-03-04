
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/profile_screen.dart';

import '../helper/dialogs.dart';
import '../main.dart';
import '../widgets/chat_user_card.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   // for storing all user
   List<ChatUser> _list = [];

   // for storing searched items
  final List<ChatUser> _searchList = [];
  // for storing search status
   bool _isSearching = false;

   @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    // for updating user active status according to lifecycle events

    // resume ---- active or online

    // pause --- inactive or offline

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('message: $message');

      if(APIs.auth.currentUser != null){
        if(message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if(message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding a keyboard when a tap is detected on screen
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: WillPopScope(
        // if search is on & back button is pressed then close search
        // or else simple close current screen on back button click
        onWillPop: (){
          if(_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          // app bar
          appBar: AppBar(

            leading: Icon(CupertinoIcons.home),
            title: _isSearching ? TextField(
              decoration: InputDecoration(border: InputBorder.none, hintText: 'Name, Email,..'),
              autofocus: true,
              style: TextStyle(fontSize: 17, letterSpacing: 0.5),
              // when search text changes then updated search list
              onChanged: (val){
                // search logic
                _searchList.clear();

                for(var i in _list){
                  if(i.name.toUpperCase().contains(val.toLowerCase()) ||
                      i.email.toLowerCase().contains(val.toLowerCase())){
                    _searchList.add(i);
                  }
                  setState(() {
                    _searchList;
                  });
                }
              },
            ):  Text('We Chat'),
            actions: [
              // search user button
              IconButton(onPressed: (){
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
                  icon: Icon(_isSearching
                  ? CupertinoIcons.clear_circled_solid
                  : Icons.search)),

              // more features button
              IconButton(onPressed: (){
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ProfileScreen(user: APIs.me)));
              },
                  icon: Icon(Icons.more_vert))
            ],

          ),

          // floating button to add new user
          floatingActionButton: Padding(
            padding:  EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              onPressed: ()  {
                _addChatUserDialog();
                },
                child: const Icon(Icons.add_comment_rounded)),
          ),

          // body
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),

            // get id of only known users
            builder: (context, snapshot) {
              switch(snapshot.connectionState){
              // if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

              // if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:


                  return StreamBuilder(
                stream: APIs.getAllUsers
                  (snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                // get only those user, who's ids are provided
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                  // if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                     // return const Center(
                        //  child: CircularProgressIndicator());

                  // if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:

                      final data = snapshot.data?.docs;
                      _list = data
                          ?.map((e) => ChatUser.fromJson(e.data()))
                          .toList() ??
                          [];

                      if(_list.isNotEmpty){
                        return ListView.builder(
                            itemCount: _isSearching ? _searchList.length :  _list.length,
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ChatUserCard(user: _isSearching ? _searchList[index]: _list[index]);
                              // return Text('Name: ${list[index]} ');
                            });
                      }else{
                        return Center(
                            child: Text('No Connection Found!',
                                style: TextStyle(fontSize: 20)));
                      }

                  }

                },
              );
            }

          },
          ),
        ),
      ),
    );
  }
   // for adding new chat user
   void _addChatUserDialog(){
     String email = '';

     showDialog(
         context: context,
         builder: (_) => AlertDialog(
           contentPadding:
           EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
           // title
           title: Row(
             children: [
               Icon(Icons.person_add,
                 color: Colors.blue,
                 size: 28,),
               Text('  Add User')
             ],
           ),

           // content
           content: TextFormField(
             maxLines: null,
             onChanged: (value) => email= value,
             decoration: InputDecoration(
               hintText: 'Email Id',
                 prefixIcon: Icon(Icons.email, color: Colors.blue),
                 border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(15))),
           ),
           // action
           actions: [
             // cancel button
             MaterialButton(
                 onPressed: (){
                   // hide alert dialog
                   Navigator.pop(context);
                 },
                 child: Text(
                   'Cancel',
                   style: TextStyle(color: Colors.blue, fontSize: 16),
                 )),
             // add button
             MaterialButton(
                 onPressed: () async {
                   // hide alert dialog
                   Navigator.pop(context);
                   if(email.isNotEmpty) {
                     await APIs.addChatUser(email).then((value) {
                       if(!value){
                         Dialogs.showSnackbar(
                             context, 'User does not Exists!');
                       }
                     });
                   }
                 },
                 child: Text(
                   'Add',
                   style: TextStyle(color: Colors.blue, fontSize: 16),
                 ))
           ],
         ));
   }
}
