// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pacel_trans_app/auth/details.dart';
import 'package:pacel_trans_app/auth/requests.dart';
import 'package:pacel_trans_app/models/order.dart';
import 'package:pacel_trans_app/widgets.dart';

import '../color_themes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  PageController _pageController = PageController(initialPage: 0);
  int _selectedIndex = 0;
  List<String> tabsLength = ["All", "Pending", "On Delivery", "Delivered"];
  // late Timer _timer;
  int _secondsRemaining = 3600; // 1 hour countdown
  bool _isDisposed = false;
  late Future<DocumentSnapshot> _latestRequestFuture;

  @override
  void initState() {
    super.initState();
    // _startCountdown();
    _latestRequestFuture = fetchLatestRequest();
  }

  @override
  void dispose() {
    _isDisposed = true;
    // _timer.cancel();
    super.dispose();
  }

  void changeTabs(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<DocumentSnapshot> getDocument() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser!;
    return FirebaseFirestore.instance
        .collection("clients")
        .doc(firebaseUser.uid)
        .get();
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  Future<DocumentSnapshot> fetchLatestRequest() async {
    var firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception('User not logged in');
    }

    CollectionReference requestPolls =
        FirebaseFirestore.instance.collection('LogisticOrders');

    QuerySnapshot querySnapshot = await requestPolls
        // .orderBy('createdAt', descending: true)
        .where('userId', isEqualTo: firebaseUser.uid)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    } else {
      throw Exception('No requests found');
    }
  }

  // void _startCountdown() {
  //   _timer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     if (_secondsRemaining > 0) {
  //       setState(() {
  //         _secondsRemaining--;
  //       });
  //     } else {
  //       _timer.cancel();
  //       _updateOrderStatus();
  //     }
  //   });
  // }

  Future<void> _updateOrderStatus() async {
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('LogisticOrders')
        .doc("sCdj7sxW5XYfBnjafr8j")
        .get();

    if (orderSnapshot.exists) {
      var orderData = orderSnapshot.data() as Map<String, dynamic>;
      if (orderData['orderStatus'] == 'pending') {
        await FirebaseFirestore.instance
            .collection('LogisticOrders')
            .doc("sCdj7sxW5XYfBnjafr8j")
            .update({'orderStatus': 'expired'});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser!;
    int hours = _secondsRemaining ~/ 3600;
    int minutes = (_secondsRemaining % 3600) ~/ 60;
    int seconds = _secondsRemaining % 60;
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder(
                          future: getDocument(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.person),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(snapshot.data!['username']),
                                  )
                                ],
                              );
                            } else if (snapshot.connectionState ==
                                ConnectionState.none) {
                              return const Text("No data");
                            }
                            return const Center(
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person),
                              ),
                            );
                          },
                        ),
                        const Icon(Icons.notifications),
                      ],
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        width: double.infinity,
                        height: 190.0,
                        decoration: BoxDecoration(
                          color: color.primaryColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: FutureBuilder<DocumentSnapshot>(
                            future: _latestRequestFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data == null) {
                                return Center(child: Text('No requests found'));
                              } else {
                                var requestData = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                return ListView(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "New Request",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RequestPage(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "view all",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Divider(),
                                    Row(
                                      children: [
                                        Text(
                                          "OrderNo- ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
                                        ),
                                        Text(
                                          requestData['orderNo'],
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 228, 228, 228),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Expiring in- ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: Colors.white),
                                          // child: Text(
                                          //   '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                                          //   style: TextStyle(
                                          //       color: Color.fromARGB(
                                          //           255, 75, 75, 75),
                                          //       fontWeight: FontWeight.bold),
                                          // ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "amount- ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
                                        ),
                                        Text(
                                          "${requestData['amount']} Tsh",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 228, 228, 228),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Campany location- ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
                                        ),
                                        Text(
                                          "Mabibo mwisho",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 228, 228, 228),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Campany contacts- ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            copyToClipboard("+255897464044");
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Text copied to clipboard'),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "+255897464044",
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 228, 228, 228),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 55.0,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                          // color: Colors.blue[50],
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                          border: Border.all(width: 1, color: Colors.black12)),
                      child: const TextField(
                        // controller: emailController,
                        decoration: InputDecoration(
                            suffixIcon: Icon(Icons.search),
                            hintText: "Enter your tracking number",
                            hintStyle: TextStyle(fontSize: 14),
                            border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      // color: Colors.black12,
                      child: ListView.builder(
                        itemCount: tabsLength.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Tabs(
                            title: tabsLength[index],
                            index: index,
                            selectedIndex: _selectedIndex,
                            isPressed: () {
                              changeTabs(index);
                              // print(index);
                              _pageController.animateToPage(index,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _selectedIndex = page;
                            print(_selectedIndex);
                          });
                        },
                        children: <Widget>[
                          CustomPage(
                            content: Container(
                              width: double.infinity,
                              height: 240,
                              // color: Colors.red,
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('LogisticOrders')
                                    .where('userId', isEqualTo: user.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data == null) {
                                    return Center(
                                        child: Text('No data available'));
                                  }

                                  final logisticOrders =
                                      snapshot.data!.docs.map((doc) {
                                    return LogisticOrder.fromDocument(doc);
                                  }).toList();

                                  return ListView.builder(
                                    itemCount: logisticOrders.length,
                                    itemBuilder: (context, index) {
                                      return HistoryCard(
                                        orderNo: logisticOrders[index].orderNo,
                                        from: logisticOrders[index].from,
                                        to: logisticOrders[index].to,
                                        isPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DetailsPage(
                                                  id: logisticOrders[index]
                                                      .routeId),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          CustomPage(
                            content: Container(
                              width: double.infinity,
                              height: 240,
                              // color: Colors.red,
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('LogisticOrders')
                                    .where('userId', isEqualTo: user.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data == null) {
                                    return Center(
                                        child: Text('No data available'));
                                  }

                                  final logisticOrders =
                                      snapshot.data!.docs.map((doc) {
                                    return LogisticOrder.fromDocument(doc);
                                  }).toList();

                                  return ListView.builder(
                                    itemCount: logisticOrders.length,
                                    itemBuilder: (context, index) {
                                      if (logisticOrders[index].orderStatus ==
                                          "pending") {
                                        return HistoryCard(
                                          orderNo:
                                              logisticOrders[index].orderNo,
                                          from: logisticOrders[index].from,
                                          to: logisticOrders[index].to,
                                          isPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailsPage(
                                                        id: logisticOrders[
                                                                index]
                                                            .routeId),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                      return SizedBox();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          CustomPage(
                            content: Container(
                              width: double.infinity,
                              height: 240,
                              // color: Colors.red,
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('LogisticOrders')
                                    .where('userId', isEqualTo: user.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data == null) {
                                    return Center(
                                        child: Text('No data available'));
                                  }

                                  final logisticOrders =
                                      snapshot.data!.docs.map((doc) {
                                    return LogisticOrder.fromDocument(doc);
                                  }).toList();

                                  return ListView.builder(
                                    itemCount: logisticOrders.length,
                                    itemBuilder: (context, index) {
                                      if (logisticOrders[index].orderStatus ==
                                          "ondelivery") {
                                        return HistoryCard(
                                          orderNo:
                                              logisticOrders[index].orderNo,
                                          from: logisticOrders[index].from,
                                          to: logisticOrders[index].to,
                                          isPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailsPage(
                                                        id: logisticOrders[
                                                                index]
                                                            .routeId),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                      return SizedBox();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          CustomPage(
                            content: Container(
                              width: double.infinity,
                              height: 240,
                              // color: Colors.red,
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('LogisticOrders')
                                    .where('userId', isEqualTo: user.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data == null) {
                                    return Center(
                                        child: Text('No data available'));
                                  }

                                  final logisticOrders =
                                      snapshot.data!.docs.map((doc) {
                                    return LogisticOrder.fromDocument(doc);
                                  }).toList();

                                  return ListView.builder(
                                    itemCount: logisticOrders.length,
                                    itemBuilder: (context, index) {
                                      if (logisticOrders[index].orderStatus ==
                                          "delivered") {
                                        return HistoryCard(
                                          orderNo:
                                              logisticOrders[index].orderNo,
                                          from: logisticOrders[index].from,
                                          to: logisticOrders[index].to,
                                          isPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailsPage(
                                                        id: logisticOrders[
                                                                index]
                                                            .routeId),
                                              ),
                                            );
                                          },
                                        );
                                      }

                                      return SizedBox();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Tabs extends StatelessWidget {
  final String title;
  final int selectedIndex;
  final int index;
  final Function()? isPressed;
  const Tabs({
    super.key,
    required this.title,
    required this.selectedIndex,
    required this.index,
    required this.isPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPressed,
      child: Container(
        height: 40.0,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: (index == selectedIndex) ? Colors.red[200] : null,
            border: Border.all(
              width: 1,
              color: Colors.black12,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Center(
            child: Text(
          title,
          style: TextStyle(
              fontWeight:
                  (index == selectedIndex) ? FontWeight.w600 : FontWeight.w500),
        )),
      ),
    );
  }
}

class CustomPage extends StatelessWidget {
  final Widget content;

  const CustomPage({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return content;
  }
}
