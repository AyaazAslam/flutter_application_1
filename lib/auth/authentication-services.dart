import 'package:flutter_application_1/components/snak_bar.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/ui/bottom_nav_bar.dart';
import 'package:flutter_application_1/ui/first.dart';
import 'package:flutter_application_1/utils/static_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServices {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .where("userId", isEqualTo: userCredential.user!.uid)
          .get();
      if (snapshot.docs.isEmpty) {

      } else {
        ModelClass model =
            ModelClass.fromMap(snapshot.docs[0].data() as Map<String, dynamic>);
        print(model);
        StaticData.userModel = model;
      

      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    return null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("Failed to send reset email: $e");
    }
  }

  // Sign out
  Future<void> signOut() async {
    await auth.signOut();

  }

  // Sign up
  Future<UserCredential?> signUpt(
      String email, String password, String username) async {

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
