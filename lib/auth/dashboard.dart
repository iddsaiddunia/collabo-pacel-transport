import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pacel_trans_app/auth/details.dart';
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
  // List<Widget> tabsPageList = [
  //   All(),
  //   pending(),
  //   onDelivery(),
  //   all(),
  // ];

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

  @override
  Widget build(BuildContext context) {
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
                                  CircleAvatar(
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
                            return Center(
                                child: const CircularProgressIndicator());
                          },
                        ),
                        Icon(Icons.notifications),
                      ],
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Container(
                        width: double.infinity,
                        height: 150.0,
                        decoration: BoxDecoration(
                            color: color.primaryColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25))),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 55.0,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                          // color: Colors.blue[50],
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                          border: Border.all(width: 1, color: Colors.black12)),
                      child: TextField(
                        // controller: emailController,
                        decoration: InputDecoration(
                            suffixIcon: Icon(Icons.search),
                            hintText: "Enter your tracking number",
                            hintStyle: TextStyle(fontSize: 14),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: EdgeInsets.symmetric(vertical: 3.0),
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
                              child: ListView(
                                children: [
                                  HistoryCard(
                                    isPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailsPage(id: 1)));
                                    },
                                  ),
                                  HistoryCard(
                                    isPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailsPage(id: 2)));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          CustomPage(
                            content: Text('Page 2 Content'),
                          ),
                          CustomPage(
                            content: Text('Page 2 Content'),
                          ),
                          CustomPage(
                            content: Text('Page 2 Content'),
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
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: (index == selectedIndex) ? Colors.red[200] : null,
            border: Border.all(
              width: 1,
              color: Colors.black12,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
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
