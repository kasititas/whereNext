import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:wherenextapp/user.dart';

class OurDatabase {
  final Firestore _firestore = Firestore.instance;

  Future<String> createUser(User user) async {
    String retVal = "error";

    try {
      await _firestore.collection("naudotojai").document(user.uid).setData({
        'vardas': user.name,
        'ePaštas': user.email,
        'nuotrauka': user.pictureUrl,
        'paskyraSukurta': Timestamp.now(),
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }



  Future<User> getUserInfo(String uid) async {
    User retVal = User();

    try {
      DocumentSnapshot _docSnapshot = await _firestore.collection("naudotojai").document(uid).get();
      retVal.uid = uid;
      retVal.name = _docSnapshot.data["vardas"];
      retVal.email = _docSnapshot.data["ePaštas"];
      retVal.pictureUrl = _docSnapshot.data["nuotrauka"];
      retVal.accountCreated = _docSnapshot.data["paskyraSukurta"];
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> createGroup(String groupName, String userUid, User initialBook) async {
    String retVal = "error";
    List<String> members = List();

    try {
      members.add(userUid);
      DocumentReference _docRef = await _firestore.collection("groups").add({
        'name': groupName,
        'leader': userUid,
        'members': members,
        'groupCreate': Timestamp.now(),
      });

      await _firestore.collection("users").document(userUid).updateData({
        'groupId': _docRef.documentID,
      });

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> joinGroup(String groupId, String userUid) async {
    String retVal = "error";
    List<String> members = List();
    try {
      members.add(userUid);
      await _firestore.collection("groups").document(groupId).updateData({
        'members': FieldValue.arrayUnion(members),
      });
      await _firestore.collection("users").document(userUid).updateData({
        'groupId': groupId,
      });

      retVal = "success";
    } on PlatformException catch (e) {
      retVal = "Make sure you have the right group ID!";
      print(e);
    } catch (e) {
      print(e);
    }

    return retVal;
  }

//  Future<OurGroup> getGroupInfo(String groupId) async {
//    OurGroup retVal = OurGroup();
//
//    try {
//      DocumentSnapshot _docSnapshot = await _firestore.collection("groups").document(groupId).get();
//      retVal.id = groupId;
//      retVal.name = _docSnapshot.data["name"];
//      retVal.leader = _docSnapshot.data["leader"];
//      retVal.members = List<String>.from(_docSnapshot.data["members"]);
//      retVal.groupCreated = _docSnapshot.data['groupCreated'];
//      retVal.currentBookId = _docSnapshot.data['currentBookId'];
//      retVal.currentBookDue = _docSnapshot.data['currentBookDue'];
//    } catch (e) {
//      print(e);
//    }
//
//    return retVal;
//  }
}