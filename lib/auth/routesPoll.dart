import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pacel_trans_app/auth/poll_booking.dart';
import 'package:pacel_trans_app/color_themes.dart';
import 'package:pacel_trans_app/models/route.dart';
import 'package:pacel_trans_app/widgets.dart';

final color = ColorTheme();

class RoutesPollsPage extends StatefulWidget {
  const RoutesPollsPage({super.key});

  @override
  State<RoutesPollsPage> createState() => _RoutesPollsPageState();
}

class _RoutesPollsPageState extends State<RoutesPollsPage> {
  final CollectionReference routesCollection =
      FirebaseFirestore.instance.collection('RoutesPolls');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 4.3,
            color: color.primaryColor,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 15.0),
                  child: SizedBox(
                    height: 250,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 2,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Active Routes",
                              style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Container(
                              width: 100,
                              height: 7,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            )
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          height: 130,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              border:
                                  Border.all(width: 1, color: Colors.black12)),
                          child: Column(
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "From",
                                  hintStyle: TextStyle(fontSize: 10),
                                ),
                              ),
                              TextField(
                                decoration: InputDecoration(
                                    // label: Text("From"),
                                    hintText: "To",
                                    hintStyle: TextStyle(fontSize: 10)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: StreamBuilder<Object>(
                          stream: routesCollection.snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData || snapshot.data == null) {
                              return const Center(
                                  child: Text('No data available'));
                            }

                            // Explicitly cast snapshot.data to QuerySnapshot
                            final QuerySnapshot querySnapshot =
                                snapshot.data as QuerySnapshot;

                            final routes = querySnapshot.docs.map((doc) {
                              return Routes.fromDocument(doc);
                            }).toList();
                            return ListView.builder(
                                itemCount: routes.length,
                                itemBuilder: (context, index) {
                                  return PollBox(
                                    truckInfo: routes[index].trackInfo,
                                    companyName: routes[index].companyName,
                                    depatureDate: routes[index].departureTime.toDate(),
                                    from: routes[index].from,
                                    to: routes[index].to,
                                    remainingCapacity: routes[index].remainingSpace,
                                    ontap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PollBookingPage(id:routes[index].id),
                                        ),
                                      );
                                    },
                                  );
                                });
                          }),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
