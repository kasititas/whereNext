import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wherenextapp/pages/event_search.dart';
import 'package:wherenextapp/pages/home_page.dart';
import 'package:wherenextapp/user.dart';

import 'menu_frame.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AppDrawer extends StatelessWidget {
  User user = new User();
  var profile;

  AppDrawer(this.profile, this.user);

  Future<Null> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MenuFrame(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          this.profile == null
              ? UserAccountsDrawerHeader(
                  accountEmail: Text("${this.user.email}"),
                  accountName: Text("${this.user.name}"),
                  currentAccountPicture: this.user.pictureUrl == null
                      ? CircleAvatar(
                          child: Text(
                            this.user.name.substring(0, 1),
                          ),
                        )
                      : CircleAvatar(
                          child: Image.network(user.pictureUrl),
                        ),
                )
              : UserAccountsDrawerHeader(
                  accountEmail: Text("${profile['email']}"),
                  accountName: Text("${profile['name']}"),
                  currentAccountPicture: CircleAvatar(
                    child: Image.network(
                      profile['picture']['data']['url'],
                    ),
                  ),
                ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Pagrindinis"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HomePage(profile, user),
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text("Rasti renginius"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EventSearch(profile, user),
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Atsijungti"),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
