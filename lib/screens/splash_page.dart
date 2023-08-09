import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:cheery_messenger/allConstants/all_constants.dart';
import 'package:cheery_messenger/providers/auth_provider.dart';
import 'package:cheery_messenger/screens/home_page.dart';
import 'package:cheery_messenger/screens/login_page.dart';

import '../utilities/my_styles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      checkSignedIn();
    });
  }

  void checkSignedIn() async {
    AuthProvider authProvider = context.read<AuthProvider>();
    bool isLoggedIn = await authProvider.isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
      return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Cherry Messenger",
                style: kMessageTextStyle2,
            ),
            Image.asset(
              'assets/images/splash.png',
              width: 300,
              height: 300,
            ),
            const SizedBox(
              height: 20,
            ),
            // const Text(
            //   "Smartest Chat Application",
            //   style: TextStyle(
            //       fontWeight: FontWeight.bold, fontSize: Sizes.dimen_18),
            // ),
            const SizedBox(
              height: 20,
            ),
            const Center(
              child: SpinKitFadingCircle(
                color: Colors.deepOrange,
                size: 100.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
