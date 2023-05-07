// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_example/helpers/clicky_button.dart';
import 'package:flutter_blue_plus_example/helpers/create_biheldata_fb.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:math' show cos, sqrt, asin;

import 'package:wakelock/wakelock.dart';

class MyMapScreen extends StatefulWidget {
  const MyMapScreen({Key? key}) : super(key: key);

  @override
  _MyMapScreenState createState() => _MyMapScreenState();
}

class _MyMapScreenState extends State<MyMapScreen> {
  final CameraPosition _initialLocation = const CameraPosition(
    target: LatLng(10.8230989, 106.62966379999999),
    zoom: 15,
  );

  late GoogleMapController mapController;
  late PolylinePoints polylinePoints;

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  bool isCounting = false;
  bool isTracking = false;
  bool isShowingControlBar = false;

  final Set<Polyline> myPolylines = {};
  final List<LatLng> myList = [];

  double distance = 0;
  double preDistance = 0;
  double totalDistance = 0;

  int tmp = 0;

  bool loading = false;
  Reference storageReference = FirebaseStorage.instance.ref();

  Uint8List? _imageBytes;

  double counter = 0;
  double clockTimer = 0;

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    // var width = MediaQuery.of(context).size.width;
    return Scaffold(
      ///////////////////////////////////////////////
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'New record',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Visibility(
          visible: !isTracking,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              // Map view
              buildMapWidget(height * 0.7),
              // Control bar
              buildControlBar(height * 0.2),
            ],
          ),

