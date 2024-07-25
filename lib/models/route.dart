import 'package:cloud_firestore/cloud_firestore.dart';

class Routes {
  final String trackInfo;
  final Timestamp departureTime;
  final String from;
  final String to;
  final double remainingSpace;
  final String id;
  final String companyID;
  final List<dynamic> route;

  Routes({
    required this.trackInfo,
    required this.departureTime,
    required this.from,
    required this.to,
    required this.remainingSpace,
    required this.id,
    required this.companyID,
    required this.route,
  });

  factory Routes.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Routes(
      trackInfo: data['trackInfo'],
      departureTime: data['depatureTime'],
      from: data['from'],
      to: data['to'],
      remainingSpace: data['remainingSpace'] ?? 0.0,
      id: doc.id,
      companyID: data['companyID'],
      route: data['route'] ?? [],
    );
  }
}
