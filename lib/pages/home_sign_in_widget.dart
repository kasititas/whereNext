import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:wherenextapp/pages/home_page.dart';
import 'package:wherenextapp/services/auth.dart';
import 'package:wherenextapp/services/database.dart';

import '../auth_provider.dart';
import '../current_user.dart';
import '../user.dart';

class HomeSignInWidget extends StatefulWidget {
  final Function goToSignUp;
  final Function goToSignIn;

  HomeSignInWidget({this.goToSignUp, this.goToSignIn});

  @override
  _HomeSignInWidgetState createState() => _HomeSignInWidgetState();
}

enum AuthStatus {
  notDetermined,
  notSignedIn,
  signedIn,
}

class _HomeSignInWidgetState extends State<HomeSignInWidget> {
  bool isLoggedIn = false;
  bool isCreated = false;
  AuthStatus authStatus = AuthStatus.notDetermined;
  User user = new User();
  var profile;

  var profileData;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

//  @override
//  void didChangeDependencies() async {
//    super.didChangeDependencies();
//
//    //get the state, check current User, set AuthStatus based on state
//    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);
//    String _returnString = await _currentUser.onStartUp();
//    if (_returnString == "success") {
//      isCreated = true;
//    } else {
//      setState(() {
//        isCreated = false;
//      });
//    }
//  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final BaseAuth auth = AuthProvider.of(context).auth;
    auth.currentUser().then((String userId) {
      setState(() {
        this.user.uid = userId;
        authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void _signInFacebook() async {
    FacebookLogin facebookLogin = new FacebookLogin();
    User _currentUser = User();
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

        profile = json.decode(graphResponse.body);
        print(profile.toString());
        final credential =
            FacebookAuthProvider.getCredential(accessToken: token);
        AuthResult _authResult = await _auth.signInWithCredential(credential);
        onLoginStatusChanged(true, profileData: profile);
        if (_authResult.additionalUserInfo.isNewUser) {
          user.uid = _authResult.user.uid;
          user.email = _authResult.user.email;
          user.name = _authResult.user.displayName;
          user.pictureUrl = "${profile['picture']['data']['url']}";
          OurDatabase().createUser(user);
        }
        _currentUser = await OurDatabase().getUserInfo(_authResult.user.uid);
        if (_currentUser != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(profile, _currentUser)),
          );
        }
        break;
    }
  }

  void _signUpUser(String email, String password, BuildContext context,
      String fullName) async {
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);

    try {
      String _returnString =
          await _currentUser.signUpUser(email, password, fullName);
      if (_returnString == "success") {
        Navigator.pop(context);
      } else {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(_returnString),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget retVal;
    retVal = showLoading();
    this.authStatus == AuthStatus.notDetermined
        ? retVal = showLoading()
        : this.authStatus == AuthStatus.signedIn && user.uid == null
            ? retVal = showLoading()
            : this.authStatus == AuthStatus.notSignedIn &&
                    this.isLoggedIn == true
                ? retVal = Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ))
                : retVal = Padding(
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
                                  '| Prisijungti su Facebook',
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
                                  'Registruotis',
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
                            'JAU TURITE PASKYRĄ? PRISIJUNGITE!',
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
    return retVal;
  }

  Widget showLoading() {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.white,
      ),
    );
  }
}
