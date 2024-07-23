import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pacel_trans_app/auth/routesPoll.dart';
import 'package:pacel_trans_app/color_themes.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'dart:convert';

class DetailsPage extends StatefulWidget {
  final String id;
  const DetailsPage({
    super.key,
    required this.id,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late GoogleMapController _mapController;
  DateTime march12_2024 = DateTime(2024, 3, 12);
  // late Position _currentPosition;
  // LatLng? _currentLatLng;
  late String _mapStyle;

  // LatLng _initialPosition = LatLng(0, 0);
  String _currentAddress = 'Fetching current location...';
  Position? _currentPosition;

  LatLng _initialPosition =
      LatLng(-6.7924, 39.2083); // Dar es Salaam coordinates
  List<LatLng> _polylineCoordinates = [];
  bool _isLoading = true;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLngBounds? bounds;
  List<LatLng> _routePoints = [];
  String apiKey = 'AIzaSyAjsJbodhou5nNntMWPdhRsWqz2h1Tgzoc';

  // Format the DateTime object to a human-readable string.
  String formattedDate =
      '${DateTime(2024, 3, 12).year}-${DateTime(2024, 3, 12).month.toString().padLeft(2, '0')}-${DateTime(2024, 3, 12).day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    fetchRouteDetails(widget.id);
  }

  Future<void> _getCurrentLocation() async {
    print("hello");
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _initialPosition = LatLng(position.latitude, position.longitude);
        _currentAddress =
            'Lat: ${position.latitude}, Long: ${position.longitude}';
      });

