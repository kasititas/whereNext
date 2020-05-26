import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class EventMainTabPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new EventMainTabPageState();

  String _eventId;
  EventMainTabPage(this._eventId);
  String _address;
  String _startTime;
  String _endTime;
}

class EventMainTabPageState extends State<EventMainTabPage>
    with SingleTickerProviderStateMixin {
  DocumentSnapshot eventDocumentSnapshot;

  @override
  void initState() {
    super.initState();
    getEventData(widget._eventId);
  }

  ///Queries OpenStreetMap using the latitude and longitude given in the [location].
  ///The resulting address is then displayed using setState.
  void setDetails(GeoPoint location, endTime, startTime) async {
    String query =
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=" +
            location.latitude.toString() +
            "&lon=" +
            location.longitude.toString();

    var response = await http.get(
      Uri.encodeFull(query),
    );
    String startFormattedDate =
        DateFormat('yyyy-MM-dd – HH:mm').format(startTime.toDate());
    String endFormattedDate =
        DateFormat('yyyy-MM-dd – HH:mm').format(endTime.toDate());

    this.setState(() => widget._startTime = startFormattedDate);
    this.setState(() => widget._endTime = endFormattedDate);
    this.setState(
        () => widget._address = json.decode(response.body)["display_name"]);
  }


  ///Gets the document snapshot of the event with [eventID] and updates the address appropriately
  void getEventData(String eventID) async {
    Firestore.instance
        .collection("įvykiai")
        .document(eventID)
        .snapshots()
        .listen((DocumentSnapshot eventSnapshot) {
      this.setState(() => eventDocumentSnapshot = eventSnapshot);
      setDetails(
          eventSnapshot.data["lokacija"],
          eventSnapshot.data["pabaigos-laikas"],
          eventSnapshot.data["pradžios-laikas"]);
//      setTime(eventSnapshot.data["pabaigos-laikas"],
//          eventSnapshot.data["pradžios-laikas"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return eventDocumentSnapshot == null
        ? new Text("Kraunama...")
        : new Stack(
            children: <Widget>[
              new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 12.0),
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        //Column with the event title and address
                        new Expanded(
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                eventDocumentSnapshot.data["pavadinimas"],
                                style: new TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              new SizedBox(
                                height: 10.0,
                              ),
                              new Text(
                                "Pradžia:",
                                style:
                                    new TextStyle(fontWeight: FontWeight.w300),
                              ),
                              new SizedBox(
                                height: 5.0,
                              ),
                              widget._startTime == null
                                  ? new Text("Kraunamas laikas...")
                                  : new Text(widget._startTime),
                              new SizedBox(
                                height: 10.0,
                              ),
                              new Text(
                                "Pabaiga:",
                                style:
                                    new TextStyle(fontWeight: FontWeight.w300),
                              ),
                              new SizedBox(
                                height: 5.0,
                              ),
                              widget._endTime == null
                                  ? new Text("Kraunamas laikas...")
                                  : new Text(widget._endTime),
                              new SizedBox(
                                height: 10.0,
                              ),
                              new Text(
                                "Adresas:",
                                style:
                                    new TextStyle(fontWeight: FontWeight.w300),
                              ),
                              new SizedBox(
                                height: 5.0,
                              ),
                              widget._address == null
                                  ? new Text("Kraunamas adresas...")
                                  : new Text(widget._address)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: new Row(
                      children: <Widget>[
                        new Text(
                          "Aprašymas: ",
                          style: new TextStyle(fontWeight: FontWeight.w300),
                        ),
                        new Text(
                          eventDocumentSnapshot.data["aprašymas"],
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // If set to display a full screen QR Code, the QR code goes full screen
              new Container(),
            ],
          );
  }
}
