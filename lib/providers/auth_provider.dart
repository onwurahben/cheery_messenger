import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cheery_messenger/allConstants/all_constants.dart';
import 'package:cheery_messenger/models/chat_user.dart';

//this class authenticates users, checks to see if user is signed in, obtains the values from db or sets them if null
// saves data to sharedPreferences
//sets db value to the model

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled,
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn; //google sign in provider
  final FirebaseAuth firebaseAuth; //email and password
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider(
      {required this.googleSignIn,
      required this.firebaseAuth,
      required this.firebaseFirestore,
      required this.prefs});

  String? getFirebaseUserId() {
    return prefs.getString(FirestoreConstants.id);
  }

  // Future<bool> isLoggedIn() async {
  //   bool isLoggedIn = await googleSignIn.isSignedIn();
  //   if (isLoggedIn &&
  //       prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  //check if user is logged in and if data is stored in sharedPreferences

  Future<bool> isLoggedIn() async {
    final googleSignedIn = await googleSignIn.isSignedIn();
    final firebaseSignedIn = firebaseAuth.currentUser != null;

    if ((googleSignedIn || firebaseSignedIn) &&
        prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  //this method signs in the user using google
  Future<bool> handleGoogleSignIn() async {
    _status = Status.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      //sign in to firebase and get the user
      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      //if user data is empty in the db, set it in the db.
      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;
        if (document.isEmpty) {
          firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebaseUser.uid)
              .set({
            FirestoreConstants.displayName: firebaseUser.displayName,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            FirestoreConstants.id: firebaseUser.uid,
            "createdAt: ": DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: null
          });

          //store user data in shared preferences
          User? currentUser = firebaseUser;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(
              FirestoreConstants.displayName, currentUser.displayName ?? "");
          await prefs.setString(
              FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
          await prefs.setString(
              FirestoreConstants.phoneNumber, currentUser.phoneNumber ?? "");
        }

        // if user data is available in the db, set userChat model to the data and save in pref
        else {
          DocumentSnapshot documentSnapshot = document[0];
          ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
          await prefs.setString(FirestoreConstants.id, userChat.id);
          await prefs.setString(
              FirestoreConstants.displayName, userChat.displayName);
          await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
          await prefs.setString(
              FirestoreConstants.phoneNumber, userChat.phoneNumber);
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
  }

  Future<bool> handleSignIn(String? email, String? password,
      {bool isGoogleSignIn = false}) async {
    UserCredential? userCredential;

    try {
      _status = Status.authenticating;
      notifyListeners();

      if (isGoogleSignIn) {
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          _status = Status.authenticateCanceled;
          notifyListeners();
          return false;
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await firebaseAuth.signInWithCredential(credential);
      } else if (email != null && password != null) {
        userCredential = await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      final firebaseUser = userCredential?.user;

      if (firebaseUser != null) {
        final snapshot = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .doc(firebaseUser.uid)
            .get();

        if (!snapshot.exists) {
          await firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebaseUser.uid)
              .set({
            FirestoreConstants.displayName: firebaseUser.displayName,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            FirestoreConstants.id: firebaseUser.uid,
            "createdAt: ": DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: null,
          });

          final currentUser = firebaseUser;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(
              FirestoreConstants.displayName, currentUser.displayName ?? "");
          await prefs.setString(
              FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
          await prefs.setString(
              FirestoreConstants.phoneNumber, currentUser.phoneNumber ?? "");
        } else {
          final userChat = ChatUser.fromDocument(snapshot);
          await prefs.setString(FirestoreConstants.id, userChat.id);
          await prefs.setString(
              FirestoreConstants.displayName, userChat.displayName);
          await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
          await prefs.setString(
              FirestoreConstants.phoneNumber, userChat.phoneNumber);
        }

        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Handle user not found error
      } else if (e.code == 'wrong-password') {
        // Handle wrong password error
      } else {
        // Handle other exceptions
      }

      _status = Status.authenticateError;
      notifyListeners();
      return false;
    } catch (e) {
      // Handle other exceptions
      _status = Status.authenticateError;
      notifyListeners();
      return false;
    }
  }

  Future<void> googleSignOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }
}
