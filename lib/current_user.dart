
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wherenextapp/services/database.dart';
import 'package:wherenextapp/user.dart';

class CurrentUser extends ChangeNotifier {
  User _currentUser = User();

  User get getCurrentUser => _currentUser;

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> onStartUp() async {
    String retVal = "error";

    try {
      FirebaseUser _firebaseUser = await _auth.currentUser();
      if (_firebaseUser != null) {
        _currentUser = await OurDatabase().getUserInfo(_firebaseUser.uid);
        if (_currentUser != null) {
          retVal = "success";
        }
      }
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> signOut() async {
    String retVal = "error";

    try {
      await _auth.signOut();
      _currentUser = User();
      retVal = "success";
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> signUpUser(String email, String password, String fullName) async {
    String retVal = "error";
    User _user = User();
    try {
      AuthResult _authResult =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _user.uid = _authResult.user.uid;
      _user.email = _authResult.user.email;
      _user.name = fullName;
      String _returnString = await OurDatabase().createUser(_user);
      if (_returnString == "success") {
        retVal = "success";
      }
    } on PlatformException catch (e) {
      retVal = e.message;
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> loginUserWithEmail(String email, String password) async {
    String retVal = "error";

    try {
      AuthResult _authResult =
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _currentUser = await OurDatabase().getUserInfo(_authResult.user.uid);
      if (_currentUser != null) {
        retVal = "success";
      }
    } on PlatformException catch (e) {
      retVal = e.message;
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> loginUserWithGoogle() async {
    String retVal = "error";
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    User _user = User();

    try {
      GoogleSignInAccount _googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication _googleAuth = await _googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);
      AuthResult _authResult = await _auth.signInWithCredential(credential);
      if (_authResult.additionalUserInfo.isNewUser) {
        _user.uid = _authResult.user.uid;
        _user.email = _authResult.user.email;
        _user.name = _authResult.user.displayName;
        OurDatabase().createUser(_user);
      }
      _currentUser = await OurDatabase().getUserInfo(_authResult.user.uid);
      if (_currentUser != null) {
        retVal = "success";
      }
    } on PlatformException catch (e) {
      retVal = e.message;
    } catch (e) {
      print(e);
    }

    return retVal;
  }

//  Future<String> _signInFacebook() async {
//    FacebookLogin facebookLogin = new FacebookLogin();
//
//    final facebookLoginResult =
//    await facebookLogin.logIn(['email', 'public_profile']);
//    final token = facebookLoginResult.accessToken.token;
//
//    switch (facebookLoginResult.status) {
//      case FacebookLoginStatus.error:
//        onLoginStatusChanged(false);
//        break;
//      case FacebookLoginStatus.cancelledByUser:
//        onLoginStatusChanged(false);
//        break;
//      case FacebookLoginStatus.loggedIn:
//        var graphResponse = await http.get(
//            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(400)&access_token=$token');
//
//        profile = json.decode(graphResponse.body);
//        print(profile.toString());
//        final credential =
//        FacebookAuthProvider.getCredential(accessToken: token);
//        AuthResult _authResult = await _auth.signInWithCredential(credential);
//
//        onLoginStatusChanged(true, profileData: profile);
////        if (isLoggedIn) {
////          await _auth.currentUser().then((result) async {
////            user.uid = result.uid;
////            user.email = "${profileData['email']}";
////            user.pictureUrl = "${profile['picture']['data']['url']}";
////            user.name = "${profileData['name']}";
////            await OurDatabase().createUser(user);
////          });
////
////          user.email = "${profileData['email']}";
////          user.name = "${profileData['name']}";
//////          await OurDatabase().createUser(user);
////          Navigator.pushReplacement(
////            context,
////            MaterialPageRoute(builder: (context) => HomePage(profile, user)),
////          );
////        }
//        break;
//    }
//  }
}