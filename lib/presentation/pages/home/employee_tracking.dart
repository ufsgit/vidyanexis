import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:techtify/constants/app_colors.dart';
import 'dart:async';

import 'package:techtify/constants/app_styles.dart';

class EmployeeTracking extends StatefulWidget {
  const EmployeeTracking({super.key});

  @override
  _EmployeeTrackingState createState() => _EmployeeTrackingState();
}

class _EmployeeTrackingState extends State<EmployeeTracking> {
  final MapController mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;
  String? selectedFromDate;
  String? selectedToDate;
  List<LatLng> latLng = [
    const LatLng(26.907524, 75.739639),
    const LatLng(12.120000, 76.680000),
    const LatLng(24.879999, 74.629997),
    const LatLng(16.994444, 73.300003),
  ];
  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _startLocationUpdates();
  }

  final List<LatLng> routePoints = [];

  void _startLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        // currentLocation = LatLng(position.latitude, position.longitude);
        mapController.move(latLng[0], mapController.zoom);
      });
    });
    // routePoints.addAll(f); // Update route points
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      _startLocationUpdates();
    } catch (e) {
      print('Error initializing location: $e');
    }
  }

  // void _startLocationUpdates() {
  //   const locationSettings = LocationSettings(
  //     accuracy: LocationAccuracy.high,
  //     distanceFilter: 10,
  //   );

  //   _positionStreamSubscription = Geolocator.getPositionStream(
  //     locationSettings: locationSettings
  //   ).listen((Position position) {
  //     setState(() {
  //       currentLocation = LatLng(position.latitude, position.longitude);
  //       mapController.move(currentLocation, mapController.zoom);
  //     });
  //   });
  // }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // // Create a list of points for the route
    // final List<LatLng> routePoints = [
    //   currentLocation,
    //   fixedLocation,
    // ];

    return Scaffold(
      appBar: !AppStyles.isWebScreen(context)
          ? AppBar(
              surfaceTintColor: AppColors.scaffoldColor,
              backgroundColor: AppColors.whiteColor,
              title: Text(
                'Employee Tracking',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: latLng[0],
              zoom: 8.0,
            ),
            children: [
              // Base map layer
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),

              // Markers layer
              MarkerLayer(
                markers: [
                  ...latLng.map(
                    (e) => Marker(
                      point: e,
                      width: 40.0,
                      height: 40.0,
                      builder: (context) => Tooltip(
                        preferBelow: false,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  spreadRadius: 4)
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        textStyle: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500),
                        message:
                            "Employee Name : Adam John \nAkshya Nagar 1st Block 1st Cross, Rammurthy nagar, Bangalore-560016",
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 3,
                                    spreadRadius: 4)
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Icon(
                              Icons.roofing_outlined,
                              color: AppColors.primaryBlue,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: DropdownButtonFormField<String>(
                        items: const [
                          DropdownMenuItem(value: "1", child: Text("Adeeb")),
                          DropdownMenuItem(value: "2", child: Text("Nihal"))
                        ],
                        hint: Text(
                          "Select a staff",
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400),
                        ),
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none)),
                        onChanged: (e) {}),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => onClickDate(context, isFromDate: true),
                    child: Container(
                      height: 45,
                      width: 200,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: Colors.grey.shade300,
                          ),
                          Text(
                            selectedFromDate ?? "From Date",
                            style: TextStyle(
                                color: selectedFromDate == null
                                    ? Colors.grey.shade500
                                    : Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => onClickDate(context),
                    child: Container(
                      height: 45,
                      width: 200,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: Colors.grey.shade300,
                          ),
                          Text(
                            selectedToDate ?? "To Date",
                            style: TextStyle(
                                color: selectedToDate == null
                                    ? Colors.grey.shade500
                                    : Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          fixedSize: const Size(130, 45),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () {},
                      child: const Text("Apply"))
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 32, right: 20),
                  decoration: BoxDecoration(
                      boxShadow: const [],
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Locations",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 18),
                      ...[
                        {
                          "name": "Adeeb",
                          "location":
                              "Akshya Nagar 1st Block 1st Cross, Rammurthy nagar, Bangalore-560016"
                        },
                        {
                          "name": "Adeeb",
                          "location":
                              "Akshya Nagar 1st Block 1st Cross, Rammurthy nagar, Bangalore-560016"
                        },
                      ].map(
                        (e) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "Customer Name",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  e["name"] ?? "",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text(
                                  "Location",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.6,
                                  child: Text(
                                    e["location"] ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      // // Add a floating button to recenter the map
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     mapController.move(latLng[0], mapController.zoom);
      //   },
      //   child: const Icon(Icons.my_location),
      // ),
    );
  }

  Future<void> onClickDate(BuildContext context,
      {bool isFromDate = false}) async {
    try {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );

      if (pickedDate == null) return;

      final formattedDate = DateFormat('dd MMM yyyy').format(pickedDate);

      setState(() {
        if (isFromDate) {
          selectedFromDate = formattedDate;
        } else {
          selectedToDate = formattedDate;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting date: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
