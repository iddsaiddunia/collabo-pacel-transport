import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pacel_trans_app/color_themes.dart';

final primaryColor = new ColorTheme();

class PollBookingPage extends StatefulWidget {
  final String id;
  final String companyId;
  final String from;
  final String to;
  const PollBookingPage({
    super.key,
    required this.id,
    required this.companyId,
    required this.from,
    required this.to,
  });

  @override
  State<PollBookingPage> createState() => _PollBookingPageState();
}

class _PollBookingPageState extends State<PollBookingPage> {
  final TextEditingController _sizeController = TextEditingController();
  int _selectedIndex = 0;
  int _selectedPackageSizeIndex = 0;
  bool _isChecked = false;
  double estimatedAmount = 0.0;
  bool isLoading = false;
  double? chargesPerTon;

  @override
  void initState() {
    super.initState();
    fetchChargesPerTon(widget.id);
  }

  Future<void> fetchChargesPerTon(String routeId) async {
    try {
      // Fetch the route document using routeId
      DocumentSnapshot routeDoc = await FirebaseFirestore.instance
          .collection('RoutesPolls')
          .doc(routeId)
          .get();

      if (routeDoc.exists) {
        setState(() {
          chargesPerTon = routeDoc['chargesPerTon'];
        });
      } else {
        throw Exception('Route not found');
      }
    } catch (e) {
      print('Error fetching charges per ton: $e');
    }
  }

  void _onCheckboxChanged(bool? value) {
    setState(() {
      _isChecked = value!;
    });
  }

  List<String> packageTypeList = [
    "Documents",
    "hardwares",
    "Electronics",
    "Crops",
  ];
  List<String> packageSize = [
    "Envelop",
    "small box",
    "medium box",
    "large box",
    "other",
  ];

