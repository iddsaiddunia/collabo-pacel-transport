import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pacel_trans_app/auth/routesPoll.dart';
import 'package:pacel_trans_app/color_themes.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailsPage extends StatefulWidget {
  final String id;
  final String from;
  final String to;

  const DetailsPage({
    super.key,
    required this.id,
    required this.from,
    required this.to,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late GoogleMapController _mapController;
  DateTime march12_2024 = DateTime(2024, 3, 12);
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
  late LatLng? _fromLatLng;
  late LatLng? _toLatLng;
  String? routeStatus;
  int toggleTrack = 0;
  String _apiKey = 'AIzaSyAjsJbodhou5nNntMWPdhRsWqz2h1Tgzoc';

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

    _fetchOrderDetails();
  }

  Future<void> _getCurrentLocation() async {
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
      if (mounted) {
        setState(() {
          _currentAddress = 'Error getting location: $e';
        });
      }
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

  Future<void> _fetchOrderDetails() async {
    try {
      print('Fetching order details...');
      // Fetch order details from LogisticOrders collection
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('LogisticOrders')
          .doc(widget.id)
          .get();

      if (orderSnapshot.exists) {
        var orderData = orderSnapshot.data() as Map<String, dynamic>;
        String from = orderData['from'];
        String to = orderData['to'];
        String routeId = orderData['routeId'];
        print('Order details fetched: from: $from, to: $to, routeId: $routeId');

        // Convert addresses to LatLng
        _fromLatLng = await _getLatLngFromAddress(from);
        _toLatLng = await _getLatLngFromAddress(to);

        _markers.add(Marker(
          markerId: MarkerId("start"),
          position: _fromLatLng!,
          infoWindow: InfoWindow(
            title: 'start',
          ),
        ));
        _markers.add(Marker(
          markerId: MarkerId("destination"),
          position: _toLatLng!,
          infoWindow: InfoWindow(
            title: 'start',
          ),
        ));
        print(
            'Converted addresses to LatLng: from: $_fromLatLng, to: $_toLatLng');

        // Fetch route from RoutesPolls collection
        DocumentSnapshot routeSnapshot = await FirebaseFirestore.instance
            .collection('RoutesPolls')
            .doc(routeId)
            .get();

        if (routeSnapshot.exists) {
          var routeData = routeSnapshot.data() as Map<String, dynamic>;
          List<String> arrivedLocationList =
              List<String>.from(routeData['ArrivedLocationList']);
          print(
              'Route details fetched with arrived locations: $arrivedLocationList');

          if (mounted) {
            setState(() {
              routeStatus = routeData['depatureStatus'];
            });
          }
          automateTrack();
          // Convert arrived locations to LatLng and add markers
          for (String location in arrivedLocationList) {
            LatLng? latLng = await _getLatLngFromAddress(location);
            _markers.add(Marker(
              markerId: MarkerId(location),
              position: latLng!,
              infoWindow:
                  InfoWindow(title: 'Achieved Location', snippet: location),
            ));
            print('Added marker for achieved location: $location -> $latLng');
          }

          // Draw route on map
          if (_fromLatLng != null && _toLatLng != null) {
            await _drawRoute(_fromLatLng!, _toLatLng!);
          } else {
            print('Error: _fromLatLng or _toLatLng is null');
          }
        } else {
          print('Route not found in RoutesPolls');
        }
      } else {
        print('Order not found');
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
  }

  Future<LatLng?> _getLatLngFromAddress(String address) async {
    print('Converting address to LatLng: $address');
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final location = data['results'][0]['geometry']['location'];
      LatLng latLng = LatLng(location['lat'], location['lng']);
      print('Converted address to LatLng: $address -> $latLng');
      return latLng;
    } else {
      print('Failed to get LatLng for address: $address');
      return null;
    }
  }

  Future<void> _drawRoute(LatLng start, LatLng end) async {
    print('Drawing route from $start to $end');
    final PolylinePoints polylinePoints = PolylinePoints();
    final PolylineResult result =
        await polylinePoints.getRouteBetweenCoordinates(
      _apiKey,
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(end.latitude, end.longitude),
    );

    if (result.points.isNotEmpty) {
      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: result.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList(),
          color: Colors.blue,
          width: 5,
        ));
      });
      print('Route drawn successfully');
    } else {
      print('Failed to load directions');
      throw Exception('Failed to load directions');
    }
  }

  automateTrack() {
    if (routeStatus == "waiting") {
      setState(() {
        toggleTrack = 0;
      });
    } else if (routeStatus == "depatured") {
      setState(() {
        toggleTrack = 1;
      });
    } else if (routeStatus == "arrived") {
      setState(() {
        toggleTrack = 2;
      });
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
                      controller.setMapStyle(_mapStyle);

                      if (_fromLatLng != null && _toLatLng != null) {
                        _mapController.animateCamera(
                          CameraUpdate.newLatLngBounds(
                            LatLngBounds(
                              southwest: LatLng(
                                _fromLatLng!.latitude < _toLatLng!.latitude
                                    ? _fromLatLng!.latitude
                                    : _toLatLng!.latitude,
                                _fromLatLng!.longitude < _toLatLng!.longitude
                                    ? _fromLatLng!.longitude
                                    : _toLatLng!.longitude,
                              ),
                              northeast: LatLng(
                                _fromLatLng!.latitude > _toLatLng!.latitude
                                    ? _fromLatLng!.latitude
                                    : _toLatLng!.latitude,
                                _fromLatLng!.longitude > _toLatLng!.longitude
                                    ? _fromLatLng!.longitude
                                    : _toLatLng!.longitude,
                              ),
                            ),
                            100.0,
                          ),
                        );
                      }
                    },
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
                            location: "${widget.from}",
                            currentStatus: toggleTrack,
                            index: 0,
                            dueDate: formattedDate,
                          ),
                          TrackBox(
                            status: "Transit",
                            location: "Dodoma,Shinyanga,Mwanza",
                            currentStatus: toggleTrack,
                            index: 1,
                            dueDate: formattedDate,
                          ),
                          TrackBox(
                            status: "Arrival",
                            location: "${widget.to}",
                            currentStatus: toggleTrack,
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
