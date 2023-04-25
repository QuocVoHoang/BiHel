// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// ignore: must_be_immutable
class SendDataButton extends StatelessWidget {
  String text;
  BluetoothService bluetoothService;
  int red;
  int green;
  int blue;


  SendDataButton({
    Key? key,
    required this.text,
    required this.bluetoothService,
    required this.red,
    required this.green,
    required this.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 100,
      child: ElevatedButton(
        onPressed: () {
          print('$red $green $blue');
          bluetoothService.characteristics[0].write([red, green, blue]);
        },
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

void showMyDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Center(
      child: Container(
        margin: const EdgeInsets.only(right: 10, left: 10),
        width: double.infinity,
        height: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    ),
  );
}

class CommonButtons extends StatelessWidget {
  const CommonButtons({
    Key? key,
    required this.textLabel,
    required this.textColor,
    required this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  final String textLabel;
  final Color textColor;
  final Color backgroundColor;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        elevation: 5,
        backgroundColor: backgroundColor,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 6,
        ),
        child: Text(
          textLabel,
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
    );
  }
}
