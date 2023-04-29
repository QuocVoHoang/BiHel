// ignore_for_file: avoid_print

import 'dart:async';

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
    BluetoothService services,
    int red,
    int green,
    int blue,
    int animationInt,
  ) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
        ),
        child: const Text('SUBMIT'),
        onPressed: () async {
          print(
              '${myColor.red} ${myColor.green} ${myColor.blue} $animationInt');
          services.characteristics[0].write(
            [red, green, blue, animationInt],
            withoutResponse: true,
          );
        },
      ),
    );
  }

  bool isDiscovered = true;
  Color myColor = Colors.blue;
  int animationInt = 0;

  //for animation
  int colorIndex = 0;
  bool animationOn = false;

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
            child: const Text("REFRESH DEVICE"),
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
                height: screenHeight * 0.06,
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
                height: screenHeight * 0.82,
                width: double.infinity,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 438,
                      child: ColorPicker(
                        enableAlpha: false,
                        pickerColor: myColor,
                        onColorChanged: (color) => setState(() {
                          myColor = color;
                        }),
                      ),
                    ),
                    Container(
                      height: 210,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (animationInt == 0)
                                  ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      myColor,
                                      BlendMode.modulate,
                                    ),
                                    child: Image.asset(
                                      'assets/images/slide animation.gif',
                                    ),
                                  ),
                                if (animationInt == 1)
                                  ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      myColor,
                                      BlendMode.modulate,
                                    ),
                                    child: Image.asset(
                                      'assets/images/blink animation.gif',
                                    ),
                                  ),
                                if (animationInt == 2)
                                  ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      myColor,
                                      BlendMode.modulate,
                                    ),
                                    child: Image.asset(
                                      'assets/images/accumulate animation.gif',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              animationButton(
                                //slide
                                animaInt: 0,
                                image: Image.asset(
                                  'assets/images/slide.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                              animationButton(
                                //blink
                                animaInt: 1,
                                image: Image.asset(
                                  'assets/images/blink.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                              animationButton(
                                //accumulate
                                animaInt: 2,
                                image: Image.asset(
                                  'assets/images/accumulate.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                            animationInt,
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

  Widget animationButton({
    required int animaInt,
    required Image image,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 10, left: 10, top: 5),
      height: 50,
      width: animationInt == animaInt ? 100 : 70,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: animationInt == animaInt
              ? const Color.fromARGB(255, 36, 141, 39)
              : Colors.grey,
        ),
        onPressed: () {
          setState(() {
            animationInt = animaInt;
            // animationOn = true;
            if (animationInt == 1) {
              allBlink = true;
            } else {
              allBlink = false;
            }
          });
          // animationTurningOn();
        },
        child: image,
      ),
    );
  }

  bool allBlink = false;
  Widget animationWidget({
    required int animationIndex,
  }) {
    return Container(
      height: 100,
      width: 20,
      decoration: BoxDecoration(
        color:
            colorIndex == animationIndex || allBlink ? myColor : Colors.white,
        border: Border.all(),
      ),
    );
  }

  int counter = 0;
  int limitCounter = 7;
  void animationTurningOn() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // slide animation
      if (animationInt == 0) {
        setState(() {
          colorIndex++;
          print(colorIndex);
        });
        if (colorIndex > 7) {
          colorIndex = 0;
          setState(() {
            // animationOn = false;
            counter++;
          });
          if (counter == 3) {
            counter = 0;
            colorIndex = 0;
            timer.cancel();
          }
        }
      }
      // blink animation
      if (animationInt == 1) {
        setState(() {
          allBlink = !allBlink;
          counter++;
        });
        if (counter == 20) {
          counter = 0;
          allBlink = false;
          timer.cancel();
        }
      }
      // accumulate animation
      if (animationInt == 2) {
        setState(() {
          colorIndex++;
          print(colorIndex);
        });
        if (colorIndex > limitCounter) {
          colorIndex = 0;
          limitCounter -= limitCounter;
          setState(() {
            // animationOn = false;
            counter++;
          });
          if (counter == 3) {
            counter = 0;
            colorIndex = 0;
            timer.cancel();
          }
        }
      }
    });
  }
}
