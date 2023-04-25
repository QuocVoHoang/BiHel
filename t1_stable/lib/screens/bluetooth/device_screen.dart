// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/screens/bluetooth/find_device_screen.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../helpers/side_drawer.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({
    Key? key,
    required this.device,
  }) : super(key: key);

  final BluetoothDevice device;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  @override
  void initState() {
    super.initState();
    widget.device.connect();
    setState(() {
      isDiscovered = true;
    });
  }

  Widget _buildServiceTiles(
      BluetoothService services, int red, int green, int blue) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
        ),
        child: const Text('SUBMIT'),
        onPressed: () async {
          print('${myColor.red} ${myColor.green} ${myColor.blue}');
          services.characteristics[0].write(
            [red, green, blue],
            withoutResponse: true,
          );
        },
      ),
    );
  }

  bool isDiscovered = true;
  Color myColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    isDiscovered
        ? Future.delayed(const Duration(seconds: 2), () {
            print("DiscoverService");
            widget.device.discoverServices();

            setState(() {
              isDiscovered = false; // <-- Code run after delay
            });
          })
        : null;

    final screenHeight = MediaQuery.of(context).size.height;

    Future<bool?> showDevicePopDialog() => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Disconnect device?',
              style: TextStyle(
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
                  widget.device.disconnect();
                  Navigator.pop(context, true);
                },
                child: const Text('YES'),
              ),
            ],
          ),
        );

    StreamBuilder discoveryServiceHandler = StreamBuilder<bool>(
      stream: widget.device.isDiscoveringServices,
      initialData: false,
      builder: (c, snapshot) => IndexedStack(
        index: snapshot.data! ? 1 : 0,
        children: [
          TextButton(
            child: const Text("REFRESH"),
            onPressed: () {
              print('REFRESH');
              widget.device.discoverServices();
            },
          ),
        ],
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDevicePopDialog();
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(178, 255, 255, 255),
        //
        drawer: SideDrawer(device: widget.device),
        //
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.blue,
          title: Text(
            widget.device.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            StreamBuilder<BluetoothDeviceState>(
              stream: widget.device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) {
                VoidCallback? onPressed;
                String text;
                switch (snapshot.data) {
                  case BluetoothDeviceState.connected:
                    onPressed = () {
                      widget.device.disconnect();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FindDevicesScreen(),
                        ),
                      );
                    };
                    text = 'DISCONNECT';
                    break;
                  default:
                    onPressed = null;
                    text = snapshot.data.toString().substring(21).toUpperCase();
                    break;
                }
                return TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .labelLarge
                        ?.copyWith(color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.08,
                child: StreamBuilder<BluetoothDeviceState>(
                  stream: widget.device.state,
                  initialData: BluetoothDeviceState.connecting,
                  builder: (c, snapshot) => ListTile(
                      title: Text(
                          'Device is ${snapshot.data.toString().split('.')[1]}'),
                      trailing: discoveryServiceHandler
                      //                 StreamBuilder<bool>(
                      //   stream: widget.device.isDiscoveringServices,
                      //   initialData: false,
                      //   builder: (c, snapshot) => IndexedStack(
                      //     index: snapshot.data! ? 1 : 0,
                      //     children: [
                      //       TextButton(
                      //         child: const Text("Refresh"),
                      //         onPressed: () {
                      //           print('REFRESH');
                      //           widget.device.discoverServices();
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // );
                      // ,
                      ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.7,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 500,
                      child: ColorPicker(
                        enableAlpha: false,
                        pickerColor: myColor,
                        onColorChanged: (color) => setState(() {
                          myColor = color;
                        }),
                      ),
                    ),
                    StreamBuilder<List<BluetoothService>>(
                      stream: widget.device.services,
                      initialData: const [],
                      builder: (c, snapshot) {
                        if (snapshot.data?.isEmpty == true ||
                            !snapshot.hasData ||
                            snapshot.hasError) {
                          return const CircularProgressIndicator();
                        } else {
                          return _buildServiceTiles(
                            snapshot.data![2],
                            myColor.red,
                            myColor.green,
                            myColor.blue,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
