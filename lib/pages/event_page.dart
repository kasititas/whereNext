import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import 'edit_event_page.dart';
import 'package:flutter/cupertino.dart';
import 'event_page_tabs/event_guests_tab.dart';
import 'event_page_tabs/event_main_tab.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new EventPageState();

  String _eventID;
  bool _canEdit = false;
  bool _canAddGuests = false;
  bool _showFAB = false;
  bool _userAdded = false;
  String email;

  EventPage(this._eventID);

//  void fabOnPress(BuildContext context) {
//    Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new ScanBarcodePage(_eventID)));
//  }

}

class EventPageState extends State<EventPage>
    with SingleTickerProviderStateMixin {
  String userId;
  String _warning;
  TabController controller;
  FabMiniMenuItem editFABItem;
  FabMiniMenuItem addGuestFABItem;

  List<FabMiniMenuItem> fabItems = [];

  void _addGuest() {
//    Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new ScanBarcodePage(widget._eventID)));
  }

  void _editEvent() {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => new EventEditPage(widget._eventID)));
  }

  @override
  void initState() {
    super.initState();

    addGuestFABItem = new FabMiniMenuItem.noText(new Icon(Icons.account_box),
        Color(0xFF1c313a), 4.0, "Add Guests", _addGuest);

    editFABItem = new FabMiniMenuItem.noText(
        new Icon(Icons.edit), Color(0xFF1c313a), 4.0, "Edit Event", _editEvent);

    controller = new TabController(length: 2, vsync: this);
    adminPrivileges();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<String> createAlertDialog(BuildContext context) {
    TextEditingController editingController = TextEditingController();
    if (Platform.isIOS) {
      return showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Naudotojo el. paštas:'),
              content: TextField(
                controller: editingController,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Pridėti'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(editingController.text.toString());
                  },
                )
              ],
            );
          });
    }
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Naudotojo el. paštas:"),
            content: TextField(
              controller: editingController,
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text('Pridėti'),
                onPressed: () {
                  Navigator.of(context).pop(editingController.text.toString());
                },
              )
            ],
          );
        });
  }

  void addUser(String email) async {
    if (widget._canAddGuests == true) {
      var userId = await getGuestUserData(email);
      if (userId != null && _warning == null) {
        print("great success uid= $userId");
        List<String> members = List();
        members.add(userId);
        await Firestore.instance
            .collection("įvykiai")
            .document(widget._eventID)
            .updateData({
          'dalyviai': FieldValue.arrayUnion(members),
        });

        await Firestore.instance
            .document("įvykiai/" + widget._eventID + "/dalyviai/" + userId)
            .setData({"dalyvauja": true});

        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Naudotojas sėkmingai pridėtas"),
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
      } else {
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
    } else {
      if (Platform.isIOS) {
        showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('Naudotojo el. paštas:'),
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
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Naudotojas neturi teisės pridėti dalyvių"),
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
  }

  Future<String> getGuestUserData(String email) async {
    var uid;
    try {
      await Firestore.instance
          .collection('naudotojai')
          .where('ePaštas', isEqualTo: email)
          .getDocuments()
          .then((QuerySnapshot docs) {
        if (docs.documents.isNotEmpty) {
          uid = docs.documents[0].documentID;
        } else {
          setState(() {
            _warning = "Nėra tokio naudotojo susieto su $email";
          });
        }
      });
    } catch (e) {
      print(e);
    }
    return uid;
  }

  void adminPrivileges() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .document(
            "įvykiai/" + widget._eventID + "/administratoriai/" + user.uid)
        .snapshots()
        .listen((DocumentSnapshot administratorsSnapshot) {
      if (administratorsSnapshot.exists) {
        this.setState(() {
          widget._canAddGuests =
              administratorsSnapshot.data["gali-pridėti-dalyvius"];
          widget._canEdit = administratorsSnapshot.data["gali-redaguoti"];

          // TODO: fails if _canEdit or _canScan are null
          if (widget._canEdit || widget._canAddGuests) {
            widget._showFAB = true;
          } else {
            widget._showFAB = false;
          }

          fabItems = [];

          if (widget._canEdit) fabItems.add(editFABItem);
          if (widget._canAddGuests) fabItems.add(addGuestFABItem);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Scaffold(
        backgroundColor: Color.fromRGBO(236, 236, 236, 1.0),

        appBar: new AppBar(
          title: new Text("Įvykio detalės"),
          actions: <Widget>[
            FlatButton(
              child: Text('Pidėti dalyvį',
                  style: TextStyle(fontSize: 14.0, color: Colors.white)),
              onPressed: () {
                createAlertDialog(context).then((onValue) {
                  if (onValue != null || onValue.isNotEmpty) {
                    addUser(onValue);
                  }
                });
//                addUser("testas@gmail.com");
              },
            )
          ],
        ),
        // TODO: Currently using a package but its not great. Look at custom implementation
        floatingActionButton: widget._showFAB
            ? new FabDialer(fabItems, Colors.blue, new Icon(Icons.add))
            : new Container(),
        body: new TabBarView(
          controller: controller,
          children: <Widget>[
            new EventMainTabPage(widget._eventID),
            new EventGuestPage(widget._eventID),
          ],
        ),
        bottomNavigationBar: new Material(
          child: new TabBar(
              labelColor: Colors.blue,
              controller: controller,
              tabs: <Tab>[
                new Tab(
                  icon: new Icon(Icons.event),
                ),
                new Tab(
                  icon: new Icon(Icons.people),
                ),
              ]),
        ),
      ),
    );
  }
}
