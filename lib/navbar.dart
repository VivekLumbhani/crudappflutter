import 'package:crudapplication/models/user.dart';
import 'package:crudapplication/screens/home/admin.dart';
import 'package:crudapplication/screens/home/home.dart';
import 'package:crudapplication/screens/home/journeydet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class navbar extends StatelessWidget {
  final String email;

  const navbar({required this.email});

  Future<void> showFeedbackDialog(BuildContext context) async {
    double rating = 0;
    String feedback = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 40,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                ),
                onChanged: (value) {
                  feedback = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = email == 'vivek@gmail.com' || email=='kruti@gmail.com';

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
            leading: Icon(Icons.feedback),
            title: Text('Feedback'),
            onTap: () {
              showFeedbackDialog(context);
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
