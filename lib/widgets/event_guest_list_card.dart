import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wherenextapp/pages/home_page.dart';
import 'package:wherenextapp/services/database.dart';
import 'package:wherenextapp/user.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class EventGuestListCard extends StatefulWidget {
  State<StatefulWidget> createState() => new EventGuestListCardState();
  String _eventID;
  String _currentUid;
  String _guestUserID;
  bool _going;
  bool _isAdmin;
  EventGuestListCard(
      this._eventID,
      this._currentUid, this._isAdmin, this._guestUserID, this._going);
}

class EventGuestListCardState extends State<EventGuestListCard> {
  String name;
  String email;
  User _currentUser = User();


  get _guestUserID => widget._guestUserID;

  @override
  void initState() {
    super.initState();
    getGuestUserData();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    FirebaseUser _firebaseUser = await _auth.currentUser();
    _currentUser = await OurDatabase().getUserInfo(_firebaseUser.uid);
  }

  ///Gets a list of guests from the database
  void getGuestUserData() {
    Firestore.instance
        .collection('naudotojai')
        .document(widget._guestUserID)
        .get()
        .then((DocumentSnapshot userDocument) {
      this.setState(() {
        name = userDocument['vardas'];
        email = userDocument['ePaštas'];
      });
    });
  }

  onTap(BuildContext context) {
    return mainBottomSheet(context);
  }

  mainBottomSheet(BuildContext context) {
    widget._isAdmin == true && widget._guestUserID == widget._currentUid
        ? showBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text(name),
              _createTile(context, "palikti įvykį",
                  Icons.remove_circle, "leave"),
            ],
          );
        })
        :
    widget._isAdmin == true
        ? showBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Text(name),
                  _createTile(
                      context, "pridėti", Icons.add, "add"),
                  _createTile(context, "pašalinti iš įvykio",
                      Icons.remove_circle, "remove"),
                ],
              );
            })
        : widget._currentUid == widget._guestUserID
            ? showBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Center(
                        child: Text(
                          name,
                        ),
                      ),
                      _createTile(context, "palikti įvykį", Icons.remove_circle,
                           "leave"),
                    ],
                  );
                })
            : showBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Center(
                        child: Text(
                          name,
                        ),
                      ),
                      new SizedBox(
                        height: 30,
                      )
                    ],
                  );
                });
  }

  void leaveConfirmed(String uid)  {

    Firestore.instance
        .collection("įvykiai")
        .document(widget._eventID)
        .collection("dalyviai")
        .document(uid)
        .delete();

    removeFromArray(uid);

  }

  removeFromArray(String uid) async {

    DocumentReference docRef =
    Firestore.instance.collection("įvykiai").document(widget._eventID);
    DocumentSnapshot doc = await docRef.get();
    List members = doc.data['dalyviai'];
    if (members.contains(uid) == true) {
      docRef.updateData({
        'dalyviai': FieldValue.arrayRemove([uid])
      });
    }
  }

  ListTile _createTile(BuildContext context, String name, IconData icon,
      String action) {
    switch(action) {
      case "leave":
        return ListTile(
          leading: Icon(icon),
          title: Text(
            name,
            style: new TextStyle(
              color: Colors.red,
            ),
          ),
          onTap: () async{
            await confirmLeave(context, action, "Tikrai norite palikti įvykį", widget._currentUid);
            Navigator.pop(context);
          },
        );
      case "remove":
        return ListTile(
          leading: Icon(icon),
          title: Text(
            name,
            style: new TextStyle(
              color: Colors.red,
            ),
          ),
          onTap: () async{
            await confirm(context, action, "Tikrai norite ištrinti svečią", widget._guestUserID);
            Navigator.pop(context);
          },
        );
      case "add":
        return ListTile(
          leading: Icon(icon),
          title: Text(
            name,
          ),
          onTap: () {
//            await confirm(context, action, "Tikrai norite ištrinti sveičią");
            Navigator.pop(context);
          },
        );
    }
  }

  confirmLeave(BuildContext context, String action, String title, String uid) async {
    var retVal;
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          Platform.isIOS?
          retVal = CupertinoAlertDialog(
            title: Text(title),
            actions: <Widget>[
              CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Atšaukti"),
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                  removeFromArray(uid);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(null, _currentUser)),
                  );
                },
                child: Text("Taip"),
              )
            ],
          ):
          retVal = AlertDialog(
            title: Text(title),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Atšaukti"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  removeFromArray(uid);
                },
                child: Text("Taip"),
              )
            ],
          );
          return retVal;
        });
  }

  confirm(BuildContext context, String action, String title, String uid) async {
    var retVal;
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          Platform.isIOS?
          retVal = CupertinoAlertDialog(
            title: Text(title),
            actions: <Widget>[
              CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Atšaukti"),
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                    leaveConfirmed(uid);
                },
                child: Text("Taip"),
              )
            ],
          ):
          retVal = AlertDialog(
            title: Text(title),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Atšaukti"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                    leaveConfirmed(uid);
                },
                child: Text("Taip"),
              )
            ],
          );
          return retVal;
        });
  }

  _removeFromEvent() {
//    showDialog(
//        context: context,
//        builder: (context) {
//          return AlertDialog(
//            title: Text("Naudotojo el. paštas:"),
//            content: TextField(
//              controller: editingController,
//            ),
//            actions: <Widget>[
//              MaterialButton(
//                elevation: 5.0,
//                child: Text('Pridėti'),
//                onPressed: () {
//                  Navigator.of(context).pop(editingController.text.toString());
//                },
//              )
//            ],
//          );
//        });
  }

  _leaveEvent() {

  }

  _addToAdmins() {
    print('action 1 $_guestUserID');
  }

  @override
  Widget build(BuildContext context) {
    return name == null
        ? new Card(
            child: new ListTile(
              leading: const CircularProgressIndicator(),
              title: new Text("Kraunami duomenys..."),
            ),
          )
        : new InkWell(
            onTap: () => mainBottomSheet(context),
            child: new Card(
              child: new ListTile(
                leading: widget._going
                    ? const Icon(
                        Icons.check,
                        color: Colors.lightBlue,
                      )
                    : const Icon(
                        Icons.clear,
                        color: Colors.redAccent,
                      ),
                title: new Text(name),
                subtitle: new Text(email),
              ),
            ),
          );
  }
}
