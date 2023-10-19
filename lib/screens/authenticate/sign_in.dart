import 'package:crudapplication/screens/authenticate/register.dart';
import 'package:crudapplication/screens/home/home.dart';
import 'package:crudapplication/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:crudapplication/shared/constants.dart';
class sigin extends StatefulWidget {

  final Function toggle;
  sigin({required this.toggle});

  @override
  State<sigin> createState() => _siginState();
}

class _siginState extends State<sigin> {
  final AuthService _auth = AuthService();
  final _formkey = GlobalKey<FormState>();
  String error='';
  String user = '';
  String pass = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sign In'),
        elevation: 0,
        actions: <Widget>[
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => register()),
              );
            },
            label: Text('Register'),
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
          key: _formkey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              TextFormField(
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(hintText: 'Enter Email',hintStyle: TextStyle(color: Colors.grey), fillColor: Colors.grey[300], filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none,),),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Enter email';
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() {
                    user = val;
                  });
                },
              ),              SizedBox(height: 20),
              TextFormField(
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(hintText: 'Enter Password', hintStyle: TextStyle(color: Colors.grey), fillColor: Colors.grey[300], filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none,),),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Enter password';
                  }
                  return null;
                },
                obscureText: true,
                onChanged: (val) {
                  pass = val;
                },
              ),              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formkey.currentState != null && _formkey.currentState!.validate()) {
                    dynamic result=await _auth.siginemailpass(user, pass);
                    if(result==null){
                      setState(() {
                        error='wrong email or password';
                      });
                    }else{
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => home(user)),
                      // );
                    }

                  }
                },
                child: Text('LogIn'),
              ),
              SizedBox(height: 20,),
              Text(error,style: TextStyle(color: Colors.red,fontSize: 14),)
            ],
          ),
        ),
      ),
    );
  }
}
