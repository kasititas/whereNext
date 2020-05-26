import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:wherenextapp/menu_frame.dart';
import 'package:wherenextapp/services/database.dart';
import '../user.dart';
import 'home_page.dart';

class CreateLogin extends StatefulWidget {
  final Function cancelBackToHome;

  CreateLogin({this.cancelBackToHome});
  @override
  _CreateLoginState createState() => _CreateLoginState();
}

class _CreateLoginState extends State<CreateLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String name, email, password, passwordConfirm;
  bool saveAttempted = false;
  final formKey = GlobalKey<FormState>();
  void _createUser({String email, String password}) {
    User user = new User();
    _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((authResult) async {
      user.uid = authResult.user.uid;
      user.email = authResult.user.email;
      user.name = name;
     String _returnString = await OurDatabase().createUser(user);
     if(_returnString == "success") {
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) => MenuFrame()),
       );
     }

    }).catchError((err) {
      print(err.code);
      if (Platform.isIOS) {
        if (err.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text(
                      'Šis el. paštas jau naudojamas su kita paskyra'),
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
        if (err.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                      'Šis el. paštas jau naudojamas su kita paskyra'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
    return new Form(
      key: formKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: <Widget>[
            Text(
              'REGISTRACIJA',
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
              onChanged: (textValue) {
                setState(() {
                  name = textValue;
                });
              },
              validator: (nameValue) {
                if (nameValue.isEmpty) {
                  return 'Šis laukas privalomas';
                }
                return null;
              },
              decoration: InputDecoration(
                errorStyle: TextStyle(
                  color: Colors.white,
                ),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                  color: Colors.white,
                )),
                hintText: 'Įveskite vardą',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                focusColor: Colors.white,
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
            SizedBox(
              height: 12.0,
            ),
            TextFormField(
              autovalidate: saveAttempted,
              onChanged: (textValue) {
                setState(() {
                  email = textValue;
                });
              },
              validator: (emailValue) {
                if (emailValue.isEmpty) {
                  return 'Šis laukas privalomas';
                }
                if ((EmailValidator.validate(emailValue))) {
                  return null;
                }
                return 'El. paštas negalimas';
              },
              decoration: InputDecoration(
                errorStyle: TextStyle(
                  color: Colors.white,
                ),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                  color: Colors.white,
                )),
                hintText: 'Įveskite el. paštą',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                focusColor: Colors.white,
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
            SizedBox(
              height: 12.0,
            ),
            TextFormField(
              autovalidate: saveAttempted,
              onChanged: (textValue) {
                setState(() {
                  password = textValue;
                });
              },
              validator: (pswValue) {
                if (pswValue.isEmpty) {
                  return 'Šis laukas privalomas';
                }
                if (pswValue.length < 8) {
                  return 'Slaptažodis turi būti sudarytas iš 8 simbolių';
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
                hintText: 'Slaptažodis',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                focusColor: Colors.white,
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
            SizedBox(
              height: 12.0,
            ),
            TextFormField(
              autovalidate: saveAttempted,
              onChanged: (textValue) {
                setState(() {
                  passwordConfirm = textValue;
                });
              },
              validator: (pswConfirmValue) {
                if (pswConfirmValue != password) {
                  return 'Slaptažodžiai turi sutapti';
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
                hintText: 'Pakartokite slaptažodį',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                focusColor: Colors.white,
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    widget.cancelBackToHome();
                  },
                  child: Text(
                    'ATŠAUKTI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 38.0,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      saveAttempted = true;
                    });
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                      _createUser(email: email, password: password);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 17.0,
                      horizontal: 40.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ),
                    ),
                    child: Text(
                      'REGISTRUOTIS',
                      style: TextStyle(
                        color: Color.fromRGBO(31, 114, 239, 1.0),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
