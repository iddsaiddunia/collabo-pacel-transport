import 'package:cloud_firestore/cloud_firestore.dart';

class LogisticOrder {
  final double amount;
  final bool approvalStatus;
  final String companyID;
  final bool isBreakable;
  final String from;
  final String to;
  final String orderNo;
  final String orderStatus;
  final String packageSize;
  final String packageType;
  final bool paymentStatus;
  final String paymentType;
  final String routeId;
  final String userId;

  LogisticOrder({
    required this.amount,
    required this.approvalStatus,
    required this.companyID,
    required this.isBreakable,
    required this.from,
    required this.to,
    required this.orderNo,
    required this.orderStatus,
    required this.packageSize,
    required this.packageType,
    required this.paymentStatus,
    required this.paymentType,
    required this.routeId,
    required this.userId,
  });

  factory LogisticOrder.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LogisticOrder(
      amount: data['amount'] ?? 0.0,
      approvalStatus: data['approvalStatus'] ?? false,
      companyID: data['companyID'] ?? '',
      isBreakable: data['isBreakable'] ?? false,
      from: data['from'] ?? '',
      to: data['to'] ?? '',
      orderNo: data['orderNo'] ?? '',
      orderStatus: data['orderStatus'] ?? '',
      packageSize: data['packageSize'] ?? '',
      packageType: data['packageType'] ?? '',
      paymentStatus: data['paymentStatus'] ?? false,
      paymentType: data['paymentType'] ?? '',
      routeId: data['routeId'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}