import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pacel_trans_app/auth/routesPoll.dart';
import 'package:pacel_trans_app/color_themes.dart';

class DetailsPage extends StatefulWidget {
  final int id;
  const DetailsPage({
    super.key,
    required this.id,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late GoogleMapController _controller;
  DateTime march12_2024 = DateTime(2024, 3, 12);

  // Format the DateTime object to a human-readable string.
  String formattedDate = '${DateTime(2024, 3, 12).year}-${DateTime(2024, 3, 12).month.toString().padLeft(2, '0')}-${DateTime(2024, 3, 12).day.toString().padLeft(2, '0')}';



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
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // San Francisco coordinates
                zoom: 12.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
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
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15),),),
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
                                    color: Colors
                                        .black12, // Left border color
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
                                          mainAxisAlignment: MainAxisAlignment.center,
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
                      SizedBox(height: 15,),
                      Text("Detailed Status",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                      SizedBox(height: 15,),
                      Column(
                        children: [
                          TrackBox(status: "Delivered for packing", location: "Kimara, Dar Es Salaam", currentStatus: 0,index: 0,dueDate: formattedDate,),
                          TrackBox(status: "Transit", location: "Dodoma,Shinyanga,Mwanza", currentStatus: 0,index: 1,dueDate: formattedDate,),
                          TrackBox(status: "Arrival", location: "Mwanza", currentStatus: 0,index: 2,dueDate: formattedDate,),


                          
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
  const TrackBox({
    super.key,
    required this.status,
    required this.location,
    required this.currentStatus,
    required this.index,
    this.dueDate
  });

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
                  color: (currentStatus ==index )?Color.fromRGBO(47, 66, 96, 1.0): null,
                  border: Border.all(width: 2,color: Colors.black12),
                  borderRadius: BorderRadius.all(Radius.circular(20),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                child: Text(status,style: TextStyle(fontWeight:(currentStatus ==index )? FontWeight.w600:FontWeight.w500,fontSize: 13.8),),
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
                          color: Colors
                              .black12, // Left border color
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
                          child: Text(location,style: TextStyle(fontSize: 11),),
                        ),
                        Text(dueDate.toString(),style: TextStyle(fontSize: 11),),
                      ],),
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