  _selectPackageType(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  _selectPackageSize(index) {
    setState(() {
      _selectedPackageSizeIndex = index;
    });
  }

  _calculatePrice() {
    if (_selectedIndex == 0) {
      if (_selectedPackageSizeIndex == 0 || _selectedPackageSizeIndex == 1) {
        setState(() {
          estimatedAmount = 5000.0;
        });
      } else {
        setState(() {
          estimatedAmount = 10000.0;
        });
      }
    } else if (_selectedIndex == 1 || _selectedIndex == 3) {
      double size = double.parse(_sizeController.text);
      setState(() {
        estimatedAmount = size * chargesPerTon!;
      });
    }
  }

  Future<double> fetchRemainingSpace(String routeId) async {
    try {
      // Reference to the RoutesPolls collection
      final CollectionReference routesCollection =
          FirebaseFirestore.instance.collection('RoutesPolls');

      // Fetch the document with the specified routeId
      DocumentSnapshot routeDoc = await routesCollection.doc(routeId).get();

      // Check if the document exists
      if (routeDoc.exists) {
        // Extract remainingSpace from the document data
        final data = routeDoc.data() as Map<String, dynamic>;
        final remainingSpace = data['remainingSpace'];

        // Check if remainingSpace is of type int or can be converted to int
        // if (remainingSpace is int) {
        //   return remainingSpace;
        // } else if (remainingSpace is double) {
        //   return remainingSpace.toInt();
        // } else {
        //   throw Exception('Invalid type for remainingSpace');
        // }

        return remainingSpace;
      } else {
        throw Exception('Route not found');
      }
    } catch (e) {
      // Handle errors
      print('Error fetching remainingSpace: $e');
      throw e;
    }
  }

  Future<void> requestRoutePoll({
    required double amount,
    required String companyID,
    required bool isBreakable,
    required String from,
    required String to,
    required String orderNo,
    required String orderStatus,
    required String packageSize,
    required String packageType,
    required bool paymentStatus,
    required String paymentType,
    required String routeId,
    required String userId,
    required DateTime createdAt,
  }) async {
    try {
      setState(() {
        isLoading = true;
      });

      double space = await fetchRemainingSpace(widget.id);

      if (space < int.parse(_sizeController.text)) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No enough space available"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        double _remainingSpace = space - double.parse(_sizeController.text);

        await FirebaseFirestore.instance.collection('LogisticOrders').add({
          'amount': amount,
          'approvalStatus': false,
          'companyID': companyID,
          'isBreakable': isBreakable,
          'from': from,
          'to': to,
          'orderNo': orderNo,
          'orderStatus': orderStatus,
          'packageSize': packageSize,
          'packageType': packageType,
          'paymentStatus': paymentStatus,
          'paymentType': paymentType,
          'depatureStatus': "waiting",
          'cargoReceived': false,
          'routeId': routeId,
          'userId': userId,
          'createdAt': createdAt,
        }).then((value) => {
              value.update({'orderNo': value.id}),
              setState(() {
                isLoading = false;
              }),
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Request Status'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'Initial order is placed successifully do checkin and payments within 1hour.'),
                        SizedBox(
                          height: 10.0,
                        ),
                        Column(
                          children: [
                            Text(
                              'invoice number',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            Text(value.id),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              )
            });

        DocumentSnapshot routeSnapshot = await FirebaseFirestore.instance
            .collection('RoutesPolls')
            .doc(widget.id)
            .get();
        if (routeSnapshot.exists) {
          // int remainingSpace = routeSnapshot['remainingSpace'] as int;
          await FirebaseFirestore.instance
              .collection('RoutesPolls')
              .doc(routeId)
              .update({
            'remainingSpace': _remainingSpace, // Update remainingSpace
          });
        }
        print('Route poll added successfully');
      }
    } catch (e) {
      print('Failed to add route poll: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
        child: ListView(
          children: [
            Text(
              "Package details",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
            ),
            Text(
              "what are you sending?",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              width: double.infinity,
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: packageTypeList.length,
                itemBuilder: (context, index) {
                  return PackageType(
                    title: packageTypeList[index],
                    ontap: () {
                      _selectPackageType(index);
                    },
                    index: index,
                    selectedIndex: _selectedIndex,
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Package size",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10,
            ),
            (_selectedIndex == 0)
                ? Container(
                    width: double.infinity,
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: packageSize.length,
                      itemBuilder: (context, index) {
                        return PackageSize(
                          title: packageSize[index],
                          ontap: () {
                            _selectPackageSize(index);
                          },
                          index: index,
                          selectedIndex: _selectedPackageSizeIndex,
                        );
                      },
                    ),
                  )
                : Container(),
            SizedBox(
              height: 25.0,
            ),

            (_selectedIndex != 0)
                ? TextField(
                    controller: _sizeController,
                    decoration: InputDecoration(
                      hintText: "specify size(Ton)",
                      hintStyle: TextStyle(fontSize: 15),
                    ),
                  )
                : Container(),
            SizedBox(
              height: 25.0,
            ),
            Row(
              children: [
                Checkbox(value: this._isChecked, onChanged: _onCheckboxChanged),
                Text("Breakable items")
              ],
            ),
            // Row(
            //   children: [
            //     Checkbox(value: this._isChecked, onChanged: _onCheckboxChanged),
            //     Text("No prohibited items")
            //   ],
            // ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Payment details",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              height: 130.0,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Estimeted price",
                        style: TextStyle(),
                      ),
                      Row(children: [
                        Text(
                          "${estimatedAmount.toString()} Tsh",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: color.primaryColor),
                        ),
                        MaterialButton(
                          color: color.primaryColor,
                          onPressed: () {
                            _calculatePrice();
                          },
                          child: Text(
                            "Generate",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        )
                        // IconButton(
                        //   onPressed: () {},
                        //   icon: Icon(
                        //     Icons.arrow_forward_ios,
                        //     color: Colors.black26,
                        //   ),
                        //   iconSize: 20,
                        // )
                      ])
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payment method",
                        style: TextStyle(),
                      ),
                      Row(
                        children: [
                          Text(
                            "Cash",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black26,
                            ),
                            iconSize: 20,
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              "Please make sure you checkin your order within 1 hr or will be cancelled",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
              elevation: 0,
              height: 55,
              color: color.primaryColor,
              onPressed: () {
                User? user = FirebaseAuth.instance.currentUser;

                requestRoutePoll(
                  amount: estimatedAmount,
                  companyID: widget.companyId,
                  isBreakable: _isChecked,
                  from: widget.from,
                  to: widget.to,
                  orderNo: "",
                  orderStatus: "init",
                  packageSize: packageSize[_selectedPackageSizeIndex],
                  packageType: packageTypeList[_selectedIndex],
                  paymentStatus: false,
                  paymentType: "cash",
                  routeId: widget.id,
                  userId: user!.uid,
                  createdAt: DateTime.now(),
                );
              },
              child: (!isLoading)
                  ? Text(
                      "Place order",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : CircularProgressIndicator(
                      color: Colors.white,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class PackageType extends StatelessWidget {
  final String title;
  final Function()? ontap;
  final int index;
  final int selectedIndex;
  const PackageType(
      {super.key,
      required this.title,
      required this.ontap,
      required this.index,
      required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.symmetric(horizontal: 15),
        // width: 130,
        height: 60,
        decoration: BoxDecoration(
            color: Colors.white,
            border: (index == selectedIndex)
                ? Border.all(width: 2, color: Color.fromRGBO(47, 66, 96, 1.0))
                : Border.all(width: 1, color: Colors.black12),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.book),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PackageSize extends StatelessWidget {
  final String title;
  final Function()? ontap;
  final int index;
  final int selectedIndex;
  const PackageSize(
      {super.key,
      required this.title,
      required this.ontap,
      required this.index,
      required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            padding: EdgeInsets.all(18),
            width: 95,
            height: 95,
            decoration: BoxDecoration(
                color: Colors.white,
                border: (index == selectedIndex)
                    ? Border.all(
                        width: 2, color: Color.fromRGBO(47, 66, 96, 1.0))
                    : Border.all(width: 1, color: Colors.black12),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Image.asset('assets/img/box.png'),
          ),
          Text(title,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))
        ],
      ),
    );
  }
}