      _mapController.animateCamera(
        CameraUpdate.newLatLng(_initialPosition),
      );
    } catch (e) {
      setState(() {
        _currentAddress = 'Error getting location: $e';
      });
    }
  }

  Future<bool> _handleLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      if (await Permission.location.request().isGranted) {
        return true;
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  Future<void> fetchRouteDetails(String routeId) async {
    print("hello world");
    try {
      // Fetch the route document using routeId
      DocumentSnapshot routeDoc = await FirebaseFirestore.instance
          .collection('RoutesPolls')
          .doc(routeId)
          .get();

      if (routeDoc.exists) {
        String from = routeDoc['from'];
        String to = routeDoc['to'];
        List<dynamic> locationList = routeDoc['locationList'];

        List<String> addresses = [from, ...locationList.cast<String>(), to];
        List<LatLng> coordinates = await geocodeAddresses(addresses);

        print("$addresses ---->");

        if (coordinates.length >= 2) {
          setState(() {
            _markers.add(Marker(
              markerId: MarkerId('start'),
              position: coordinates.first,
              infoWindow: InfoWindow(title: 'Start'),
            ));
            _markers.add(Marker(
              markerId: MarkerId('destination'),
              position: coordinates.last,
              infoWindow: InfoWindow(title: 'Destination'),
            ));

            for (int i = 1; i < coordinates.length - 1; i++) {
              _markers.add(Marker(
                markerId: MarkerId('location_$i'),
                position: coordinates[i],
                infoWindow: InfoWindow(title: 'Stop ${i + 1}'),
              ));
            }

            bounds = LatLngBounds(
              southwest: coordinates.reduce((a, b) => LatLng(
                  a.latitude < b.latitude ? a.latitude : b.latitude,
                  a.longitude < b.longitude ? a.longitude : b.longitude)),
              northeast: coordinates.reduce((a, b) => LatLng(
                  a.latitude > b.latitude ? a.latitude : b.latitude,
                  a.longitude > b.longitude ? a.longitude : b.longitude)),
            );

            _drawRoute(coordinates.first, coordinates.last,
                coordinates.sublist(1, coordinates.length - 1));
          });
        }
      } else {
        throw Exception('Route not found');
      }
    } catch (e) {
      print('Error fetching route details: $e');
    }
  }

  Future<List<LatLng>> geocodeAddresses(List<String> addresses) async {
    List<LatLng> coordinates = [];
    for (String address in addresses) {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        coordinates
            .add(LatLng(locations.first.latitude, locations.first.longitude));
      }
    }
    return coordinates;
  }

  Future<void> _drawRoute(
      LatLng start, LatLng end, List<LatLng> waypoints) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final polylinePoints = data['routes'][0]['overview_polyline']['points'];
      final List<List<num>> decodedPolyline = decodePolyline(polylinePoints);

      List<LatLng> result = decodedPolyline
          .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
          .toList();

      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: result,
          color: Colors.blue,
          width: 5,
        ));
      });
    } else {
      throw Exception('Failed to load directions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 1.3,
            // color: Colors.red,
            child: _initialPosition == null
                ? Center(child: const CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 7,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    // polylines: {
                    //   if (_polylineCoordinates.isNotEmpty)
                    //     Polyline(
                    //       polylineId: PolylineId('route'),
                    //       points: _polylineCoordinates,
                    //       color: Colors.blue,
                    //       width: 5,
                    //     ),
                    // },
                    // markers: {
                    //   Marker(
                    //     markerId: MarkerId('dar_es_salaam'),
                    //     position: LatLng(-6.7924, 39.2083),
                    //     infoWindow: InfoWindow(title: 'Dar es Salaam'),
                    //   ),
                    //   Marker(
                    //     markerId: MarkerId('mwanza'),
                    //     position: LatLng(-2.5163, 32.9175),
                    //     infoWindow: InfoWindow(title: 'Mwanza'),
                    //   ),
                    // },

                    markers: _markers,
                    polylines: _polylines,
                  ),
          ),
          DraggableScrollableSheet(
            initialChildSize:
                0.3, // Initial size of the sheet (30% of the screen)
            minChildSize: 0.15, // Minimum size of the sheet (10% of the screen)
            maxChildSize: 0.6, // Maximum size of the sheet (80% of the screen)
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Align(
                              child: Container(
                                width: 100,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Container(
                              height: 70.0,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.black12, // Left border color
                                    width: 1, // Left border width
                                    style: BorderStyle.solid,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Allen Swai",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              "DHL Logistics",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35),
                                      ),
                                      color: Color.fromRGBO(47, 66, 96, 1.0),
                                    ),
                                    child: const Icon(
                                      Icons.phone,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Detailed Status",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Column(
                        children: [
                          TrackBox(
                            status: "Delivered for packing",
                            location: "Kimara, Dar Es Salaam",
                            currentStatus: 0,
                            index: 0,
                            dueDate: formattedDate,
                          ),
                          TrackBox(
                            status: "Transit",
                            location: "Dodoma,Shinyanga,Mwanza",
                            currentStatus: 0,
                            index: 1,
                            dueDate: formattedDate,
                          ),
                          TrackBox(
                            status: "Arrival",
                            location: "Mwanza",
                            currentStatus: 0,
                            index: 2,
                            dueDate: formattedDate,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class TrackBox extends StatelessWidget {
  final String status;
  final String location;
  final int currentStatus;
  final int index;
  final String? dueDate;
  const TrackBox(
      {super.key,
      required this.status,
      required this.location,
      required this.currentStatus,
      required this.index,
      this.dueDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      // color: Colors.grey,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  color: (currentStatus == index)
                      ? Color.fromRGBO(47, 66, 96, 1.0)
                      : null,
                  border: Border.all(width: 2, color: Colors.black12),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                child: Text(
                  status,
                  style: TextStyle(
                      fontWeight: (currentStatus == index)
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 13.8),
                ),
              )
            ],
          ),
          Expanded(
            child: Container(
              // color: Colors.red,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 60,
                    decoration: BoxDecoration(
                      // color: Colors.blue,
                      border: Border(
                        right: BorderSide(
                          color: Colors.black12, // Left border color
                          width: 1, // Left border width
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      // color: Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              location,
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                          Text(
                            dueDate.toString(),
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
