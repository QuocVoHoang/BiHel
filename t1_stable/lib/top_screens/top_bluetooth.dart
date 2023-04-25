import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../screens/bluetooth/bluetooth_off_screen.dart';
import '../screens/bluetooth/find_device_screen.dart';

class TopBluetooth extends StatelessWidget {
  const TopBluetooth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
      stream: FlutterBluePlus.instance.state,
      initialData: BluetoothState.unknown,
      builder: (c, snapshot) {
        final state = snapshot.data;
        if (state == BluetoothState.on) {
          return const FindDevicesScreen();
        }
        return BluetoothOffScreen(state: state);
      },
    );
  }
}
