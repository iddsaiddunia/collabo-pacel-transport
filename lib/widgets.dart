import 'package:flutter/material.dart';
import 'package:pacel_trans_app/color_themes.dart';

class HistoryCard extends StatelessWidget {
  final Function()? isPressed;
  const HistoryCard({super.key, required this.isPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70.0,
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      // margin: const EdgeInsets.symmetric(vertical: 3.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom:
              BorderSide(width: 1, color: Color.fromARGB(255, 224, 224, 224)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                  width: 47,
                  height: 47,
                  padding: const EdgeInsets.all(9.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: const Color.fromARGB(255, 150, 150, 150),
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(25),
                    ),
                  ),
                  child: Icon(
                    Icons.fire_truck,
                    color: Colors.black54,
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("GEJFKKKLDLLLD",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12)),
                    Text("Dar - Mwanza", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
              onPressed: isPressed,
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.black54,
              ))
        ],
      ),
    );
  }
}

class PollBox extends StatelessWidget {
  final String truckInfo;
  final String companyName;
  final DateTime depatureDate;
  final String from;
  final String to;
  final double remainingCapacity;
  final Function()? ontap;
  const PollBox({
    super.key,
    required this.ontap,
    required this.truckInfo,
    required this.companyName,
    required this.depatureDate,
    required this.from,
    required this.to,
    required this.remainingCapacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: Colors.black12),
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
                color: Colors.white10, blurRadius: 2.0, spreadRadius: 2.0),
          ]),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      truckInfo,
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      companyName,
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Depature",
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      depatureDate.toString(),
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              ],
            ),
          ),
          Divider(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      from,
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      to,
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ramaining Capacity",
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "${remainingCapacity.toString()} Tons",
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                MaterialButton(
                  color: color.primaryColor,
                  onPressed: ontap,
                  child: Text(
                    "Proceed",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  elevation: 0,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
