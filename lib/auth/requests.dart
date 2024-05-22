import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pacel_trans_app/models/order.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('LogisticOrders')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available'));
          }

          final logisticOrders = snapshot.data!.docs.map((doc) {
            return LogisticOrder.fromDocument(doc);
          }).toList();

          return ListView.builder(
            itemCount: logisticOrders.length,
            itemBuilder: (context, index) {
              if (logisticOrders[index].orderStatus != "init") {
                return SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black12),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            verticalTextTIle(
                              title: "OrderNo",
                              content:
                                  logisticOrders[index].orderNo.toUpperCase(),
                            ),
                            verticalTextTIle(
                              title: "Status",
                              content: "pre-request",
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            verticalTextTIle(
                              title: "From",
                              content: logisticOrders[index].from,
                            ),
                            verticalTextTIle(
                              title: "To",
                              content: logisticOrders[index].to,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            verticalTextTIle(
                              title: "Logistics Provider",
                              content: "DHL Logistics",
                            ),
                            verticalTextTIle(
                              title: "Contact",
                              content: "+25590099388",
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            verticalTextTIle(
                              title: "Amount",
                              content: logisticOrders[index].amount.toString(),
                            ),
                            verticalTextTIle(
                              title: "Expires",
                              content: "00:45:20",
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            verticalTextTIle(
                              title: "package Type",
                              content: logisticOrders[index].packageType,
                            ),
                            verticalTextTIle(
                              title: "Package Size",
                              content: logisticOrders[index].packageSize,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class verticalTextTIle extends StatelessWidget {
  final String title;
  final String content;
  const verticalTextTIle({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 11),
        ),
        Text(
          content,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
