import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/calendar_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEventForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new EditEventFormState();

  final void Function(Map<String, dynamic>) _submitFormCallback;
  final Map _startingData;
  EditEventForm(this._submitFormCallback, this._startingData);
}

class EditEventFormState extends State<EditEventForm> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  num _latitude;
  num _longitude;
  final TextEditingController _startTimeController =
      new TextEditingController();
  final TextEditingController _endTimeController = new TextEditingController();
  final TextEditingController _titleController = new TextEditingController();
  final TextEditingController _descriptionController =
      new TextEditingController();
  final TextEditingController _latitudeController = new TextEditingController();
  final TextEditingController _longitudeController =
      new TextEditingController();

  @override
  void initState() {
    if (!(widget._startingData == null)) {
      _startTimeController.text = DateFormat(CalendarPickerState.timeFormat)
          .format(widget._startingData["pradžios-laikas"].toDate());
      _endTimeController.text = DateFormat(CalendarPickerState.timeFormat)
          .format(widget._startingData["pabaigos-laikas"].toDate());
      _titleController.text = widget._startingData["pavadinimas"];
      _descriptionController.text = widget._startingData["aprašymas"];
      _latitudeController.text =
          widget._startingData["lokacija"].latitude.toString();
      _longitudeController.text =
          widget._startingData["lokacija"].longitude.toString();
    }
    super.initState();
  }

  ///Submits the form
  ///
  /// The form fields are first validated, and then the event details are based
  /// to a the [widget._submitFormCallback]
  void submitForm() async {
    final FormState form = _formKey.currentState;

    if (form.validate()) {
      form.save();

      widget._submitFormCallback(<String, dynamic>{
        "pavadinimas": _titleController.text,
        "aprašymas": _descriptionController.text,
        "lokacija": new GeoPoint(_latitude, _longitude),
        "pradžios-laikas":
            CalendarPickerState.stringToDate(_startTimeController.text),
        "pabaigos-laikas": CalendarPickerState.stringToDate(_endTimeController.text)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      child: new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Form(
          //autovalidate: true,
          key: _formKey,
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: new TextFormField(
                  controller: _titleController,
                  decoration: new InputDecoration(
                    labelText: "Įvykio pavadinimas",
                    border: new OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val.length < 1 ? "Įvykio pavadinimas negali būti tuščias":
                      val.length < 5 ? "Įvykio pavadinimas per trumpas" : null,
                  //onSaved: (val) => _eventName = val,
                ),
              ),
              new TextFormField(
                controller: _descriptionController,
                decoration: new InputDecoration(
                  labelText: "Aprašymas",
                  border: new OutlineInputBorder(),
                ),
                validator: (val) => val.isEmpty
                    ? "Įvykio aprašymas negali būti tuščias"
                    : null,
                maxLines: 3,
                //onSaved: (val) => _description = val,
              ),
              new CalendarPicker(_startTimeController, "startTime"),
              new CalendarPicker(_endTimeController, "endTime"),
              new Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: new TextFormField(
                  controller: _latitudeController,
                  decoration: new InputDecoration(
                    labelText: "Platuma",
                    //icon: new Icon(Icons.map),
                    border: new OutlineInputBorder(),
                  ),
                  validator: (val) => double.parse(val, (e) => null) == null
                      ? "Negalima reikšmė. Turi būti skaičius."
                      : null,
                  onSaved: (val) => _latitude = double.parse(val, (e) => null),
                ),
              ),
              new TextFormField(
                controller: _longitudeController,
                decoration: new InputDecoration(
                  labelText: "Ilguma",
                  //icon: new Icon(Icons.map),
                  border: new OutlineInputBorder(),
                ),
                validator: (val) => double.parse(val, (e) => null) == null
                    ? "Negalima reikšmė. Turi būti skaičius."
                    : null,
                onSaved: (val) => _longitude = double.parse(val, (e) => null),
              ),
              new MaterialButton(
                onPressed: () => submitForm(),
                child: new Text("Tvirtinti"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
