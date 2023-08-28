import 'dart:convert';

import 'package:crudapplication/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class BusBookingPage extends StatefulWidget {
  final username;
  final int number;
  final busname;
  BusBookingPage({required this.username, required this.number, required this.busname});
  @override
  _BusBookingPageState createState() => _BusBookingPageState();
}

class _BusBookingPageState extends State<BusBookingPage> {
  List<bool> seatAvailability = List.generate(30, (index) => true);
  List<int> selectedSeats = [];
  int numberOfSeats = 0;
  String busname = '';
  String user = '';

  @override
  void initState() {
    super.initState();
    numberOfSeats = widget.number;
    busname = widget.busname;
    // user=widget.username;
    print('number of seats $numberOfSeats and name is $busname ${widget.username.email}');
  }

  void _toggleSeatSelection(int index) {
    setState(() {
      if (index <= numberOfSeats) {
        int calculatedIndex = index - 1; // Adjust for 0-based indexing
        if (seatAvailability[calculatedIndex]) {
          if (selectedSeats.contains(calculatedIndex)) {
            selectedSeats.remove(calculatedIndex);
          } else {
            selectedSeats.add(calculatedIndex);
          }
        }
      }
    });
  }

  Color _getSeatColor(int index) {
    if (selectedSeats.contains(index)) {
      return Colors.blue;
    } else if (!seatAvailability[index]) {
      return Colors.grey;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Booking'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => home(user: widget.username)),
              );
            },
            child: Text('Home'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('allseatsrecord')
            .where('busname', isEqualTo: busname)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return CircularProgressIndicator();
          }

          var itemList = snapshot.data!.docs;
          var seatsData = itemList.first['seats'];
          List<dynamic> strtoarr=jsonDecode(seatsData);
          print('seatsData type: ${strtoarr.runtimeType} and seats are $strtoarr');


          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Select Your Seats',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < numberOfSeats; i++)
                        Column(
                          children: [
                            for (int j = 0; j < 6; j++)
                              if (i * 6 + j < numberOfSeats)
                                GestureDetector(
                                  onTap: () {
                                    int seatNumber = i * 6 + j + 1;
                                    if (strtoarr.contains(seatNumber)) {

                                    } else {
                                      _toggleSeatSelection(seatNumber);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: strtoarr.contains(i * 6 + j + 1) ? Colors.grey : _getSeatColor(i * 6 + j),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          (i * 6 + j + 1).toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedSeats.isEmpty
                        ? null
                        : () async {
                      //to add seats details about users journey
                      var finalseats=selectedSeats.map((seat) => seat + 1).toList();
                      // Check if the document with the email exists in Firestore
                      var querySnapshotForCheck = await FirebaseFirestore.instance
                          .collection('journeydetail')
                          .where('email', isEqualTo: widget.username.email)
                          .where('busname',isEqualTo:widget.busname)
                          .get();

                      if (querySnapshotForCheck.docs.isNotEmpty) {
                        var existingDoc = querySnapshotForCheck.docs.first;

                        // Convert the existing seats string to a list
                        var existingSeats = <int>[];
                        if (existingDoc['seats'] != null) {
                          try {
                            existingSeats = (jsonDecode(existingDoc['seats']) as List<dynamic>).cast<int>();
                          } catch (e) {
                            // Handle JSON decoding error
                            print('Error decoding existing seats: $e');
                          }
                        }

                        print('Existing seats: $existingSeats, New seats: $selectedSeats');

                        // Modify the existing seats list and add new seats
                        var updatedSeats = List<int>.from(existingSeats);
                        updatedSeats.addAll(selectedSeats.map((seat) => seat + 1));

                        // Update the document with the updated seats array
                        await existingDoc.reference.update({'seats': jsonEncode(updatedSeats)});
                      }

                      else {
                         var str = jsonEncode(selectedSeats.map((seat) => seat + 1).toList());

                        await FirebaseFirestore.instance.collection('journeydetail').add({
                          'seats': str,
                          'busname': busname,
                          'email': widget.username.email,
                        });
                      }




                      // Retrieving seat information from the 'allseatsrecord' collection
                      var snapshot = await FirebaseFirestore.instance
                          .collection('allseatsrecord')
                          .where('busname', isEqualTo: busname)
                          .get();

                      var itemList = snapshot.docs;
                      var seatsData = itemList.first['seats'];
                      List<dynamic> seattype = jsonDecode(seatsData);

                      print('seatsData type: ${seattype.runtimeType}');
                      print('seatsData content: $seattype');
                      var newseatlist=seattype+finalseats;
                      print('seats that are booked + $newseatlist ');



                      // to update new added seats bookeed detail in db
                      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                          .collection('allseatsrecord')
                          .where('busname', isEqualTo: busname)
                          .get();

                      if (querySnapshot.docs.isEmpty) {
                        print(' new');

                        // No document with the matching busname exists, so create a new one
                        await FirebaseFirestore.instance.collection('allseatsrecord').add({
                          'seats': newseatlist,
                          'busname': busname,
                        });

                        print("New document created for busname: $busname");
                      } else {
                        // Documents with the matching busname exist, update the seats
                        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
                          DocumentReference docRef = documentSnapshot.reference;
                          print('not new');
                          await docRef.update({

                            'seats': newseatlist.toString(),
                          });
                        }

                        print("Seats data updated for busname: $busname");
                      }

                      // FirebaseFirestore.instance.collection('allseatsrecord').add({
                      //   'seats': '$newseatlist',
                      //   'busname': '$busname'
                      // });

                      print(
                          'selected seats are $selectedSeats and name is $busname user is ${widget.username.email} ');
                    },
                    child: Text('Book Selected Seats'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
