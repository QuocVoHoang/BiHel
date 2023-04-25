import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../top_screens/top_login.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);
  final BluetoothState? state;
  @override
  Widget build(BuildContext context) {
    Future<bool?> showPopDialog({
      required BuildContext context,
      required String message,
    }) =>
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('NO'),
              ),
              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TopLogin(),
                    ),
                  );
                },
                child: const Text('YES'),
              ),
            ],
          ),
        );

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showPopDialog(
            context: context, message: 'Do you want to sign out?');
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[600],
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bluetooth_disabled,
                size: 200.0,
                color: Colors.white54,
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Text(
                  'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                height: 70,
                width: 250,
                margin: const EdgeInsets.only(top: 50),
                child: ElevatedButton(
                  child: const Text(
                    'TURN ON',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 13, 72, 120),
                  ),
                  onPressed: Platform.isAndroid
                      ? () => FlutterBluePlus.instance.turnOn()
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
