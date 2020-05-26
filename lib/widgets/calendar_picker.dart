import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class CalendarPicker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new CalendarPickerState();

  TextEditingController _controller;
  String time;
  CalendarPicker(this._controller, this.time);
}

class CalendarPickerState extends State<CalendarPicker> {
  static String timeFormat = "yyyy-MM-dd h:mm";

  /// A date picket is first displayed, and then a time picker. The resulting
  /// date and time are then formatted and passed to the [_controller]
  void dateTimePicker() async {
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: stringToDate(widget._controller.text) ??
            DateTime.now().add(new Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(new Duration(days: 5 * 365)));

    if (date == null) return; // ignore: return_without_value

    final TimeOfDay time = await showTimePicker(
        context: context,
        initialTime: stringToTime(widget._controller.text) ??
            TimeOfDay.now().replacing(minute: 0));

    if (time == null) return; // ignore: return_without_value

    DateTime dateAndTime =
        new DateTime(date.year, date.month, date.day, time.hour, time.minute);

    this.setState(() =>
        widget._controller.text = DateFormat(timeFormat).format(dateAndTime));
  }

  ///Converts a given [dateString] in the correct format to a date. Otherwise returns null
  static DateTime stringToDate(String dateString) {
    try {
      return DateFormat(timeFormat).parseStrict(dateString);
    } catch (e) {
      return null;
    }
  }

  ///Converts a given [timeString] in the correct format to a date. Otherwise returns null
  static TimeOfDay stringToTime(String timeString) {
    try {
      return TimeOfDay.fromDateTime(
          DateFormat(timeFormat).parseStrict(timeString));
    } catch (e) {
      return null;
    }
  }

  ///Validates that the given date is in the correct format
  bool dateValidator(String date) {
    if (date.isEmpty) return true;
    return stringToDate(date) == null;
  }

  @override
  Widget build(BuildContext context) {
    if (this.widget.time == "startTime")
      return new Row(children: <Widget>[
        new Expanded(
            child: new TextFormField(
          decoration: new InputDecoration(
              labelText: "Pradžios laikas", icon: new Icon(Icons.calendar_today)),
          controller: widget._controller,
          keyboardType: TextInputType.datetime,
          validator: (val) => dateValidator(val) ? "Įveskite galiojančią datą" : null,
        )),
        new IconButton(
          icon: new Icon(Icons.more_horiz),
          onPressed: () => dateTimePicker(),
          tooltip: "Choose date",
        )
      ]);
    else
      return new Row(children: <Widget>[
        new Expanded(
            child: new TextFormField(
          decoration: new InputDecoration(
              labelText: "Pabaigos laikas", icon: new Icon(Icons.calendar_today)),
          controller: widget._controller,
          keyboardType: TextInputType.datetime,
          validator: (val) => dateValidator(val) ? "Įveskite galiojančią datą" : null,
        )),
        new IconButton(
          icon: new Icon(Icons.more_horiz),
          onPressed: () => dateTimePicker(),
          tooltip: "Choose date",
        )
      ]);
  }
}
