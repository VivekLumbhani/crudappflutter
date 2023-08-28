import 'package:crudapplication/navbar.dart';
import 'package:crudapplication/screens/home/bookseat.dart';
import 'package:crudapplication/screens/home/journeydet.dart';
import 'package:flutter/material.dart';
import 'package:crudapplication/models/user.dart';
import 'package:crudapplication/services/auth.dart';
import 'package:intl/intl.dart';
import 'admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class home extends StatelessWidget {
  final User user;

  home({required this.user});
  // bool isAdmin = user.email == 'noone@gmail.com';


  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Home'),
          centerTitle: true,
          actions: <Widget>[

            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => journeydet(user: user)),);

              },
              label: Text('My Journey det'),
              icon: Icon(Icons.map),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                _auth.signout();
              },
              label: Text('Sign Out'),
              icon: Icon(Icons.person),
            ),
            Row(
              children: <Widget>[
                SizedBox(height: 20,),

                ElevatedButton(onPressed: (){
                  Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => admin(user: user)),);
                }, child: Text('seatui'))

              ],
            )
          ],
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


                // Check if the trip date is before the current date
                if (tripDate.isAfter(currentDate)) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => BusBookingPage(username: user,number:seats,busname: documentIds[index])),
                      );
                    },
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
                  );
                } else {
                  return Container(); // Don't show cards for future trips
                }

              },

            );

          },
        ),
      ),
    );
  }
}
