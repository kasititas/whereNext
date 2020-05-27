import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wherenextapp/auth_provider.dart';
import 'package:wherenextapp/pages/create_login.dart';
import 'package:wherenextapp/pages/home_page.dart';
import 'package:wherenextapp/pages/home_sign_in_widget.dart';
import 'package:wherenextapp/pages/sign_in.dart';
import 'package:wherenextapp/services/auth.dart';
import 'package:wherenextapp/services/database.dart';
import 'package:wherenextapp/user.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MenuFrame extends StatelessWidget {
  void ensureIfAlreadyLogedIn(BuildContext context) async {
    User _currentUser = new User();
    FirebaseUser _firebaseUser = await _auth.currentUser();
    if (_firebaseUser != null) {
      _currentUser = await OurDatabase().getUserInfo(_firebaseUser.uid);
      if (_currentUser != null) {
        print(_currentUser.toString());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(null, _currentUser)),
        );
      }
    }
  }

  final PageController pageController = PageController();
  Duration _animationDuration = Duration(milliseconds: 150);

  void _changePage(int page) {
    pageController.animateToPage(page,
        duration: _animationDuration, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    ensureIfAlreadyLogedIn(context);
    return AuthProvider(
      auth: AuthService(),
      child: Material(
        child: Builder(
          builder: (BuildContext context) {
            return OfflineBuilder(
              connectivityBuilder: (BuildContext context,
                  ConnectivityResult connectivityResult, Widget child) {
                final bool connected =
                    connectivityResult != ConnectivityResult.none;
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    child,
                    Visibility(
                      visible: !connected,
                      child: Positioned(
                        left: 0.0,
                        right: 0.0,
                        height: 80.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: connected
                              ? null
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Nėra ryšio',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    SizedBox(
                                      width: 12.0,
                                      height: 12.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                        ),
                      ),
                    )
                  ],
                );
              },
              child: Container(
                child: Column(
                  children: <Widget>[
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 28.0, vertical: 40.0),
                        child: Column(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.searchLocation,
                              color: Color.fromRGBO(13, 90, 189, 1.0),
                              size: 60,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'WHERE',
                                  style: TextStyle(
                                      fontSize: 35.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(13, 90, 189, 1.0)),
                                ),
                                Text(
                                  'NEXT',
                                  style: TextStyle(
                                      fontSize: 35.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            Text(
                              'Raskite vietas, kurkite įvykius bei kaupkite geriausius prisiminimus',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
//                    SizedBox(
//                      height: 65.0,
//                    ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: pageController,
                        children: <Widget>[
                          HomeSignInWidget(
                            goToSignIn: () {
                              _changePage(1);
                            },
                            goToSignUp: () {
                              _changePage(2);
                            },
                          ),
                          new SignIn(
                            signUp: () {
                              _changePage(2);
                            },
                          ),
                          new CreateLogin(
                            cancelBackToHome: () {
                              _changePage(0);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(64, 165, 238, 1.0),
                      Color.fromRGBO(23, 101, 239, 1.0)
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
