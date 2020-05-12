import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'home_page.dart';

class SignIn extends StatefulWidget {
  final Function signUp;

  SignIn({this.signUp});
  @override
  _State createState() => _State();
}

class _State extends State<SignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email, password;
  bool saveAttempted = false;
  bool _rememberPassword = false;
  final formKey = GlobalKey<FormState>();
  void _signIn({String email, String password}) {
    _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((authResult) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }).catchError((err) {
      print(err.code);
      if (Platform.isIOS) {
        if (err.code == 'ERROR_WRONG_PASSWORD') {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text('Incorrect password for \"$email\"'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              });
        }
        if (err.code == 'ERROR_USER_NOT_FOUND') {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text('No account associated with \"$email\"'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              });
        }
      } else {
        if (err.code == 'ERROR_WRONG_PASSWORD') {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Incorrect password for \"$email\"'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () {Navigator.pop(context);},
                    )
                  ],
                );
              });
        }
        if (err.code == 'ERROR_USER_NOT_FOUND') {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('No account associated with \"$email\"'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () {Navigator.pop(context);},
                    )
                  ],
                );
              });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: <Widget>[
                Text(
                  'SIGN IN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 12.0,
                ),
                TextFormField(
                  autovalidate: saveAttempted,
                  onChanged: (textVal) {
                    setState(() {
                      email = textVal;
                    });
                  },
                  validator: (emailValue) {
                    if (emailValue.isEmpty) {
                      return 'Field empty';
                    }
                    if ((EmailValidator.validate(emailValue))) {
                      return null;
                    }
                    return 'Email is not valid';
                  },
                  decoration: InputDecoration(
                    errorStyle: TextStyle(
                      color: Colors.white,
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.white,
                    )),
                    hintText: 'Enter Email',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    focusColor: Colors.white,
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  autovalidate: saveAttempted,
                  onChanged: (textVal) {
                    setState(() {
                      password = textVal;
                    });
                  },
                  validator: (nameValue) {
                    if (nameValue.isEmpty) {
                      return 'Field is empty';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    errorStyle: TextStyle(
                      color: Colors.white,
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.white,
                    )),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    focusColor: Colors.white,
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Checkbox(
                      activeColor: Colors.indigo,
                      value: _rememberPassword,
                      onChanged: (newValue) {
                        setState(() {
                          _rememberPassword = newValue;
                        });
                      },
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      'Remember Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 14.0,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      saveAttempted = true;
                    });
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                      _signIn(email: email, password: password);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 17.0,
                      horizontal: 55.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ),
                    ),
                    child: Text(
                      'LOG IN',
                      style: TextStyle(
                        color: Color.fromRGBO(31, 114, 239, 1.0),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                InkWell(onTap: () {

                },
                  child: Container(
                    padding: EdgeInsets.all(17.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ),
                    ),
                    child: Icon(
                      FontAwesomeIcons.facebookF,
                      color: Color.fromRGBO(60, 92, 160, 1.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 14.0,
                ),
                Text(
                  'FORGOT PASSWORD?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          InkWell(onTap: () {
            widget.signUp();
          },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(30.0),
              color: Colors.black.withOpacity(0.2),
              child: Text(
                'DON\'T HAVE AN ACCONT? SIGN UP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(121, 158, 186, 1.0),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
