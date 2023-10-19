import 'package:crudapplication/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class admin extends StatefulWidget {
  admin();

  @override
  State<admin> createState() => _AdminState();
}

class _AdminState extends State<admin> {
  final _formkey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd'); // Date format
  int selectedRadio = 0;
  final TextEditingController busname = TextEditingController();
  final TextEditingController selectedDateController = TextEditingController();
  final TextEditingController destinationplace = TextEditingController();
  final TextEditingController departureplace = TextEditingController();
  final TextEditingController departuretimecontrol = TextEditingController();
  final TextEditingController destinationtimecontrol = TextEditingController();
  final TextEditingController pricecontrol = TextEditingController();
  final TextEditingController seatscontrol = TextEditingController();
  final TextEditingController accontrol = TextEditingController();
  TimeOfDay _selectedDepartureTime = TimeOfDay.now();
  TimeOfDay _selectedDestinationTime = TimeOfDay.now();

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); // Choose your desired time format
    return format.format(dateTime);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedDateController.text = _dateFormat.format(selectedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isDepartureTime) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        if (isDepartureTime) {
          _selectedDepartureTime = selectedTime;
          departuretimecontrol.text = _formatTime(_selectedDepartureTime);
        } else {
          _selectedDestinationTime = selectedTime;
          destinationtimecontrol.text = _formatTime(_selectedDestinationTime);
        }
      });
    }
  }
  final username = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: navbar(email: username!.email.toString()),
      appBar: AppBar(title: Text('Admin Panel'), centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Bus Name'),
                  controller: busname,
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.length < 5) {
                      return 'Enter Bus Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Selected Date: ${_dateFormat.format(selectedDate)}'),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: Text('Select Date'),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: departureplace,
                  decoration: InputDecoration(labelText: 'Enter Departure Place Name'),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.length < 5) {
                      return 'Enter Departure Place Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Departure Time: ${_formatTime(_selectedDepartureTime)}'),
                    ElevatedButton(
                      onPressed: () {
                        _selectTime(context, true);
                      },
                      child: Text('Departure Time'),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: destinationplace,
                  decoration: InputDecoration(labelText: 'Enter Destination Place Name'),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.length < 6) {
                      return 'Enter Destination Place Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Destination Time: ${_formatTime(_selectedDestinationTime)}'),
                    ElevatedButton(
                      onPressed: () {
                        _selectTime(context, false); // Pass 'false' for destination time
                      },
                      child: Text('Destination Time'),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: pricecontrol,
                  decoration: InputDecoration(labelText: 'Enter Price'),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.length < 2) {
                      return 'Enter Price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                RadioListTile(
                  value: 1,
                  groupValue: selectedRadio,
                  onChanged: (val) {
                    setSelectedRadio(val as int);
                    accontrol.text = '$val';
                  },
                  title: Text('AC'),
                ),
                RadioListTile(
                  value: 2,
                  groupValue: selectedRadio,
                  onChanged: (val) {
                    setSelectedRadio(val as int);
                    accontrol.text = '$val';
                  },
                  title: Text('Non AC'),
                ),
                Text('Selected Option: $selectedRadio'),
                SizedBox(height: 20,),
                TextFormField(
                  controller: seatscontrol,
                  decoration: InputDecoration(labelText: 'Enter number of seats'),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Enter Seats';
                    }

                    int? numberOfSeats = int.tryParse(val);
                    if (numberOfSeats == null || numberOfSeats < 2 || numberOfSeats > 30) {
                      return 'Seats must be between 2 and 30';
                    }

                    return null;
                  },
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (_formkey.currentState != null && _formkey.currentState!.validate()) {
                      String busName = busname.text;
                      String departurePlace = departureplace.text;
                      String destinationPlace = destinationplace.text;
                      String price = pricecontrol.text;
                      String acType = accontrol.text;
                      int seats = int.parse(seatscontrol.text);
                      String date = selectedDateController.text;

                      // Convert selected times to a String format
                      String departureTime = _selectedDepartureTime.format(context); // Format to String
                      String destinationTime = _selectedDestinationTime.format(context); // Format to String

                      try {
                        var newDocRef = await FirebaseFirestore.instance.collection('buscollections').add({
                          'busName': busName,
                          'date': date,
                          'departurePlace': departurePlace,
                          'destinationPlace': destinationPlace,
                          'departureTime': departureTime, // Store the selected departure time as String
                          'destinationTime': destinationTime, // Store the selected destination time as String
                          'price': price,
                          'acType': acType,
                          'seats': seats,
                        });

                        String newDocId = newDocRef.id;
                        print('New document ID: $newDocId');
                        await FirebaseFirestore.instance.collection('allseatsrecord').add({
                          'busname': newDocId,
                          'seats': '[]',
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Data inserted successfully')),
                        );
                      } catch (e) {
                        print('Error inserting data: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error inserting data')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Validation failed')),
                      );
                    }
                  },
                  child: Text('Submit Bus details'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
