import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/edit_event_form.dart';
class AddEventPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AddEventPageState();
}

class AddEventPageState extends State<AddEventPage> {
  ///Submits the form
  ///
  /// The form fields are first validated, and then the event is added to the
  /// database. The current user is then added to the Administrator collection
  /// of the event with all privileges enabled.
  void submitForm (Map data) async {
    DocumentReference event = await Firestore.instance.collection("įvykiai").add(
        data
    );

    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    List<String> members = List();
    members.add(user.uid);
    await Firestore.instance.collection("įvykiai").document(event.documentID).updateData({
      'dalyviai': FieldValue.arrayUnion(members),
    });

    Firestore.instance.document("įvykiai/" + event.documentID + "/administratoriai/" + user.uid).setData(
        {
          "gali-redaguoti": true,
          "gali-pridėti-dalyvius": true
        }
    );

    Firestore.instance.document("įvykiai/" + event.documentID + "/dalyviai/" + user.uid).setData(
        {
          "dalyvauja": true
        }
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text("Pridėti įvykį"),),
        body: new EditEventForm(submitForm, null)
    );
  }
}