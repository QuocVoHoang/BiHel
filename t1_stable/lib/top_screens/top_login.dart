import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_example/top_screens/top_bluetooth.dart';

import '../screens/auth/login_screen.dart';

class TopLogin extends StatefulWidget {
  const TopLogin({Key? key}) : super(key: key);

  @override
  State<TopLogin> createState() => _TopLoginState();
}

class _TopLoginState extends State<TopLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('waiting');
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          } else if (snapshot.hasData) {
            return const TopBluetooth();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
