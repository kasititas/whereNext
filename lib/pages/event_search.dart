
import 'package:flutter/material.dart';

import '../app_drawer.dart';
import '../user.dart';
class EventSearch extends StatefulWidget {
  @override
  _EventSearchState createState() => _EventSearchState();
  User user = new User();
  var profile;

  EventSearch(this.profile, this.user);
}

class _EventSearchState extends State<EventSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rasti renginius"),
      ),
      drawer: AppDrawer(widget.profile, widget.user),

    );
  }
}
