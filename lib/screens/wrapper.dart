import 'package:crudapplication/screens/authenticate/authenticate.dart';
import 'package:crudapplication/screens/authenticate/sign_in.dart';
import 'package:crudapplication/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crudapplication/models/user.dart';

class wrapper extends StatefulWidget { // Capitalize class name
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<wrapper> { // Use _WrapperState as the state class
  bool showsignin = true;

  void toggleview() {
    setState(() {
      showsignin = !showsignin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    String varr=user.toString();
    print('users are $user');
    if (user == null) {
      return sigin(toggle: toggleview);
    } else {
      return home(user: user); // Pass the user object to the Home widget
    }
  }
}
