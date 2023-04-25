import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_example/helpers/clicky_button.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('text'),
      ),
      body: Center(
        child: Container(
          height: 300,
          width: 300,
          alignment: Alignment.center,
          color: Colors.grey,
          child: ClickyButton(
              child: const Text('delete'), color: Colors.red, onPressed: () {}),
        ),
      ),
    );
  }
}
