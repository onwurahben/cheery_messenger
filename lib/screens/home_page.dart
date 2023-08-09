import 'dart:async';
import 'dart:io';
import 'package:cheery_messenger/providers/chat_provider.dart';
import 'package:cheery_messenger/utilities/my_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:cheery_messenger/allConstants/all_constants.dart';
import 'package:cheery_messenger/allWidgets/loading_view.dart';
import 'package:cheery_messenger/models/chat_user.dart';
import 'package:cheery_messenger/providers/auth_provider.dart';
import 'package:cheery_messenger/providers/home_provider.dart';
import 'package:cheery_messenger/screens/chat_page.dart';
import 'package:cheery_messenger/screens/login_page.dart';
import 'package:cheery_messenger/screens/profile_page.dart';
import 'package:cheery_messenger/utilities/debouncer.dart';
import 'package:cheery_messenger/utilities/keyboard_utils.dart';

import '../allWidgets/avatar_list.dart';
import '../models/chat_messages.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController scrollController = ScrollController();

  int _limit = 20;
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;
  String groupChatId = '';

  late AuthProvider authProvider;
  late String currentUserId;
  late HomeProvider homeProvider;
  late ChatProvider chatProvider;
  String? chatId;

  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> buttonClearController = StreamController<bool>();
  TextEditingController searchTextEditingController = TextEditingController();



  Future<void> googleSignOut() async {
    authProvider.googleSignOut();

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<void> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return SimpleDialog(
            backgroundColor: AppColors.burgundy,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Exit Application',
                  style: TextStyle(color: AppColors.white),
                ),
                Icon(
                  Icons.exit_to_app,
                  size: 30,
                  color: Colors.white,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.dimen_10),
            ),
            children: [
              vertical10,
              const Text(
                'Are you sure?',
                textAlign: TextAlign.center,
                style:
                TextStyle(color: AppColors.white, fontSize: Sizes.dimen_16),
              ),
              vertical15,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(Sizes.dimen_8),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: AppColors.spaceCadet),
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    buttonClearController.close();
  }

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();
    chatProvider = context.read<ChatProvider>();
    if (authProvider
        .getFirebaseUserId()
        ?.isNotEmpty == true) {
      currentUserId = authProvider.getFirebaseUserId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false);
    }


    scrollController.addListener(scrollListener);
  }

  // void readLocal() {
  //   if (authProvider.getFirebaseUserId()?.isNotEmpty == true) {
  //     currentUserId = authProvider.getFirebaseUserId()!;
  //   } else {
  //     Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (context) => const LoginPage()),
  //             (Route<dynamic> route) => false);
  //   }
  //   if (currentUserId.compareTo(widget.peerId) > 0) {
  //     groupChatId = '$currentUserId - ${widget.peerId}';
  //   } else {
  //     groupChatId = '${widget.peerId} - $currentUserId';
  //   }
  // }

  // String getGroupChatId(String currentUserId, String peerId) {
  //   if (currentUserId.compareTo(peerId) > 0) {
  //     return '$currentUserId - $peerId';
  //   } else {
  //     return '$peerId - $currentUserId';
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF262C28),
        appBar: AppBar(
            elevation: 0,
            toolbarHeight: 80,
            backgroundColor: const Color(0xFF262C28),
            centerTitle: true,
            title: const Text('Cherry', style: kMessageTextStyle),
            actions: [
              IconButton(
                  onPressed: () => googleSignOut(),
                  icon: const Icon(Icons.logout)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()));
                  },
                  icon: const Icon(Icons.person)),
            ]),

        body: WillPopScope(
          onWillPop: onBackPress,
          child: Stack(
            children: [

              Container(
                color: const Color(0xFF262C28),
                child: Column(
                  children: [
                    buildSearchBar(),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: homeProvider.getFirestoreData(
                            FirestoreConstants.pathUserCollection, _limit,
                            _textSearch),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> userSnapshot) {
                          if (userSnapshot.hasData) {
                            if ((userSnapshot.data?.docs.length ?? 0) > 0) {
                              List<ChatUser> users = userSnapshot.data!.docs
                                  .map((doc) => ChatUser.fromDocument(doc))
                                  .toList();

                              String? chatId = chatProvider.uniqueChatId;

                              if (chatId != null) {

                                return StreamBuilder<QuerySnapshot>(
                                  stream: chatProvider.getChatMessage(
                                      chatId, 1),
                                  builder: (BuildContext context, AsyncSnapshot<
                                      QuerySnapshot> chatSnapshot) {
                                    if (chatSnapshot.hasData) {
                                      List<
                                          ChatMessages> chatMessages = chatSnapshot
                                          .data!.docs.map((doc) =>
                                          ChatMessages.fromDocument(doc))
                                          .toList();
                                      
                                      print('hello');

                                      print("$chatMessages");

                                      return Column(
                                        children: [
                                          // Container(
                                          //   width: double.infinity,
                                          //   height: 100,
                                          //   color: Colors.white,
                                          // ),
                                         avatarList(authProvider, users, currentUserId),
                                          ListView.separated(
                                            shrinkWrap: true,
                                            itemCount: userSnapshot.data!.docs
                                                .length,
                                            itemBuilder: (context, index) =>
                                                buildItem(context, userChat: users[index],
                                                    chatMessages: chatMessages),
                                            controller: scrollController,
                                            separatorBuilder: (BuildContext context,
                                                int index) => const Divider(),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return const Center(


                                          child: Text('Error in loading a')

                                        //CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                );
                              }

                              else {
                                return Center(
                                  child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: userSnapshot.data!.docs
                                      .length,
                                  itemBuilder: (context, index) =>
                                      buildItem(context, userChat: users[index]),
                                  controller: scrollController,
                                  separatorBuilder: (BuildContext context,
                                      int index) => const Divider(),
                                 ),
                                );
                              }
                            } else {
                              return const Center(
                                child: Text('No user found...'),
                              );
                            }
                          } else {
                            return const Center(
                                child: Text('Error in loading c')
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                child:
                isLoading ? const LoadingView() : const SizedBox.shrink(),
              ),
            ],
          ),
        )

      //  bottomNavigationBar: ,
    );
  }

  Widget buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(Sizes.dimen_10),
      height: 56,
      width: 301,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.dimen_20),
        color: Colors.black26,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            width: 27,
          ),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchTextEditingController,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  buttonClearController.add(true);
                  setState(() {
                    _textSearch = value;
                  });
                } else {
                  buttonClearController.add(false);
                  setState(() {
                    _textSearch = "";
                  });
                }
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Search connections',
                hintStyle: TextStyle(color: AppColors.white),
              ),
            ),
          ),
          const Icon(
            Icons.search,
            color: Color(0xFF7958D1),
            size: Sizes.dimen_24,
          ),
          const SizedBox(
            width: Sizes.dimen_20,
          ),
          StreamBuilder(
              stream: buttonClearController.stream,
              builder: (context, snapshot) {
                return snapshot.data == true
                    ? GestureDetector(
                  onTap: () {
                    searchTextEditingController.clear();
                    buttonClearController.add(false);
                    setState(() {
                      _textSearch = '';
                    });
                  },
                  child: const Icon(
                    Icons.clear_rounded,
                    color: AppColors.greyColor,
                    size: 20,
                  ),
                )
                    : const SizedBox.shrink();
              })
        ],
      ),
    );
  }

  // Future<ChatMessages> getLastMessageForUser(ChatUser user) async {
  //   // Implement the logic to fetch the last message for the given user from Firestore
  //   // and return it as a ChatMessages object
  //   // For example:
  //   QuerySnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('chat_messages')
  //       .where('receiverId', isEqualTo: user.id)
  //       .orderBy('timestamp', descending: true)
  //       .limit(1)
  //       .get();
  //   if (snapshot.docs.isNotEmpty) {
  //     return ChatMessages.fromDocument(snapshot.docs.first);
  //   } else {
  //     return const SizedBox.shrink(); // Return an empty ChatMessages object if no message is found
  //   }
  // }

  Widget buildItem(BuildContext context,   {List<ChatMessages>? chatMessages,   ChatUser? userChat }) {
    final firebaseAuth = FirebaseAuth.instance;
    if (userChat != null) {
      if (userChat.id == currentUserId) {
        return const SizedBox.shrink();
      } else {
        // Sort the chat messages based on timestamp in descending order
        chatMessages?.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return TextButton(
          onPressed: () {
            if (KeyboardUtils.isKeyboardShowing()) {
              KeyboardUtils.closeKeyboard(context);
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatPage(
                      peerId: userChat.id,
                      peerAvatar: userChat.photoUrl,
                      peerNickname: userChat.displayName,
                      userAvatar: firebaseAuth.currentUser!.photoURL!,
                    ),
              ),
            );
          },
          child: Container(
            height: 90,
            width: 396,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1E1F),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(
                      0, 0), // changes the shadow direction (x,y)
                ),
              ],
              // You can adjust the radius as per your requirement
            ),
            child: Center(
              child: ListTile(
                textColor: Colors.white,
                leading: userChat.photoUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(Sizes.dimen_30),
                  child: Image.network(
                    userChat.photoUrl,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    loadingBuilder: (BuildContext ctx, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      }
                    },
                    errorBuilder: (context, object, stackTrace) {
                      return const Icon(Icons.account_circle, size: 50);
                    },
                  ),
                )
                    : const Icon(
                  Icons.account_circle,
                  size: 50,
                ),
                title: Text(
                  userChat.displayName,
                  // style: const TextStyle(color: Colors.black),
                ),
                subtitle: chatMessages?.isNotEmpty == true
                    ? Text(chatMessages!.first.content)
                    : const Text('No messages yet'),
              ),
            ),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}