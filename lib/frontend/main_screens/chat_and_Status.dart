import 'dart:io';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:page_transition/page_transition.dart';
import 'package:my_chat/backend/firebase/online_database_management/cloud_data_management.dart';
import 'package:my_chat/backend/sqlite_management/local_database_management.dart';
import 'package:my_chat/frontend/call_screens/pickup_screen.dart';
import 'package:my_chat/frontend/preview/image_preview.dart';
import 'package:my_chat/frontend/status_screens/story_view.dart';
import 'package:my_chat/models/call.dart';
import 'package:my_chat/models/story_model.dart';
import 'package:my_chat/services/chat_management/chat_screen.dart';
import 'package:my_chat/frontend/status_screens/status_maker.dart';
import 'package:my_chat/global_uses/constants.dart';
import 'package:my_chat/global_uses/enum_generation.dart';
import 'package:my_chat/models/latest_message_from_connection.dart';
import 'package:my_chat/services/search_screen.dart';
import 'package:status_view/status_view.dart';
import 'package:story_viewer/models/story_item.dart';

class ChatAndStatusScreen extends StatefulWidget {
  const ChatAndStatusScreen({Key? key}) : super(key: key);

  @override
  State<ChatAndStatusScreen> createState() => _ChatAndStatusScreenState();
}

class _ChatAndStatusScreenState extends State<ChatAndStatusScreen> {
  bool _isLoading = false; //loading overlay value
  List<StoryModel> _connectionsStatus = [];
  StoryModel? _currentUserStatus;
  String? _currentUserProfilePic;
  List<LatestMessageFromConnection> _latestMessages = [];

  TextEditingController _searchChatsController = TextEditingController();

  final CloudStoreDataManagement _cloudStoreDataManagement =
      CloudStoreDataManagement();

  final LocalDatabase _localDatabase = LocalDatabase();

  final FirestoreFieldConstants _firestoreFieldConstants =
      FirestoreFieldConstants();

  /// Fetch Real Time Data From current user's acct on Cloud Firestore
  Future<void> _fetchRTDataFromFirestore() async {
    final realTimeSnapshot =
        await _cloudStoreDataManagement.fetchRealTimeDataFromFirestore();

    //check for changes
    realTimeSnapshot!.listen((querySnapshot) {
      querySnapshot.docs.forEach((queryDocumentSnapshot) async {
        if (queryDocumentSnapshot.id ==
            FirebaseAuth.instance.currentUser!.email.toString()) {
          _checkingForMessagesAndStatus(
              queryDocumentSnapshot, querySnapshot.docs);
        }
      });
    });
  }

