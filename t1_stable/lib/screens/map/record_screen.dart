// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'my_map_screen.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({Key? key}) : super(key: key);

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final user = FirebaseAuth.instance.currentUser;

  double myTotalDistance = 0;
  List<double> myDistanceList = [];

  bool isCalculated = true;

  @override
  void initState() {
    updateTotalDistanceList();
    calcu();
    super.initState();
  }

  void calcu() {
    setState(() {
      isCalculated = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      calculateTotalDistance();
      setState(() {
        isCalculated = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> bihelDataStream = FirebaseFirestore.instance
        .collection('BihelData_${user!.email}')
        .orderBy('dateTime', descending: false)
        .snapshots(includeMetadataChanges: true);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 191, 194, 200),
      appBar: AppBar(
        title: const Text(
          'Your records',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color.fromARGB(255, 105, 111, 223),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          bool isCal = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyMapScreen(),
            ),
          );

          if (isCal) {
            updateTotalDistanceList();
            calcu();
            setState(() {
              isCal = false;
            });
          }
        },
        backgroundColor: const Color.fromARGB(255, 105, 111, 223),
        icon: const Icon(Icons.play_arrow, size: 25),
        label: const Text('Run'),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          //top design
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 105, 111, 223),
                    // color: Colors.amber,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Center(
                    child: Container(
                      width: width,
                      height: 120,
                      margin: const EdgeInsets.only(left: 40, right: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Total Distance:   '),
                            Text(
                              '${myTotalDistance.toStringAsFixed(2)} km',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Color.fromARGB(255, 105, 111, 223),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          //
          SizedBox(
            height: height - height * 0.1 - 150,
            child: StreamBuilder<QuerySnapshot>(
              stream: bihelDataStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasError) {
                  return Text('Something went wrong! ${streamSnapshot.error}');
                } else if (streamSnapshot.hasData) {
                  return ListView.builder(
                      itemCount: streamSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot documentSnapshot =
                            streamSnapshot.data!.docs[index];
                        return myRecordItem(
                          date: documentSnapshot['date'],
                          averageSpeed: documentSnapshot['averageSpeed'],
                          totalDistance: documentSnapshot['totalDistance'],
                          time: documentSnapshot['time'],
                          imageUrl: documentSnapshot['imageUrl'],
                          bihelDataId: documentSnapshot.id,
                        );
                      });
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget myRecordItem({
    required String date,
    required double averageSpeed,
    required double totalDistance,
    required double time,
    required String imageUrl,
    required String bihelDataId,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(148, 220, 170, 112),
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.only(top: 10, left: 25, right: 25),
      padding: const EdgeInsets.all(10),
      height: 150,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              alignment: Alignment.centerLeft,
              // margin: const EdgeInsets.only(left: 5),
              height: 150,
              child: InkWell(
                onTap: () async {
                  _showImageHandler(
                    imageUrl: imageUrl,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(imageUrl),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(left: 50),
              width: 170,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 5),
                    height: 30,
                    child: Text(
                      date,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 5),
                    height: 30,
                    child: Text(
                      '${totalDistance.toStringAsFixed(2)} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 5),
                    height: 30,
                    child: Text(
                      '${averageSpeed.toStringAsFixed(1)} km/h',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 5),
                    height: 30,
                    child: Text(
                      '${time.toStringAsFixed(2)} h',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.only(right: 5),
              height: 80,
              width: 120,
              child: InkWell(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.delete),
                      Text(
                        'DELETE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                onLongPress: () {
                  _showDeleteDialogHandler(
                    bihelDataId: bihelDataId,
                    imageUrl: imageUrl,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageHandler({
    required String imageUrl,
  }) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: const Color.fromARGB(0, 255, 255, 255),
            child: Builder(builder: (context) {
              return Container(
                color: const Color.fromARGB(0, 255, 255, 255),
                width: 400,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(imageUrl),
                ),
              );
            }),
          );
        });
  }

  Future<void> _showDeleteDialogHandler({
    required String bihelDataId,
    required String imageUrl,
  }) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Are you sure?"),
            actions: [
              SizedBox(
                width: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color.fromARGB(62, 158, 158, 158),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('NO'),
                ),
              ),
              SizedBox(
                width: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color.fromARGB(62, 158, 158, 158),
                  ),
                  onPressed: () {
                    bool isCal = true;
                    if (isCal) {
                      updateTotalDistanceList();
                      calcu();
                      setState(() {
                        isCal = false;
                      });
                    }
                    _deleteItemHandler(
                      bihelDataId: bihelDataId,
                      imageUrl: imageUrl,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 1),
                        content: Center(child: Text("ITEM DELETED")),
                      ),
                    );
                  },
                  child: const Text('YES'),
                ),
              ),
            ],
          );
        });
  }

  Future<void> _deleteItemHandler({
    required String bihelDataId,
    required String imageUrl,
  }) async {
    await FirebaseFirestore.instance
        .collection('BihelData_${user!.email}')
        .doc(bihelDataId)
        .delete();

    await FirebaseStorage.instance.refFromURL(imageUrl).delete();
  }

  void updateTotalDistanceList() {
    myDistanceList.clear();
    FirebaseFirestore.instance
        .collection('BihelData_${user!.email}')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        myDistanceList.add(doc['totalDistance']);
      }
    });
    calculateTotalDistance();
  }

  void calculateTotalDistance() {
    setState(() {
      myTotalDistance = 0;
    });
    for (int i = 0; i < myDistanceList.length; i++) {
      setState(() {
        myTotalDistance += myDistanceList[i];
      });
    }
  }
}
