import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/event_page.dart';

class EventCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new EventCardController();
  String action;
  bool leave = false;
  bool _canEdit = false;
  String _name;
  String _description;
  String _documentID;
  String currentUid;

  onTap(BuildContext context) {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) => new EventPage(_documentID)));
  }

  onLongPress(BuildContext context) {
    return mainBottomSheet(context);
  }

  mainBottomSheet(BuildContext context) {
    this._canEdit == true
        ? showBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _createTile(
                      context, "Ištrinti įvykį", Icons.remove_circle, "remove"),
                ],
              );
            })
        : showBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _createTile(
                      context, "palikti įvykį", Icons.remove_circle, "leave"),
                ],
              );
            });
//
  }


  confirm(BuildContext context, String action, String title) async {
    var retVal;
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          Platform.isIOS?
          retVal = CupertinoAlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text('$_name')],
              ),
            ),
            actions: <Widget>[
              CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Atšaukti"),
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (action == "leave") {
                    leaveConfirmed();
                  } else
                    removeConfirmed();
                },
                child: Text("Taip"),
              )
            ],
          ):
          retVal = AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text('$_name')],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Atšaukti"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (action == "leave") {
                    leaveConfirmed();
                  } else
                    removeConfirmed();
                },
                child: Text("Taip"),
              )
            ],
          );
          return retVal;
        });
  }

  void removeConfirmed() {
    Firestore.instance.collection("įvykiai").document(_documentID).delete();
  }

  void leaveConfirmed()  {

    Firestore.instance
        .collection("įvykiai")
        .document(_documentID)
        .collection("dalyviai")
        .document(currentUid)
        .delete();

    removeFromArray();

  }

  ListTile _createTile(
      BuildContext context, String name, IconData icon, String action) {
    switch (action) {
      case "remove":
        return ListTile(
          leading: Icon(icon),
          title: Text(
            name,
            style: new TextStyle(
              color: Colors.red,
            ),
          ),
          onTap: () async {
//            Navigator.pop(context);
            await confirm(context, action, "Tikrai norite ištrinti įvykį");
            Navigator.pop(context);
          },
        );
      case "leave":
        return ListTile(
          leading: Icon(icon),
          title: Text(
            name,
            style: new TextStyle(
              color: Colors.red,
            ),
          ),
          onTap: () async {
            await confirm(context, action, "Tikrai norite palikti įvykį");
            Navigator.pop(context);
          },
        );
    }
    return ListTile(
      leading: Icon(icon),
      title: Text(
        name,
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  removeFromArray() async {

    DocumentReference docRef =
    Firestore.instance.collection("įvykiai").document(_documentID);
    DocumentSnapshot doc = await docRef.get();
    List members = doc.data['dalyviai'];
    if (members.contains(currentUid) == true) {
      docRef.updateData({
        'dalyviai': FieldValue.arrayRemove([currentUid])
      });
    }
  }

  EventCard(this._name, this._description, this._documentID);
}

class EventCardController extends State<EventCard> {
  @override
  void initState() {
    super.initState();
    adminPrivileges();
  }

  void adminPrivileges() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      widget.currentUid = user.uid;
    });

    Firestore.instance
        .document(
            "įvykiai/" + widget._documentID + "/administratoriai/" + user.uid)
        .snapshots()
        .listen((DocumentSnapshot administratorsSnapshot) {
      if (administratorsSnapshot.exists) {
        this.setState(() {
          widget._canEdit = administratorsSnapshot.data["gali-redaguoti"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new InkWell(
        onTap: () => widget.onTap(context),
        onLongPress: () => widget.mainBottomSheet(context),
        child: new Card(
            child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new ListTile(
              leading: const Icon(
                Icons.check,
                color: Colors.greenAccent,
              ),
              title: new Text(widget._name),
              subtitle: new Text(widget._description.length < 35
                  ? widget._description
                  : widget._description.substring(0, 30) + "..."),
            ),
          ],
        )));
  }
}
