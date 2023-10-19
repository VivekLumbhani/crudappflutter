import 'package:flutter/material.dart';
import 'package:crudapplication/services/auth.dart';
class register extends StatefulWidget {
  @override
  State<register> createState() => _registerState();
}
class _registerState extends State<register> {
  final AuthService _auth = AuthService();
  final _formkey = GlobalKey<FormState>();
  String user = '';
  String pass = '';
  String error ='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Register'), elevation: 0),
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
                  if (val == null || val.length<6) {
                    return 'Enter email';
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() {
                    user = val;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(hintText: 'Enter Password', hintStyle: TextStyle(color: Colors.grey), fillColor: Colors.grey[300], filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none,),),
                validator: (val) {
                  if (val == null || val.length < 6) {
                    return 'Enter at least 6 characters';
                  }
                  return null;
                },
                obscureText: true,
                onChanged: (val) {
                  pass = val;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formkey.currentState != null && _formkey.currentState!.validate()) {
                    dynamic result=await _auth.register(user, pass);
                    if(result==null){
                      setState(() {
                        error='not regitsterd';
                      });
                    }else{
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text('Register'),
              ),
              Text(error,style: TextStyle(color: Colors.red,fontSize: 14),)
            ],
          ),
        ),
      ),
    );
  }
}
