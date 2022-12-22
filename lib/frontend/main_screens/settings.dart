import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_chat/backend/sqlite_management/local_database_management.dart';
import 'package:my_chat/frontend/main_screens/profile.dart';
import 'package:my_chat/global_uses/constants.dart';
import 'package:my_chat/global_uses/enum_generation.dart';

import '../auth_screens/login.dart';
import 'about_screen.dart';
import 'help.dart';

class SettingsWindow extends StatefulWidget {
  const SettingsWindow({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsWindow> createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool isLoading = false;

  final LocalDatabase _localDatabase = LocalDatabase();
  String username = '';
  String? profilePic;
  String userMail = '';

  //get current username, profile pic and usernamil from local
  void _getProfileDetailsFromLocal() async {
    final String? currentUserName = await _localDatabase.getUserNameForAnyUser(
        FirebaseAuth.instance.currentUser!.email.toString());

    String? pic = await _localDatabase.getParticularFieldDataFromImportantTable(
        userName: currentUserName!,
        getField: GetFieldForImportantDataLocalDatabase.profileImagePath);
    String? mail =
        await _localDatabase.getParticularFieldDataFromImportantTable(
            userName: currentUserName,
            getField: GetFieldForImportantDataLocalDatabase.userEmail);

    if (mounted) {
      setState(() {
        username = currentUserName;
        userMail = mail!;
        profilePic = pic;
      });
    }
  }

  @override
  void initState() {
    _getProfileDetailsFromLocal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: kWhite,
            body: Center(
              child: Column(children: [
                const SizedBox(height: 20.0),
                const Text('Settings',
                    style: TextStyle(
                      color: kBlack,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 40.0),
                profilePic == null
                    ? const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/person.png'),
                        radius: 60.0,
                        backgroundColor: kTransparent,
                      )
                    : CircleAvatar(
                        backgroundImage: FileImage(File(profilePic!)),
                        radius: 60.0,
                        backgroundColor: kTransparent,
                      ),
                const SizedBox(height: 10.0),
                Text(
                  username,
                  style: const TextStyle(
                      fontSize: 20.0,
                      color: kBlack,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.0),
                ),
                const SizedBox(height: 5.0),
                Text(
                  userMail,
                  style: const TextStyle(
                      fontSize: 16.0,
                      color: kGrey,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.0),
                ),
                const SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10.0, left: 100.0, right: 100.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100.0, 30.0),
                          primary: kPrimaryAppColor,
                          elevation: 0.0,
                          padding: const EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 8.0),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40.0)))),
                      child: const Text('EDIT PROFILE',
                          style: TextStyle(
                              color: kWhite,
                              letterSpacing: 1.0,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500)),
                      onPressed: () async {
                        final String currentProfilePic = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileScreen()));

                        if (mounted) {
                          setState(() {
                            profilePic = currentProfilePic;
                          });
                        }
                      }),
                ),
                const SizedBox(height: 10.0),
                Container(
                  color: const Color.fromARGB(66, 214, 177, 237),
                  width: double.maxFinite,
                  padding:
                      const EdgeInsets.only(top: 3.0, bottom: 3.0, left: 20.0),
                  height: 30.0,
                  child: const Text(
                    'PREFERENCES',
                    style: TextStyle(
                        fontSize: 16.0,
                        color: kGrey,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.0),
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
                  child: Column(
                    children: [
                       Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_)=> const AboutSection()));
                            },
                            child: ListTile(
                              tileColor: Theme.of(context).disabledColor.withOpacity(0.1),
                              leading: Icon(
                                Icons.info_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: const Text("About"),
                            ),
                          ),
                        ),
                      ),const SizedBox(height: 7,),
                      InkWell(
                        onTap:(){
                          Navigator.push(context, MaterialPageRoute(builder: (_)=>const HelpScreen()));
                        },
                        child:  ListTile(
                          tileColor: Theme.of(context).disabledColor.withOpacity(0.1),
                          leading: Icon(
                            Icons.help_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: const Text("Help"),
                        ),),
                      SizedBox(height: 8,),

                      InkWell(
                        onTap:(){showDialog(context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child:  Padding(padding: const EdgeInsets.all(10),
                                  child:  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 12,),
                                      const Text("Do you want to logout?",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),

                                      const SizedBox(height: 12,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },style: TextButton.styleFrom(
                                              backgroundColor: Theme.of(context).primaryColor
                                          ),
                                              child: const Text("No",
                                                style: TextStyle(color: Colors.white),)),
                                          const SizedBox(width: 10,),
                                          TextButton(onPressed: ()  {
                                              if(mounted){
                                                setState(() {
                                                  isLoading=true;
                                                });
                                              }
                                            logOut();

                                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>LoginPage()), (route) => false);

                                          },
                                              style: TextButton.styleFrom(
                                              backgroundColor: Theme.of(context).primaryColor
                                          ),child: const Text("Yes",style: TextStyle(color: Colors.white),))

                                        ],
                                      )

                                    ],
                                  ),
                                ),
                              );
                            });},
                        child: ListTile(
                          tileColor: Theme.of(context).disabledColor.withOpacity(0.1),
                          leading: Icon(
                            Icons.logout_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: const Text("Logout"),
                        ),)
                    ],
                  ),
                ),
              ]
              ),
            )
        )
    );
  }
  Future<bool> logOut() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();

     await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
}
