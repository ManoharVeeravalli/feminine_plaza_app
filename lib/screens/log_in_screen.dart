import 'package:feminine_plaza_app/screens/add_item_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LogInScreen extends StatelessWidget {
  static const route = '/login';
  const LogInScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Container(
        child: Center(
          child: LogInButton(),
        ),
      ),
    );
  }
}

class LogInButton extends StatefulWidget {
  const LogInButton();

  @override
  _LogInButtonState createState() => _LogInButtonState();
}

class _LogInButtonState extends State<LogInButton> {
  var _loading = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : OutlineButton(
            splashColor: Colors.grey,
            onPressed: () async {
              setState(() {
                _loading = true;
              });
              try {
                signInWithGoogle(context);
              } catch (e) {
                setState(() {
                  _loading = true;
                });
              }
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            highlightElevation: 0,
            borderSide: BorderSide(color: Colors.grey),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> signInWithGoogle(final BuildContext context) async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        Navigator.of(context).pushReplacementNamed(AddItemScreen.route);
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e);
      setState(() {
        _loading = true;
      });
    }
  }
}
