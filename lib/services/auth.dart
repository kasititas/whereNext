import 'package:firebase_auth/firebase_auth.dart';
import 'package:wherenextapp/user.dart';
import 'dart:async';

abstract class BaseAuth {
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> signInWithCredential(AuthCredential token);
  Future<String> currentUser();
  Future<void> signOut();
  Future<bool> isEmailVerified();
  Future<void> sendEmailVerification();
}

class AuthService implements BaseAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

////   create user obj based on firebase user
//  User _userFromFirebaseUser(FirebaseUser user) {
//    return user != null ? User() : null;
//  }

//   auth change user stream
//  Stream<User> get user {
//    return _auth.onAuthStateChanged
//        //.map((FirebaseUser user) => _userFromFirebaseUser(user));
//        .map(_userFromFirebaseUser);
//  }



  // sign in with email and password
  @override
  Future<String> currentUser() async {
    final FirebaseUser user = await _auth.currentUser();
    return user?.uid;
  }

  // register with email and password

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  @override
  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
        email: email, password: password)) as FirebaseUser;
    return user?.uid;
    return null;
  }

  @override
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
        email: email, password: password)) as FirebaseUser;
    return user?.uid;
  }

  @override
  Future<String> signInWithCredential(AuthCredential token) async {
    final FirebaseUser user =
        (await _auth.signInWithCredential(token)) as FirebaseUser;
    return user?.uid;
  }

  @override
  Future<bool> isEmailVerified() async{
    var user = await _auth.currentUser();
    return user.isEmailVerified;
  }

  @override
  Future<void> sendEmailVerification() async{
    var user = await _auth.currentUser();
    user.sendEmailVerification();
  }
}
