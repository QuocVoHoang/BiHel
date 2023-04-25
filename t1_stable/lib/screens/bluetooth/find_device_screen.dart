// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/screens/bluetooth/device_screen.dart';
import 'package:flutter_blue_plus_example/top_screens/top_login.dart';

import '../../helpers/widgets.dart';

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          title: const Text(
            'Find device screen',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  RefreshIndicator(
                    onRefresh: () => FlutterBluePlus.instance
                        .startScan(timeout: const Duration(seconds: 4)),
                    child: StreamBuilder<List<ScanResult>>(
                      stream: FlutterBluePlus.instance.scanResults,
                      initialData:  const [],
                      builder: (c, snapshot) => Column(
                        children: snapshot.data!
                            .map(
                              (r) => ScanResultTile(
                                result: r,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DeviceScreen(device: r.device),
                                    ),
                                  );
                                  r.device.discoverServices();
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                  child: InkWell(
                    splashColor: Colors.orange,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color.fromARGB(255, 244, 230, 190),
                      ),
                      width: 220,
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Text('Turn off bluetooth'),
                          Icon(Icons.bluetooth_disabled),
                        ],
                      ),
                    ),
                    onTap: () => FlutterBluePlus.instance.turnOff(),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: FlutterBluePlus.instance.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data!) {
              return FloatingActionButton.extended(
                icon: const Icon(Icons.stop),
                label: const Text('Stop scan'),
                onPressed: () => FlutterBluePlus.instance.stopScan(),
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton.extended(
                icon: const Icon(Icons.search),
                label: const Text('Start scan'),
                onPressed: () => FlutterBluePlus.instance.startScan(
                  timeout: const Duration(seconds: 4),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
