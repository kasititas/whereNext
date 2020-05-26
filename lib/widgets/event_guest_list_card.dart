import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventGuestListCard extends StatefulWidget {
  State<StatefulWidget> createState() => new EventGuestListCardState();

  String _guestUserID;
  bool _going;
  EventGuestListCard(this._guestUserID, this._going);
}

class EventGuestListCardState extends State<EventGuestListCard> {
  String name;
  String email;

  @override
  void initState() {
    super.initState();
    getGuestUserData();
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

  @override
  Widget build(BuildContext context) {
    return name == null
        ? new Card(
            child: new ListTile(
              leading: const CircularProgressIndicator(),
              title: new Text("Kraunami duomenys..."),
            ),
          )
        : new Card(
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
          );
  }
}
