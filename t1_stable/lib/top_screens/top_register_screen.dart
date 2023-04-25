import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_example/screens/auth/register_screen.dart';
import 'package:flutter_blue_plus_example/top_screens/top_bluetooth.dart';

class TopRegisterScreen extends StatefulWidget {
  const TopRegisterScreen({Key? key}) : super(key: key);

  @override
  State<TopRegisterScreen> createState() => _TopRegisterScreenState();
}

class _TopRegisterScreenState extends State<TopRegisterScreen> {
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
            return const RegisterScreen();
          }
        },
      ),
    );
  }
}
