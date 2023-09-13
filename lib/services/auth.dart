import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import 'package:firebase_core/firebase_core.dart';
import '../models/user.dart';

class AuthService {
  final fbAuth.FirebaseAuth _auth = fbAuth.FirebaseAuth.instance;
  User? _userFromFirebaseUser(fbAuth.User? user) {
    return user != null ? User(uid: user.uid, email: user.email ?? '') : null;
  }


  Stream<User?> get user {
    // return _auth.authStateChanges().map(_userFromFirebaseUser);
    return _auth.authStateChanges()
        .map(_userFromFirebaseUser);

  }
  //sigin in Anonymously
  Future<User?> signInAnon() async {
    try {
      fbAuth.UserCredential userCredential = await _auth.signInAnonymously();
      fbAuth.User? user = userCredential.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print('Error in anonymous sign-in: ${e.toString()}');
      return null;
    }
  }

  //sigin with email,pass
  Future<User?> siginemailpass(String email, String password) async {
    try {
      fbAuth.UserCredential userCredential =  await _auth.signInWithEmailAndPassword(email: email, password: password);
      fbAuth.User? user = userCredential.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print('error in register $e');
      return null;
    }
  }


  // register to firebase with email,pass
  Future<User?> register(String email, String password) async {
    try {
      fbAuth.UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      fbAuth.User? user = userCredential.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print('error in register $e');
      return null;
    }
  }

  // sign out
  Future signout() async{
    try{
      print('sogning out');

      return await _auth.signOut();

    }catch(e){
      print('error in signout ${e.toString()}');
      return null;

    }
  }
}
