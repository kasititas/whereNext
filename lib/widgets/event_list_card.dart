import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/event_page.dart';

class EventCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new EventCardController();
  bool remove = false;
  bool leave = false;
  bool _canEdit = false;
  String _name;
  String _description;
  String _documentID;

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
                  _createTile(context, "Ištrinti įvykį", Icons.remove_circle,
                      true, _removeEvent),
                ],
              );
            })
        : showBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _createTile(context, "palikti įvykį", Icons.remove_circle,
                      true, _leaveEvent),
                ],
              );
            });
//
  }

  _removeEvent() {
    print('remove event');
    remove = true;
  }

  _leaveEvent() {
    print('remove event');
    leave = true;
  }

  confirm(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Tikrai norite ištrinti įvykį"),
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
                  removeConfirmed();
                },
                child: Text("Taip"),
              )
            ],
          );
        });
  }

  void removeConfirmed() {
    Firestore.instance.collection("įvykiai").document(_documentID).delete();
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        print("confiming");
        Navigator.pop(context);
        removeConfirmed();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text(
          "Would you like to continue learning how to use Flutter alerts?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  ListTile _createTile(BuildContext context, String name, IconData icon,
      bool remove, Function action) {
    switch (remove) {
      case true:
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
            await confirm(context);
            Navigator.pop(context);
          },
        );
      case false:
        return ListTile(
          leading: Icon(icon),
          title: Text(
            name,
          ),
          onTap: () {
            Navigator.pop(context);
            action();
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
        action();
      },
    );
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
