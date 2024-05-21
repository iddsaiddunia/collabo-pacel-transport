import 'package:cloud_firestore/cloud_firestore.dart';

class Routes {
  final String id;
  final Timestamp arrivalTime;
  final double chargesPerTon;
  final String companyID;
  final String companyName;
  final Timestamp departureTime;
  final String from;
  final double remainingSpace;
  final String to;
  final String trackInfo;

  Routes({
    required this.id,
    required this.arrivalTime,
    required this.chargesPerTon,
    required this.companyID,
    required this.companyName,
    required this.departureTime,
    required this.from,
    required this.remainingSpace,
    required this.to,
    required this.trackInfo,
  });

  // Factory constructor to create a Routes instance from a Firestore document
  factory Routes.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Routes(
      id: doc.id,
      arrivalTime: data['arrivalTime'] ?? Timestamp.now(),
      chargesPerTon: data['chargesPerTon']?.toDouble() ?? 0.0,
      companyID: data['companyID'] ?? '',
      companyName: data['companyName'] ?? '',
      departureTime: data['departureTime'] ?? Timestamp.now(),
      from: data['from'] ?? '',
      remainingSpace: data['remainingSpace']?.toDouble() ?? 0.0,
      to: data['to'] ?? '',
      trackInfo: data['trackInfo'] ?? '',
    );
  }

  // Method to convert a Routes instance to a map
  Map<String, dynamic> toMap() {
    return {
      'arrivalTime': arrivalTime,
      'chargesPerTon': chargesPerTon,
      'companyID': companyID,
      'companyName': companyName,
      'departureTime': departureTime,
      'from': from,
      'remainingSpace': remainingSpace,
      'to': to,
      'trackInfo': trackInfo,
    };
  }
}
