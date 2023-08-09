import 'package:flutter/material.dart';
import 'package:cheery_messenger/allConstants/all_constants.dart';

Widget errorContainer() {
  return Container(
    clipBehavior: Clip.hardEdge,
    child: Image.asset(
      'assets/images/img_not_available.jpeg',
      height: Sizes.dimen_200,
      width: Sizes.dimen_200,
    ),
  );
}

//function returns chat icon
Widget chatImage({required String imageSrc, required Function onTap}) {
  return OutlinedButton(
    onPressed: onTap(),
    child: Image.network(
      imageSrc,
      width: Sizes.dimen_200,
      height: Sizes.dimen_200,
      fit: BoxFit.cover,
      loadingBuilder:
          (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.greyColor2,
            borderRadius: BorderRadius.circular(Sizes.dimen_10),
          ),
          width: Sizes.dimen_200,
          height: Sizes.dimen_200,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.burgundy,
              value: loadingProgress.expectedTotalBytes != null &&
                      loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, object, stackTrace) => errorContainer(),
    ),
  );
}

//function returns message widget. This will be modified to take a boolean to return different chat bubble for sender vs receiver
Widget messageBubbleRight(
    {required String chatContent,
    required EdgeInsetsGeometry? margin,
    Color? color,
    Color? textColor}) {
  return Container(
    padding: const EdgeInsets.all(Sizes.dimen_14),
    margin: margin,
    constraints: const BoxConstraints(maxWidth: 200,),
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(17), topRight:Radius.circular(17), bottomLeft: Radius.circular(17), bottomRight: Radius.circular(0), ),
    ),
    child: Text(
      chatContent,
      style: TextStyle(fontSize: Sizes.dimen_16, color: textColor),
    ),
  );
}

Widget messageBubbleLeft(
    {required String chatContent,
      required EdgeInsetsGeometry? margin,
      Color? color,
      Color? textColor}) {
  return Container(
    padding: const EdgeInsets.all(Sizes.dimen_14),
    margin: margin,
    constraints: const BoxConstraints(maxWidth: 200,),
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(17), topRight:Radius.circular(17), bottomLeft: Radius.circular(0), bottomRight: Radius.circular(17), ),
    ),
    child: Text(
      chatContent,
      style: TextStyle(fontSize: Sizes.dimen_16, color: textColor),
    ),
  );
}


// Container(              // Profile image
// clipBehavior: Clip.hardEdge,
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(Sizes.dimen_20),
// ),
// child: Image.network(
// widget.peerAvatar,
// width: Sizes.dimen_40,
// height: Sizes.dimen_40,
// fit: BoxFit.cover,
// loadingBuilder: (BuildContext ctx, Widget child,
// ImageChunkEvent? loadingProgress) {
// if (loadingProgress == null) return child;
// return Center(
// child: CircularProgressIndicator(
// color: AppColors.burgundy,
// value: loadingProgress.expectedTotalBytes !=
// null &&
// loadingProgress.expectedTotalBytes !=
// null
// ? loadingProgress.cumulativeBytesLoaded /
// loadingProgress.expectedTotalBytes!
//     : null,
// ),
// );
// },
// errorBuilder: (context, object, stackTrace) {
// return const Icon(
// Icons.account_circle,
// size: 35,
// color: AppColors.greyColor,
// );
// },
// ),
// )
//     : Container(
// width: 35,
// ),
//
// chatMessages.type == MessageType.text
// ? messageBubbleLeft(
// color: const Color(0xFF111010),
// textColor: AppColors.white,
// chatContent: chatMessages.content,
// margin: const EdgeInsets.only(left: Sizes.dimen_4),
// )
//     : chatMessages.type == MessageType.image
// ? Container(
// margin: const EdgeInsets.only(
// left: Sizes.dimen_10, top: Sizes.dimen_10),
// child: chatImage(
// imageSrc: chatMessages.content, onTap: () {}),
// )
//     : const SizedBox.shrink(),
// ],
// ),
// ),


Widget userAvatar(String userAvatar) {
  return Container( // Profile image
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Sizes.dimen_20),),
    child: Image.network(
      userAvatar,
      width: Sizes.dimen_40,
      height: Sizes.dimen_40,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext ctx, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: AppColors.burgundy,
            value: loadingProgress.expectedTotalBytes !=
                    null &&
                loadingProgress.expectedTotalBytes !=
                    null
                ? loadingProgress.cumulativeBytesLoaded /
                   loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },

      errorBuilder: (context, object, stackTrace) {
        return const Icon(
          Icons.account_circle,
          size: 35,
          color: AppColors.greyColor,
        );
      },
    ),
  );
}


// Flexible(
//
// child: TextField(
// focusNode: focusNode,
// textInputAction: TextInputAction.send,
// keyboardType: TextInputType.text,
// textCapitalization: TextCapitalization.sentences,
// controller: textEditingController,
// decoration:
// kTextInputDecoration.copyWith(hintText: 'write here...'),
// onSubmitted: (value) {
// onSendMessage(textEditingController.text, MessageType.text);
// },
// )),

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

            textInputAction: TextInputAction.send,
           // focusNode: focusNode,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            //controller: textEditingController,



            //controller: searchTextEditingController,
            // onChanged: (value) {
            //   if (value.isNotEmpty) {
            //     buttonClearController.add(true);
            //     setState(() {
            //       _textSearch = value;
            //     });
            //   } else {
            //     buttonClearController.add(false);
            //     setState(() {
            //       _textSearch = "";
            //     });
            //   }
            // },

            decoration: const InputDecoration.collapsed(
              hintText: 'Search connections',
              hintStyle: TextStyle(color: AppColors.white),
            ),
            // onFieldSubmitted: (value) {
            //  onSendMessage(textEditingController.text, MessageType.text);},
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
      ],
    ),
  );
}