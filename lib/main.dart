import 'package:crudapplication/screens/wrapper.dart';
import 'package:crudapplication/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/user.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAuU92bN1G9FcLPOv7n0QTLfcRsOR9jQLw",
      appId: "1:218901491224:android:5024eb25ef428022105d6d",
      messagingSenderId: "218901491224",
      projectId: "crudapplication-7b905",
      databaseURL: 'https://crudapplication-7b905-default-rtdb.firebaseio.com'
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>(
      initialData: null, // Provide the initial data here
      create: (context) => AuthService().user,
      child: MaterialApp(
        home: wrapper(),
      ),
    );
  }
}