  /// check if there are new messages and status
  Future<void> _checkingForMessagesAndStatus(
      QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    try {
      final List<dynamic> _connectionRequestList =
          queryDocumentSnapshot.get(_firestoreFieldConstants.connectionRequest);

      //if connection request has been accepted
      _connectionRequestList.forEach((connectionRequestData) {
        if (connectionRequestData.values.first.toString() ==
                OtherConnectionStatus.invitation_accepted.toString() ||
            connectionRequestData.values.first.toString() ==
                OtherConnectionStatus.request_accepted.toString()) {
          docs.forEach((everyDocument) async {
            if (everyDocument.id ==
                connectionRequestData.keys.first.toString()) {
              final List<dynamic> _statusData =
                  everyDocument.get(_firestoreFieldConstants.status);

              final String _usernameData =
                  everyDocument.get(_firestoreFieldConstants.userName);

              final String _connectionPicData =
                  everyDocument.get(_firestoreFieldConstants.profilePic);

              final dynamic _callData =
                  everyDocument.get(_firestoreFieldConstants.call);

              //CHECK FOR NEW CALLS
              Call call = Call.fromMap(_callData);

              if (_callData.isNotEmpty) {
                if (call.receiverId ==
                    FirebaseAuth.instance.currentUser!.email.toString()) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PickupScreen(call: call)));
                }
              }

              //CHECK FOR NEW MESSAGES
              final String? _getConnectionMailFromLocal =
                  await _localDatabase.getParticularFieldDataFromImportantTable(
                      userName: _usernameData,
                      getField:
                          GetFieldForImportantDataLocalDatabase.userEmail);

              if (_getConnectionMailFromLocal != null) {
                final List<dynamic>? getMessages = queryDocumentSnapshot.get(
                    _firestoreFieldConstants
                        .connections)[_getConnectionMailFromLocal];

                if (getMessages != null && getMessages.isNotEmpty) {
                  if (getMessages[getMessages.length - 1]
                          .keys
                          .first
                          .toString() ==
                      ChatMessageType.text.toString()) {
                    Future.microtask(() {
                      _manageIncomingTextMessages(
                          username: _usernameData,
                          textMessage:
                              getMessages[getMessages.length - 1].values.first,
                          count: getMessages.length);
                    });
                  } else {
                    Future.microtask(() {
                      _manageIncomingTextMessages(
                          username: _usernameData,
                          textMessage: 'media file',
                          count: getMessages.length);
                    });
                  }
                }
              }
              //CHECK FOR NEW STATUS
              //check whether connection has uploaded a new status
              if (_statusData.isNotEmpty) {
                List<Story> stories = [];
                _statusData.forEach((element) {
                  stories.add(Story(storyData: element));
                });

                List<String> allFriendsWithStatus = [];
                _connectionsStatus.forEach((element) {
                  allFriendsWithStatus.add(element.userName);
                });

                if (!allFriendsWithStatus.contains(_usernameData)) {
                  if (mounted) {
                    setState(() {
                      _connectionsStatus.add(StoryModel(
                        imageUrl: _connectionPicData,
                        userName: _usernameData,
                        stories: stories,
                      ));
                    });
                  } else {
                    if (mounted) {
                      setState(() {
                        _connectionsStatus.insert(
                            allFriendsWithStatus.indexOf(_usernameData),
                            StoryModel(
                              imageUrl: _connectionPicData,
                              userName: _usernameData,
                              stories: stories,
                            ));
                      });
                    }
                  }

                }
              }
            }
          });
        }
      });

      //GET CURRENT USERS'S STATUS



    } catch (e) {
      print('error in getting last sent message and status from firestore ${e.toString()}');
    }
  }

  //store connection's incoming message locally
  void _manageIncomingTextMessages(
      {required var textMessage,
      required String username,
      required int count}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      if (mounted) {
        //if user is not already in the list
        List<String> usernames = [];
        _latestMessages.forEach((element) {
          usernames.add(element.username);
        });

        String? profilePic =
            await _localDatabase.getParticularFieldDataFromImportantTable(
                userName: username,
                getField:
                    GetFieldForImportantDataLocalDatabase.profileImagePath);

        if (!usernames.contains(username)) {
          setState(() {
            _latestMessages.add(LatestMessageFromConnection(
                username: username,
                lastestMessage: textMessage.keys.first.toString(),
                messageTime: textMessage.values.first.toString(),
                messageDate: DateTime.now().toString().split(" ")[0],
                messageHolder: MessageHolderType.connectedUsers.toString(),
                messageType: ChatMessageType.text.toString(),
                profilePic: profilePic!,
                count: count));
          });
        } else {
          int index = usernames.indexOf(username);
          setState(() {
            _latestMessages[index].lastestMessage =
                textMessage.keys.first.toString();
            _latestMessages[index].messageTime =
                textMessage.values.first.toString();
            _latestMessages[index].messageDate =
                DateTime.now().toString().split(" ")[0];
            _latestMessages[index].messageType = ChatMessageType.text;
            _latestMessages[index].count = count;
          });
        }
      }
    } catch (e) {
      //print('');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //load previous messages from local
  void _loadLatestMessageReceivedFromConnection() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      List<LatestMessageFromConnection> _latestMessageFromConnections =
          await _localDatabase.getLatestMessageFromConnections();

      for (int i = 0; i < _latestMessageFromConnections.length; i++) {
        final LatestMessageFromConnection latestMessageFromConnection =
            _latestMessageFromConnections[i];
        if (mounted) {
          setState(() {
            _latestMessages.add(LatestMessageFromConnection(
                username: latestMessageFromConnection.username,
                profilePic: latestMessageFromConnection.profilePic,
                lastestMessage: latestMessageFromConnection.messageType ==
                        ChatMessageType.text
                    ? latestMessageFromConnection.lastestMessage
                    : 'Media file',
                messageDate: latestMessageFromConnection.messageDate,
                messageTime: latestMessageFromConnection.messageTime,
                messageHolder: latestMessageFromConnection.messageHolder,
                messageType:
                    latestMessageFromConnection.messageType.toString()));
          });
        }
      }
    } catch (e) {
      print("error fetching latest messages from local : ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _getCurrentUserPicFromLocal() async {
    final String? currentUserName = await _localDatabase.getUserNameForAnyUser(
        FirebaseAuth.instance.currentUser!.email.toString());

    String? pic = await _localDatabase.getParticularFieldDataFromImportantTable(
        userName: currentUserName!,
        getField: GetFieldForImportantDataLocalDatabase.profileImagePath);
    if (mounted) {
      setState(() {
        _currentUserProfilePic = pic;
      });
    }
  }

  @override
  void initState() {
    _loadLatestMessageReceivedFromConnection(); //load previous messages from local
    _getCurrentUserPicFromLocal();
    _fetchRTDataFromFirestore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kWhite,
        body: LoadingOverlay(
            isLoading: _isLoading,
            child: ListView(shrinkWrap: true, children: [
              Container(
                  color: kWhite,
                  height: 100.0,
                  width: double.maxFinite,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5.0),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Chats',
                                  style: TextStyle(
                                    color: kBlack,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                  )),
                              const SizedBox(width: 177.0),

                            ]),
                        _searchChats(),
                      ])),
              _latestMessages.isEmpty
                  ? Column(children: [

                      const SizedBox(height: 70.0),
                      Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Add new friends',
                                  style: TextStyle(
                                      color: kGrey,
                                      fontSize: 18.0,
                                      letterSpacing: 1.0)),
                              IconButton(
                                  icon: const Icon(
                                    Icons.person_add_alt_1,
                                    size: 23.0,
                                    color: kPrimaryAppColor,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.fade,
                                            child: const SearchScreen()));
                                  })
                            ],
                          )),
                    ])
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _latestMessages.length,
                      itemBuilder: (context, position) {
                        return Column(children: [
                          //   display statuses first
                         // if (position == 0) _activityList(context),

                          _chatTile(
                            context,
                            position,
                          )
                        ]);
                      })
            ])));
  }

  //chat tile
  Widget _chatTile(BuildContext context, int index) {
    return ListTile(
        key: Key('$index'),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ChatScreen(
                        username: _latestMessages[index].username,
                        profilePic: _latestMessages[index].profilePic,
                      )));
        },
        leading: Badge(
            badgeColor: kGreen,
            position: BadgePosition.bottomEnd(bottom: -1, end: 5),
            child: GestureDetector(
                child: CircleAvatar(
                    radius: 25.0,
                    backgroundColor: Colors.transparent,
                    backgroundImage:
                        FileImage(File(_latestMessages[index].profilePic))),
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: ImageViewScreen(
                            imagePath: _latestMessages[index].profilePic,
                            imageProviderCategory:
                                ImageProviderCategory.fileImage,
                          )));
                })),
        title: Text(
            _latestMessages[index].username.length <= 18
                ? _latestMessages[index].username
                : _latestMessages[index].username.replaceRange(
                    18,
                    _latestMessages[index].username.length,
                    '...'), //ensure title length is no more than 18
            style: const TextStyle(
                fontSize: 18.0,
                color: kBlack,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.0)),
        subtitle: Text(
            _latestMessages[index].lastestMessage.length <= 30
                ? _latestMessages[index].lastestMessage
                : _latestMessages[index].lastestMessage.replaceRange(
                    30,
                    _latestMessages[index].lastestMessage.length,
                    '...'), //ensure subtitle length is no more than 30
            style: const TextStyle(
              color: kGrey,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              fontStyle: FontStyle.italic,
              fontSize: 13.0,
            )),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_latestMessages[index].messageTime,
                style: const TextStyle(color: kBlack, fontSize: 14.0)),
            const SizedBox(height: 2.0),
            _latestMessages[index].count != 0
                ? CircleAvatar(
                    radius: 9.0,
                    backgroundColor: kPrimaryAppColor,
                    child: Text(
                      '${_latestMessages[index].count}',
                      style: const TextStyle(
                          color: kWhite, fontSize: 8.0), //number of messages
                    ),
                  )
                : const Text('')
          ],
        ));
  }

  Widget _searchChats() {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30.0))),
      child: TextField(
          maxLines: 1,
          controller: _searchChatsController,
          style: const TextStyle(
              color: kBlack, letterSpacing: 1.0, fontSize: 16.0),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 20,right: 1,bottom: 1,top: 1),
            constraints: const BoxConstraints(maxHeight: 40.0, maxWidth: 260.0),
            suffixIcon: IconButton(
                icon: const Icon(Icons.search, size: 22.0, color: kGrey),
                onPressed: () {}),
            hintText: 'Search',
            fillColor: const Color.fromARGB(26, 63, 2, 142),
            filled: true,
            focusColor: null,
            hintStyle: const TextStyle(
                color: kGrey, fontSize: 18.0, letterSpacing: 1.0),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                borderSide: BorderSide(color: kTransparent)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                borderSide: BorderSide(color: kTransparent)),
          )),
    );
  }
}
