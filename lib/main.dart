import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/home/categories_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/cart/cart_provider.dart';
import 'screens/home/products_screen.dart';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
   await Firebase.initializeApp(
      options: const FirebaseOptions(apiKey: "AIzaSyBM_TGJmuGsgqbsDN-4A_vu0jlvATNjelE",
          authDomain: "e-shopping-799fc.firebaseapp.com",
          projectId: "e-shopping-799fc",
          storageBucket: "e-shopping-799fc.firebasestorage.app",
          messagingSenderId: "698952744650",
          appId: "1:698952744650:web:c9e5368809c0a45ada7e33"));
       }
  else {
    await Firebase.initializeApp();
  }


  runApp( MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Shopping',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: LoginScreen(), // Start with the home screen
    );
  }
}