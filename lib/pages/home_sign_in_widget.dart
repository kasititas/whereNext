import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:wherenextapp/pages/home_page.dart';

class HomeSignInWidget extends StatefulWidget {
  final Function goToSignUp;
  final Function goToSignIn;

  HomeSignInWidget({this.goToSignUp, this.goToSignIn});

  @override
  _HomeSignInWidgetState createState() => _HomeSignInWidgetState();
}

class _HomeSignInWidgetState extends State<HomeSignInWidget> {
  bool isLoggedIn = false;

  var profileData;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  void _signInFacebook() async {
    FacebookLogin facebookLogin = new FacebookLogin();

    final facebookLoginResult =
        await facebookLogin.logIn(['email', 'public_profile']);
    final token = facebookLoginResult.accessToken.token;

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(400)&access_token=$token');

        var profile = json.decode(graphResponse.body);
        print(profile.toString());
        final credential =
            FacebookAuthProvider.getCredential(accessToken: token);
        _auth.signInWithCredential(credential);
        onLoginStatusChanged(true, profileData: profile);
        if (isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 30.0,
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              _signInFacebook();
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 18.0,
                horizontal: 20.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.facebookF,
                    color: Colors.blue,
                    size: 30.0,
                  ),
                  Text(
                    '| Sign in with Facebook',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          InkWell(
            onTap: () {
              widget.goToSignUp();
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 18.0,
                horizontal: 20.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          InkWell(
            onTap: () {
              widget.goToSignIn();
            },
            child: Text(
              'ALREADY REGISTERED? SIGN IN!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
