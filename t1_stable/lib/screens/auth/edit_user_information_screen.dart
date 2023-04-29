// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus_example/helpers/constant.dart';
import 'package:image_picker/image_picker.dart';

import '../tool/select_photo_options_screen.dart';

class EditUserInformationScreen extends StatefulWidget {
  const EditUserInformationScreen({Key? key}) : super(key: key);

  @override
  State<EditUserInformationScreen> createState() =>
      _EditUserInformationScreenState();
}

class _EditUserInformationScreenState extends State<EditUserInformationScreen> {
  TextEditingController displayNameController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  String? userName;

  File? _image;
  String imageUrl = '';

  bool loading = false;

  @override
  void initState() {
    setState(() {
      userName = user!.displayName;
    });
    super.initState();
  }

  @override
  void dispose() {
    displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Edit user information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Email: '),
                      Text(
                        '${user!.email}',
                      ),
                      const Text(''),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('User name: '),
                      Text(
                        user!.displayName != null ? '$userName' : 'NO NAME',
                      ),
                      IconButton(
                        onPressed: () {
                          changeUserName();
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('User avatar: '),
                    ],
                  ),
                ),
                Container(
                  height: 380,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  padding: const EdgeInsets.only(right: 20, left: 20),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          height: 280,
                          width: 300,
                          child: _image == null
                              ? CircleAvatar(
                                  backgroundImage: user!.photoURL == null
                                      ? NetworkImage(anonymousImage)
                                      : NetworkImage('${user!.photoURL}'),
                                )
                              : CircleAvatar(
                                  backgroundImage: FileImage(_image!),
                                ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 78),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.grey,
                          ),
                          height: 50,
                          width: 50,
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showSelectPhotoOptions(context);
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _image != null,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            height: 50,
                            width: 200,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });

                                if (user!.photoURL != null) {
                                  await FirebaseStorage.instance
                                      .refFromURL('${user!.photoURL}')
                                      .delete();
                                }

                                String uniqueFileName = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                Reference referenceRoot =
                                    FirebaseStorage.instance.ref();
                                Reference referenceDirImages =
                                    referenceRoot.child('avatar');
                                Reference referenceImageToUpload =
                                    referenceDirImages.child(uniqueFileName);

                                try {
                                  await referenceImageToUpload
                                      .putFile(File(_image!.path));
                                  imageUrl = await referenceImageToUpload
                                      .getDownloadURL();
                                } catch (e) {
                                  print(e);
                                }

                                print(imageUrl);

                                try {
                                  user!.updatePhotoURL(imageUrl);
                                } catch (error) {
                                  print(error);
                                }

                                Timer(const Duration(seconds: 2), () {
                                  setState(() {
                                    loading = false;
                                  });
                                });
                              },
                              child: const Text('Update avatar'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: loading,
            child: Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color.fromARGB(195, 118, 118, 118),
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 320,
                    right: 130,
                    bottom: 320,
                    left: 130,
                  ),
                  height: 100,
                  width: 100,
                  child: const CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changeUserName() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change user name'),
        actions: [
          TextFormField(
            controller: displayNameController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'User name',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                user!.updateDisplayName(displayNameController.text);
              } catch (error) {
                print(error);
              }
              setState(() {
                userName = displayNameController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Update name'),
          ),
        ],
      ),
    );
  }

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      File? img = File(image.path);

      String imagePath = image.path;
      print(imagePath);

      setState(() {
        _image = img;
        Navigator.of(context).pop();
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.28,
        maxChildSize: 0.4,
        minChildSize: 0.28,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: SelectPhotoOptionsScreen(
              onTap: _pickImage,
            ),
          );
        },
      ),
    );
  }
}
