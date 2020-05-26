//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wherenextapp/menu_frame.dart';
import 'package:wherenextapp/services/database.dart';
import 'package:wherenextapp/widgets/event_list_card.dart';

import '../app_drawer.dart';
import '../user.dart';
import 'add_event_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

  User user = new User();
  var profile;

  HomePage(this.profile, this.user);
}

class _HomePageState extends State<HomePage> {
  void addEvent() {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => new AddEventPage()));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: AppDrawer(widget.profile, widget.user),
      appBar: AppBar(
        title: Text("Pagrindinis"),
      ),
      floatingActionButton: FloatingActionButton(
        //backgroundColor: Colors.amberAccent,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: () => addEvent(),
      ),
      body: new Material(
        color: Color.fromRGBO(64, 165, 238, 1.0),
        child: new StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('įvykiai')
              .where('dalyviai', arrayContains: widget.user.uid)
              .orderBy("pradžios-laikas", descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return new Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              );
            } else
            if (!snapshot.hasData) {
              return new Center(
                  child: Text(
                "Nėra įvykių",
                style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ));
            }
            return new ListView(
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return new EventCard(document['pavadinimas'],
                    document['aprašymas'], document.documentID);
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
