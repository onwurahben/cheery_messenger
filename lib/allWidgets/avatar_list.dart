

import 'package:cheery_messenger/models/chat_user.dart';
import 'package:cheery_messenger/providers/auth_provider.dart';
import 'package:cheery_messenger/screens/chat_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../allConstants/color_constants.dart';
import '../screens/profile_page.dart';

Widget avatarList(AuthProvider authProvider, List<ChatUser> user, String currentUser) {
  return Container(
    width: double.infinity,
    height: 100,
    color: Colors.transparent,
    padding: const EdgeInsets.all(8),
    child: Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
            child: Text('Online', style: TextStyle(  color: Color(0xFF7958D1),),)
        ),
        const SizedBox(height: 1,),
        const Divider(),
        Container(
          color: Colors.transparent,
          height: 50, // Adjust the height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: user.length, // Specify the number of items
            itemBuilder: (BuildContext context, int index) {

              ChatUser singleUser = user[index];
              String userId = singleUser.id;

              String nickname = singleUser.displayName;
              String avatar = singleUser.photoUrl;

              return
              userId != currentUser?

               GestureDetector(

                onTap:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(peerId: userId, peerNickname: nickname, peerAvatar: avatar, userAvatar: '',),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: circularAvatar(context, singleUser),
                ),
              ): const SizedBox.shrink();
            },
          ),
        ),
      ],
    ),
  );
}


Widget circularAvatar(BuildContext context, ChatUser? user) {
  String? photoUrl = user?.photoUrl;

  return photoUrl != null && photoUrl.isNotEmpty
      ? ClipRRect(
    borderRadius: BorderRadius.circular(60),
    child: Image.network(
      photoUrl,
      fit: BoxFit.cover,
      width: 50,
      height: 50,
      errorBuilder: (context, error, stackTrace) =>
      const Icon(
        Icons.account_circle,
        size: 50,
        color: AppColors.greyColor,
      ),
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return SizedBox(
          width: 50,
          height: 50,
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.grey,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    ),
  )
      : const Icon(
    Icons.account_circle,
    size: 50,
    color: AppColors.greyColor,
  );
}
