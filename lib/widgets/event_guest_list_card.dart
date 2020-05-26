import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventGuestListCard extends StatefulWidget {
  State<StatefulWidget> createState() => new EventGuestListCardState();

  String _currentUid;
  String _guestUserID;
  bool _going;
  bool _isAdmin;
  EventGuestListCard(
      this._currentUid, this._isAdmin, this._guestUserID, this._going);
}

class EventGuestListCardState extends State<EventGuestListCard> {
  String name;
  String email;

  get _guestUserID => widget._guestUserID;

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
                  Icons.remove_circle, true, _leaveEvent),
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
                  _createTile(context, "message", Icons.message, false,
                      _removeFromEvent),
                  _createTile(
                      context, "pridėti", Icons.add, false, _addToAdmins),
                  _createTile(context, "pašalinti iš grupės",
                      Icons.remove_circle, true, _removeFromEvent),
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
                          true, _leaveEvent),
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
          onTap: () {
            Navigator.pop(context);
            action();
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
