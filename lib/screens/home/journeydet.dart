import 'dart:convert';
import 'package:crudapplication/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class journeydet extends StatelessWidget {

  journeydet();

  @override
  Widget build(BuildContext context) {

    final username=FirebaseAuth.instance.currentUser;

    return MaterialApp(
      home: Scaffold(
        drawer:navbar(email: username!.email.toString()),

        appBar: AppBar(
          title: Text('Journey detail'),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('journeydetail')
              .where('email', isEqualTo: username!.email.toString())
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
                      .doc(busName)
                      .get(),
                  builder: (context, documentSnapshot) {
                    if (documentSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (!documentSnapshot.hasData || !documentSnapshot.data!.exists) {
                      return SizedBox.shrink();
                    }
                    var busData = documentSnapshot.data!.data() as Map<String, dynamic>;
                    var busoriname = busData['busName'];
                    var dateof = busData['date'];
                    var departurePlace = busData['departurePlace'];
                    var destinationPlace = busData['destinationPlace'];
                    var departureTime = busData['departureTime'];
                    String combinedDateTime = '$dateof $departureTime'; // Combine date and time
                     return SingleChildScrollView(
                      child: Card(
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
                                  Expanded(
                                      child:Text('Journey: $departurePlace',style:TextStyle(fontSize: 16) ,),
                                  ),
                                  Icon(Icons.arrow_forward),
                                    Expanded(
                                      child: Text(destinationPlace,style:TextStyle(fontSize: 16) ),
                                    )
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
                                        .where('email', isEqualTo: username!.email.toString())
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
