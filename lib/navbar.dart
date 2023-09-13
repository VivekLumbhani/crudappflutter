import 'package:crudapplication/models/user.dart';
import 'package:crudapplication/screens/home/admin.dart';
import 'package:crudapplication/screens/home/home.dart';
import 'package:crudapplication/screens/home/journeydet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class navbar extends StatelessWidget {
  final String email;

  const navbar({required this.email});

  @override
  Widget build(BuildContext context) {
    bool isAdmin = email == 'admin@gmail.com';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Row(
              children: [
                Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  "Welcome,",
                  style: TextStyle(fontSize: 30),
                ),
              ],
            ),
            accountEmail: Row(
              children: [
                SizedBox(width: 30),
                Text(
                  email as String,
                  style: TextStyle(fontSize: 25),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.pink,
              // image: DecorationImage(image: AssetImage('images/nav.jpg'),fit: BoxFit.cover )
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => home()),
              );
            },
          ),

          if (isAdmin)
            ListTile(
              leading: Icon(Icons.person),
              title: Text('admin'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => admin()),
                );
              },
            ),

          ListTile(
            leading: Icon(Icons.route),
            title: Text('my Journey'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => journeydet()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sign out'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          )

        ],
      ),
    );
  }
}
