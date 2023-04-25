// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../helpers/my_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmedPasswordController = TextEditingController();

  bool passwordShow1 = true;
  bool passwordShow2 = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmedPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 65, 71),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 19, 65, 71),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Create an Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: myBody(height),
    );
  }

  Widget myBody(var height) {
    return SingleChildScrollView(
      child: Container(
        height: height * 0.9,
        margin: const EdgeInsets.only(right: 10, left: 10),
        child: Column(
          children: [
            Container(
              height: 100,
              margin: const EdgeInsets.only(top: 50, bottom: 10),
              child: Image.asset(
                'assets/images/add.png',
                scale: 0.75,
                color: const Color.fromARGB(255, 221, 190, 147),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              cursorColor: Colors.white,
              obscureText: passwordShow1,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      passwordShow1 = !passwordShow1;
                    });
                  },
                  icon: Icon(
                    passwordShow1 ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: confirmedPasswordController,
              keyboardType: TextInputType.visiblePassword,
              cursorColor: Colors.white,
              obscureText: passwordShow2,
              textInputAction: TextInputAction.done,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Re-enter password',
                labelStyle: const TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      passwordShow2 = !passwordShow2;
                    });
                  },
                  icon: Icon(
                    passwordShow2 ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 20),
              width: 250,
              height: 70,
              child: ElevatedButton(
                onPressed: () {
                  signUp();
                },
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    color: Color.fromARGB(255, 19, 65, 71),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 221, 190, 147),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
            SizedBox(
              width: double.infinity,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/city.png',
                ),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }

  Future<void> signUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (error) {
      String message = error.toString();
      showMyDialog(
        context,
        message.substring(message.indexOf(']') + 2),
      );
      print(error);
    }
    print(FirebaseAuth.instance.currentUser!.email!);

    if (FirebaseAuth.instance.currentUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 1),
          content: Center(child: Text("ACCOUNT CREATED")),
        ),
      );
    }
  }
}
