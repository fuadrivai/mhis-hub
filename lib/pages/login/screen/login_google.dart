import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/login/repository/login_api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInDemo extends StatefulWidget {
  const SignInDemo({super.key});

  @override
  SignInDemoState createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        context.go("/");
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // The user canceled the sign-in 932197578701
      } else {
        bool isExistUser = await LoginApi.checkUser(googleUser.email);
        if (isExistUser) {
          await googleUser.authentication.then((googleAuth) async {
            final AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            await _auth.signInWithCredential(credential);
            await Session.set("token", credential.accessToken ?? "");
            await Session.set("email", googleUser.email);
            await Session.set("fullName", googleUser.displayName ?? "");
          });
        }
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleSignIn,
          child: const Text('Sign In with Google'),
        ),
      ),
    );
  }
}
