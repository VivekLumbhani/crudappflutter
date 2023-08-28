import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudapplication/models/user.dart';
import 'package:flutter/material.dart';
import 'package:crudapplication/services/auth.dart';
import 'package:crudapplication/screens/home/admin.dart';
import 'package:crudapplication/screens/home/home.dart';

class journeydet extends StatelessWidget {
  final User user;

  journeydet({required this.user});

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        drawer: Drawer(
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
                      user.email,
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
                    MaterialPageRoute(builder: (context) => home(user: user)),
                  );
                },
              ),

              // if (isAdmin)
              ListTile(
                leading: Icon(Icons.person),
                title: Text('admin'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => admin(user: user)),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.route),
                title: Text('my Journey'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => journeydet(user: user)),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign out'),
                onTap: () {
                  _auth.signout();
                },
              ),
            ],
          ),
        ),

        appBar: AppBar(
          title: Text('Journey detail'),
          centerTitle: true,
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => home(user: user)),
                );
              },
              label: Text('Home'),
              icon: Icon(Icons.home),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _auth.signout();
              },
              label: Text('Sign Out'),
              icon: Icon(Icons.person),
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('journeydetail')
              .where('email', isEqualTo: user.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator(); // Loading indicator
            }

            var itemList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                var journeyData = itemList[index].data() as Map<String, dynamic>;
                String busName = journeyData['busname'] ?? 'Unknown Bus';
                String seatsBooked = journeyData['seats'] ?? 'Unknown seats';

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('buscollections')
                      .doc(busName) // Use busName directly as the document ID
                      .get(),
                  builder: (context, documentSnapshot) {
                    if (documentSnapshot.connectionState == ConnectionState.waiting) {
                      // print('Waiting for query to complete...');
                      return CircularProgressIndicator();
                    }

                    if (!documentSnapshot.hasData || !documentSnapshot.data!.exists) {
                      // print('No data or document not found for busName: $busName');
                      return SizedBox.shrink();
                    }

                    var busData = documentSnapshot.data!.data() as Map<String, dynamic>;
                    var busoriname = busData['busName'];
                    var dateof = busData['date'];
                    var departurePlace = busData['departurePlace'];
                    var destinationPlace = busData['destinationPlace'];
                    var departureTime = busData['departureTime'];
                    String combinedDateTime = '$dateof $departureTime'; // Combine date and time
                    // DateTime parsedDateTime = DateTime.parse(combinedDateTime); // Parse combined date and time
                    // print('parsed is $parsedDateTime');
                    // if(DateTime.now().isAfter(parsedDateTime)){}
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: ListTile(
                        title: Text('Bus Name: $busoriname'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Seats Booked: ${jsonDecode(seatsBooked)}'),
                            Row(
                              children: [

                                Text('Journey: $departurePlace',style:TextStyle(fontSize: 16) ,),
                                Icon(Icons.arrow_forward),
                                Text(destinationPlace,style:TextStyle(fontSize: 16) ),
                              ],
                            ),
                            Text('Date : $dateof'),
                            Text('Departure Time: $departureTime'),
                          ],
                        ),
                        trailing: ElevatedButton(onPressed: (){
                          showDialog(context: context,
                            builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: Text('Confirmation'),
                              content: Text('Are you sure you want to cancel your ticket fully?'),
                              actions: [
                                ElevatedButton(onPressed: () async {
                                  QuerySnapshot<Map<String, dynamic>> queryupdate = await FirebaseFirestore.instance
                                      .collection('allseatsrecord')
                                      .where('busname', isEqualTo: busName)
                                      .get();

                                  for (QueryDocumentSnapshot documentSnapshot in queryupdate.docs) {
                                    var existingDoc = documentSnapshot.data() as Map<String, dynamic>?;

                                    if (existingDoc != null) {
                                      var seatsString = existingDoc['seats'] as String; // Retrieve seats as a string
                                      var allseats = List<int>.from(jsonDecode(seatsString) as List<dynamic>);
                                      var userseats = List<int>.from(jsonDecode(seatsBooked));

                                      allseats.removeWhere((seat) => userseats.contains(seat));

                                      await documentSnapshot.reference.update({'seats': allseats.toString()}); // Store updated seats as a string
                                    }
                                  }



                                  QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
                                      .collection('journeydetail')
                                      .where('busname', isEqualTo: busName)
                                      .where('email', isEqualTo: user.email)
                                      .get();

                                  for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
                                    await documentSnapshot.reference.delete();
                                  }
                                  Navigator.of(dialogContext).pop();
                                  print('yes $busoriname');
                                },
                                  child: Text('Yes'),
                                ),
                                ElevatedButton(onPressed: (){Navigator.of(dialogContext).pop();}, child: Text('No'))
                              ],
                            );
                          }
                          );
                        }, child: Text('Cancel my ticket fully')),
                      ),
                    );

                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
