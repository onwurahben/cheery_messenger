import 'dart:io';

import 'package:cheery_messenger/allWidgets/name_editor.dart';
import 'package:cheery_messenger/field_editing_ui.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:cheery_messenger/allConstants/all_constants.dart';
import 'package:cheery_messenger/allConstants/app_constants.dart';
import 'package:cheery_messenger/allWidgets/loading_view.dart';
import 'package:cheery_messenger/models/chat_user.dart';
import 'package:cheery_messenger/providers/profile_provider.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  TextEditingController? displayNameController;
  TextEditingController? aboutMeController;
  TextEditingController? locationController;
  final TextEditingController _phoneController = TextEditingController();

  final firebaseAuth = FirebaseAuth.instance;

  late String currentUserId;
  String dialCodeDigits = '+00';
  String id = '';
  String displayName = '';
  String photoUrl = '';
  String phoneNumber = '';
  String aboutMe = '';
  String location = '';

  bool isLoading = false;
  File? avatarImageFile;
  late ProfileProvider profileProvider;

  final FocusNode focusNodeNickname = FocusNode();

  @override
  void initState() {
    super.initState();
    profileProvider = context.read<ProfileProvider>();
    readLocal();
    // readFirebase();
  }

  void readFirebase(){


    setState(() {


      // auth values are not firestore values.

      id =  firebaseAuth.currentUser!.uid?? "";
      displayName = firebaseAuth.currentUser!.displayName! ?? "";

      print("$displayName");

      photoUrl =  firebaseAuth.currentUser!.photoURL?? "";
      phoneNumber = profileProvider.getPrefs(FirestoreConstants.phoneNumber) ?? "";
      aboutMe = profileProvider.getPrefs(FirestoreConstants.aboutMe) ?? "";

      print("$aboutMe");

      location = profileProvider.getPrefs('location') ?? "";

    });

    displayNameController = TextEditingController(text: displayName);
    aboutMeController = TextEditingController(text: aboutMe);
    locationController = TextEditingController(text: location);
  }

  void readLocal() {
    setState(() {
      id = profileProvider.getPrefs(FirestoreConstants.id) ?? "";
      displayName = profileProvider.getPrefs(FirestoreConstants.displayName) ?? "";

      photoUrl = profileProvider.getPrefs(FirestoreConstants.photoUrl) ?? "";
      phoneNumber =
          profileProvider.getPrefs(FirestoreConstants.phoneNumber) ?? "";
      aboutMe = profileProvider.getPrefs(FirestoreConstants.aboutMe) ?? "";

      location = profileProvider.getPrefs('location') ?? "";

    });
    displayNameController = TextEditingController(text: displayName);
    aboutMeController = TextEditingController(text: aboutMe);
    locationController = TextEditingController(text: location);


  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    // PickedFile is not supported
    // Now use XFile?
    XFile? pickedFile = await imagePicker
        .pickImage(source: ImageSource.gallery)
        .catchError((onError) {
      Fluttertoast.showToast(msg: onError.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = id;
    UploadTask uploadTask = profileProvider.uploadImageFile(
        avatarImageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();
      ChatUser updateInfo = ChatUser(id: id,
          photoUrl: photoUrl,
          displayName: displayName,
          phoneNumber: phoneNumber,
          aboutMe: aboutMe);
      profileProvider.updateFirestoreData(
          FirestoreConstants.pathUserCollection, id, updateInfo.toJson())

          .then((value) async {
        await profileProvider.setPrefs(FirestoreConstants.photoUrl, photoUrl);
        setState(() {
          isLoading = false;
        });
      });

    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void updateFirestoreData() {

    focusNodeNickname.unfocus();
    setState(() {
      isLoading = true;
      if (dialCodeDigits != "+00" && _phoneController.text != "") {
        phoneNumber = dialCodeDigits + _phoneController.text.toString();
      }
    });
    ChatUser updateInfo = ChatUser(id: id,
        photoUrl: photoUrl,
        displayName: displayName,
        phoneNumber: phoneNumber,
        aboutMe: aboutMe);

    // update firebase and prefs

    profileProvider.updateFirestoreData(
        FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
        .then((value) async {
      await profileProvider.setPrefs(
          FirestoreConstants.displayName, displayName);
      await profileProvider.setPrefs(
          FirestoreConstants.phoneNumber, phoneNumber);
      await profileProvider.setPrefs(
        FirestoreConstants.photoUrl, photoUrl,);
      await profileProvider.setPrefs(
          FirestoreConstants.aboutMe,aboutMe );
      await profileProvider.setPrefs(
          "location", location);

      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'UpdateSuccess');
    }).catchError((onError) {
      Fluttertoast.showToast(msg: onError.toString());
    });
  }


  @override
  Widget build(BuildContext context) {


    return
      Scaffold(
        backgroundColor: const Color(0xFF494D52),
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            AppConstants.profileTitle,
          ),
        ),


        body: Stack(
          children: [

            //  firebaseAuth.currentUser != null?

            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [


                  SizedBox(
                    height: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [

                        Positioned(
                          top: 80,
                          // bottom: 50,
                          child: Center(
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Color(0xFF323538),
                                  borderRadius: BorderRadius.all(Radius.circular(20))
                              ),

                              height: 130,
                              width: 312,

                            ),
                          ),
                        ),

                        Positioned(
                          top: 4,
                          child: GestureDetector(
                            onTap: getImage,
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(20),
                              child:

                              avatarImageFile == null ?

                              photoUrl.isNotEmpty ?

                              ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.network(photoUrl,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  errorBuilder: (context, object, stackTrace) {
                                    return const Icon(Icons.account_circle, size: 90,
                                      color: AppColors.greyColor,);
                                  },
                                  loadingBuilder: (BuildContext context, Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.grey,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes! : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ) : const Icon(Icons.account_circle,
                                size: 90,
                                color: AppColors.greyColor,)

                                  : ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.file(avatarImageFile!, width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,),),
                            ),),
                        ),
                      ], ),
                  ),


                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [

                        vertical15,

                        fieldEditing(
                            "name",
                            displayNameController,
                            displayName,
                            (value) {displayName = value;},
                            'Enter your name'),


                        vertical15,

                        fieldEditing(
                          "Bio",
                            aboutMeController,
                            aboutMe,
                            (value) {aboutMe = value;},
                            'Tell us about yourself'),

                        vertical15,

                        fieldEditing(
                            "Location",
                            locationController,
                            location,
                                (value) {location = value;},
                            'Enter your location'),

                        vertical15,
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Select Country Code', style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: AppColors.spaceCadet,
                          ),),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 100,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CountryCodePicker(
                              onChanged: (country) {
                                setState(() {
                                  dialCodeDigits = country.dialCode!;
                                });
                              },
                              initialSelection: 'IN',
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              favorite: const ["+1", "US", "+91", "IN"],
                            ),
                          ),
                        ),

                        vertical15,
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Phone Number', style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: AppColors.spaceCadet,
                          ),),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            decoration: kTextInputDecoration.copyWith(
                              hintText: 'Phone Number',
                              prefix: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(dialCodeDigits,
                                  style: const TextStyle(color: Colors.grey),),
                              ),
                            ),
                            controller: _phoneController,
                            maxLength: 12,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(onPressed: updateFirestoreData, child:const Padding(
                    padding:  EdgeInsets.all(8.0),
                    child:  Text('Update Info'),
                  )),

                ],
              ),
            ),
            // : const LoadingView(),


            Positioned(child: isLoading ? const LoadingView() : const SizedBox.shrink()),
          ],
        ),

      );

  }
}
