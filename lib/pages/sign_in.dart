import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wherenextapp/services/database.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../user.dart';
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
  bool resetPassword = false;
  final formKey = GlobalKey<FormState>();
  String _warning;


  Future sendPasswordResetEmail(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }

  void _signIn({String email, String password}) {
    User user = new User();
    _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((authResult) async {
      user = await OurDatabase().getUserInfo(authResult.user.uid);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(null, user)),
      );
    }).catchError((err) {
      print(err.code);
      if (Platform.isIOS) {
        if (err.code == 'ERROR_WRONG_PASSWORD') {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text(
                      'Neteisingas įvestas slaptažodis paskyrai \"$email\"'),
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
                  title: Text('Nėra tokios paskyros susietos su \"$email\"'),
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
                  title: Text(
                      'Neteisingas įvestas slaptažodis paskyrai \"$email\"'),
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
        if (err.code == 'ERROR_USER_NOT_FOUND') {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Nėra tokios paskyros susietos su \"$email\"'),
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

  void showAlert() {
    if (_warning != null) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(_warning),
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


//      return Container(
//        color: Colors.amberAccent,
//        width: double.infinity,
//        padding: EdgeInsets.all(8.0),
//        child: Row(
//          children: <Widget>[
//            Padding(
//              padding: const EdgeInsets.only(right: 8.0),
//              child: Icon(Icons.error_outline),
//            ),
//            Expanded(
//              child: AutoSizeText(
//                _warning,
//                maxLines: 3,
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.only(left: 8.0),
//              child: IconButton(
//                icon: Icon(Icons.close),
//                onPressed: () {
//                  setState(() {
//                    _warning = null;
//                  });
//                },
//              ),
//            )
//          ],
//        ),
//      );
//    }
//    return SizedBox(
//      height: 0,
//    );
  }

  @override
  Widget build(BuildContext context) {
    Widget retVal;
    this.resetPassword == true?
        retVal = resetPasswordWidget():
    retVal = new Form(
      key: formKey,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
//          showAlert(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: <Widget>[
                Text(
                  'PRISIJUNGIMAS',
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
                      return 'Laukas tuščias';
                    }
                    if ((EmailValidator.validate(emailValue))) {
                      return null;
                    }
                    return 'El. laiškas negalimas';
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
                      return 'Laukas tuščias';
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
                  height: 8.0,
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
                      'PRISIJUNGTI',
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
                InkWell(
                  onTap: () {},
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
                InkWell(
                  onTap: () {
                    setState(() {
                      resetPassword= true;
                    });
//                    sendPasswordResetEmail(email);
                  },
                  child: Text(
                    'PAMIRŠOTE SLAPTAŽODĮ?',
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
          ),
          InkWell(
            onTap: () {
              widget.signUp();
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(30.0),
              color: Colors.black.withOpacity(0.2),
              child: Text(
                'NETURITE PASKYROS? REGISTRUOKITES!',
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
    return retVal;
  }

  Widget resetPasswordWidget() {
    return new Form(
      key: formKey,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: <Widget>[
                Text(
                  'ATKURTI SLAPTAŽODĮ',
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
                      return 'Laukas tuščias';
                    }
                    if ((EmailValidator.validate(emailValue))) {
                      return null;
                    }
                    return 'El. laiškas negalimas';
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
                  height: 8.0,
                ),
                SizedBox(
                  height: 14.0,
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      saveAttempted = true;
                    });
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                      await sendPasswordResetEmail(email);
                      _warning = "Slaptažodžio atkūrimo nuoroda nusiųsta į $email";
                      setState(() {
                        _warning = "Slaptažodžio atkūrimo nuoroda nusiųsta į $email";
//                        resetPassword = false;
                      });
                      showAlert();
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
                      'ATKURTI',
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
                SizedBox(
                  height: 14.0,
                ),
                InkWell(
                  onTap: () {
                     setState(() {
                       resetPassword = false;
                     });
//                    sendPasswordResetEmail(email);
                  },
                  child: Text(
                    'GRĮŽTI ATGAL',
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
          ),
          InkWell(
            onTap: () {
              widget.signUp();
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(30.0),
              color: Colors.black.withOpacity(0.2),
              child: Text(
                'NETURITE PASKYROS? REGISTRUOKITES!',
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
