import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/screens/auth/edit_user_information_screen.dart';
import 'package:flutter_blue_plus_example/screens/map/record_screen.dart';

import '../top_screens/top_login.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItems(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 30, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            border: const Border(
              bottom: BorderSide(
                color: Color.fromARGB(85, 0, 0, 0),
              ),
            ),
          ),
          child: Column(
            children: [
              user!.photoURL == null
                  ? const CircleAvatar(
                      radius: 52,
                      backgroundImage:
                          AssetImage('assets/images/anonymous-user.png'),
                    )
                  : CircleAvatar(
                      radius: 52,
                      backgroundImage: NetworkImage('${user!.photoURL}'),
                    ),
              const SizedBox(height: 12),
              Text(
                user!.displayName == null ? 'NO NAME' : '${user?.displayName}',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                '${user?.email}',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Bihel customization'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.map),
          title: const Text('Your records'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecordScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('User information'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditUserInformationScreen(),
              ),
            );
          },
        ),
        const Divider(color: Color.fromARGB(85, 0, 0, 0)),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sign out'),
          onTap: () {
            Navigator.pop(context);
            FirebaseAuth.instance.signOut();
            widget.device.disconnect();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TopLogin(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class SubSideDrawer extends StatelessWidget {
  const SubSideDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
