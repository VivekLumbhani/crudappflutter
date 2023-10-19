import 'package:crudapplication/navbar.dart';
import 'package:crudapplication/screens/home/bookseat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crudapplication/services/auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class home extends StatelessWidget {
  home();
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    var username=FirebaseAuth.instance.currentUser;
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      home: Scaffold(
        drawer: navbar(email: username!.email.toString()),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Home'),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('buscollections').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator(); // Loading indicator
            }
            var itemList = snapshot.data!.docs;
            List<String> documentIds = itemList.map((doc) => doc.id).toList();
            return ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                var busData = itemList[index].data() as Map<String, dynamic>;
                String busName = busData['busName'] ?? 'Unknown Bus';
                String date = busData['date'] ?? '12/12/2023';
                String acType = busData['acType'] == "1" ? 'AC' : 'Non-AC';
                String departureTime = busData['departureTime'] ?? 'N/A';
                String departurePlace = busData['departurePlace'] ?? 'N/A';
                String destinationTime = busData['destinationTime'] ?? 'N/A';
                String destinationPlace = busData['destinationPlace'] ?? 'N/A';
                String price = busData['price'] ?? 'N/A';
                int seats = busData['seats'] ?? 'N/A';
                DateTime tripDate = DateTime.parse(date);
                DateTime currentDate = DateTime.now();

                if (tripDate.isAfter(currentDate)) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => BusBookingPage(username: username!.email.toString(),number:seats,busname: documentIds[index],price: price,)),
                      );
                    },
                    child: SingleChildScrollView(
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    busName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    acType,
                                    style: TextStyle(
                                      color: acType == 'AC' ? Colors.blue : Colors.orange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.access_time),
                                  SizedBox(width: 5),
                                  Column(
                                    children: [
                                      Text(departureTime),
                                      Text(departurePlace),
                                    ],
                                  ),
                                  Icon(Icons.arrow_forward),
                                  Column(
                                    children: [
                                      Text(destinationTime),
                                      Text(destinationPlace),
                                    ],
                                  ),
                                  SizedBox(width: 5),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Date: ${DateFormat('MMM d, y').format(tripDate)}, Price: $price',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