          // Loading Widget
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
          //
        ],
      ),
    );
  }

  // buildMapWidget Widget
  Widget buildMapWidget(var height) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            polylines: myPolylines,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          // Get current location button
          getCurrentLocatinButton(),
        ],
      ),
    );
  }

  // Current location button
  Widget getCurrentLocatinButton() {
    return Container(
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      child: Align(
        alignment: Alignment.bottomRight,
        child: ClipOval(
          child: Material(
            color: Colors.orange.shade100,
            child: InkWell(
                splashColor: Colors.orange,
                child: const SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(Icons.my_location),
                ),
                onTap: () {
                  _getCurrentLocationHandler();
                }),
          ),
        ),
      ),
    );
  }

  Widget buildControlBar(var height) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber[200],
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(10),
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // The timer
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 25),
              height: 56,
              width: 150,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: const Icon(
                      Icons.timer,
                      size: 45,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 5),
                  buildTime(clockTimer),
                ],
              ),
            ),
          ),

          // The speedometer
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.only(right: 25),
              height: 56,
              width: 150,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: const Icon(
                      Icons.speed,
                      size: 45,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 5),
                  buildDistance(),
                ],
              ),
            ),
          ),

          //start
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              // margin: const EdgeInsets.only(left: 20),
              height: 80,
              // width: 200,
              child: ClickyButton(
                child: isTracking
                    ? const Icon(
                        Icons.pause,
                        color: Colors.white,
                        size: 50,
                      )
                    : const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 50,
                      ),
                color: isTracking ? Colors.red : Colors.green,
                onPressed: () async {
                  Wakelock.enable();
                  !isTracking
                      ? {
                          _getCurrentLocationHandler(),
                          setState(() {
                            isCounting = !isCounting;
                            isTracking = !isTracking;
                          }),
                          _recordingHandler(),
                        }
                      : _finishDialog(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _adjustCameraHandler() {
    double miny = (myList.first.latitude <= myList.last.latitude)
        ? myList.first.latitude
        : myList.last.latitude;
    double minx = (myList.first.longitude <= myList.last.longitude)
        ? myList.first.longitude
        : myList.last.longitude;
    double maxy = (myList.first.latitude <= myList.last.latitude)
        ? myList.last.latitude
        : myList.first.latitude;
    double maxx = (myList.first.longitude <= myList.last.longitude)
        ? myList.last.longitude
        : myList.first.longitude;

    double southWestLatitude = miny;
    double southWestLongitude = minx;

    double northEastLatitude = maxy;
    double northEastLongitude = maxx;

    mapController.moveCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(northEastLatitude, northEastLongitude),
          southwest: LatLng(southWestLatitude, southWestLongitude),
        ),
        100.0,
      ),
    );
  }

  Widget buildTime(double clockTimer) {
    int hours = (clockTimer ~/ 3600);
    int minutes = ((clockTimer - hours * 3600)) ~/ 60;
    int seconds = (clockTimer - (hours * 3600) - (minutes * 60)).toInt();

    String showTime =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Text(
      showTime,
      style: const TextStyle(
        fontSize: 17,
      ),
    );
  }

  Widget buildDistance() {
    return Text(
      totalDistance < 100
          ? '${totalDistance.toStringAsFixed(2)} km'
          : '${totalDistance.toStringAsFixed(1)} km',
      style: const TextStyle(
        fontSize: 17,
      ),
    );
  }

  // calculate distance method
  double _calculateDistanceHandler(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Method for retrieving the current location
  _getCurrentLocationHandler() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 20.0,
            ),
          ),
        );
      });
    }).catchError((e) {
      print(e);
    });
  }

  // _recordingHandler
  Future<void> _recordingHandler() async {
    // call location api every x milliseconds
    if (isCounting) {
      Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        if (isTracking) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          counter++;

          setState(() {
            clockTimer = counter / 2;
          });

          myList.add(LatLng(position.latitude, position.longitude));

          for (int i = 0; i < myList.length - 1; i++) {
            distance += _calculateDistanceHandler(
              myList[i].latitude,
              myList[i].longitude,
              myList[i + 1].latitude,
              myList[i + 1].longitude,
            );
          }

          setState(() {
            totalDistance = distance - preDistance;
            preDistance = distance;
          });

          myPolylines.add(
            Polyline(
              polylineId: const PolylineId('myPolyline'),
              points: myList,
              color: const Color.fromARGB(255, 105, 111, 223),
              width: 5,
            ),
          );

          //track camera => but it makes device slower
          // mapController.animateCamera(
          //   CameraUpdate.newCameraPosition(
          //     CameraPosition(
          //       target: LatLng(position.latitude, position.longitude),
          //       zoom: 20.0,
          //     ),
          //   ),
          // );
        } else {
          timer.cancel();
        }
      });
    }
  }

  //convert and upload image
  void _uploadDataHandler(
      Uint8List capturedImage, double clockTimer, double totalDistance) async {
    UploadTask storageUploadTask = storageReference
        .child("IMG_${DateTime.now().millisecondsSinceEpoch}.png")
        .putData(capturedImage);

    final String imageUrl =
        await (await storageUploadTask).ref.getDownloadURL();

    DateTime today = DateTime.now();
    String uploadDate = '${today.day}-${today.month}-${today.year}';

    int hours = (clockTimer ~/ 3600);
    int minutes = ((clockTimer - hours * 3600)) ~/ 60;
    int seconds = (clockTimer - (hours * 3600) - (minutes * 60)).toInt();

    double timeInHours = hours + minutes / 60 + seconds / 3600;

    double averageSpeed = totalDistance / timeInHours;

    final DateTime timeNow = DateTime.now();

    createData(
      userMail: user!.email.toString(),
      date: uploadDate,
      dateTime: timeNow,
      averageSpeed: averageSpeed,
      totalDistance: totalDistance,
      time: timeInHours,
      imageUrl: imageUrl,
    );

    setState(() {
      loading = false;
    });
  }

  Future<void> _finishDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Tap \'YES\' to save data '
              '(you will loose \n your current progress)\n'
              '\n'
              'Tap \'NO\' to continue your progress'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('YES'),
              onPressed: () async {
                setState(() {
                  Wakelock.disable();
                  
                  // Close dialog
                  Navigator.of(context).pop();

                  // Turn of counting and tracking
                  isCounting = false;
                  isTracking = false;
                });

                // Move camera
                if (myList.isNotEmpty) {
                  _adjustCameraHandler();
                }

                // Capture map
                Uint8List? imageBytes = await mapController.takeSnapshot();

                setState(() {
                  // Turn on loading circular
                  loading = true;

                  // Clear polyline points
                  myList.clear();
                  myPolylines.clear();

                  // Image handler
                  _imageBytes = imageBytes;
                });
                _recordingHandler();
                _uploadDataHandler(
                  _imageBytes!,
                  clockTimer,
                  totalDistance,
                );

                setState(() {
                  // Reset clock timer
                  counter = 0;
                  clockTimer = 0;
                  // Reset distance variables
                  distance = 0;
                  preDistance = 0;
                  totalDistance = 0;
                });

                //
              },
            ),
          ],
        );
      },
    );
  }
  //
}
