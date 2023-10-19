import 'package:crudapplication/screens/authenticate/register.dart';
import 'package:crudapplication/screens/authenticate/sign_in.dart';
import 'package:flutter/material.dart';
class authenticate extends StatefulWidget {
  const authenticate({Key? key}) : super(key: key);
  @override
  State<authenticate> createState() => _authenticateState();
}
class _authenticateState extends State<authenticate> {
  bool showsignin=true;
  void toggleview(){
    setState(() {
      showsignin=!showsignin;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(showsignin){
      return sigin(toggle: toggleview);
    }else{
      return register();
    }
  }
}
