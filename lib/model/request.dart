// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Request {
  String requestId;
  String userId;
  String senderPhone;
  String receiverPhone;
  Map<String, dynamic> senderAddress;
  Map<String, dynamic> receiverAddress;
  String type;
  String parcelId;
  String paymentMethod;
  String payer;
  double cost;
  String statusRequest;
  String driverId;
  String created;
  Request({
    required this.requestId,
    required this.userId,
    required this.senderPhone,
    required this.senderAddress,
    required this.receiverAddress,
    required this.type,
    required this.parcelId,
    required this.paymentMethod,
    required this.payer,
    required this.cost,
    required this.statusRequest,
    required this.driverId,
    required this.receiverPhone,
    required this.created,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'requestId': requestId,
      'userId': userId,
      'senderAddress': senderAddress,
      'receiverAddress': receiverAddress,
      'type': type,
      'parcelId': parcelId,
      'paymentMethod': paymentMethod,
      'payer': payer,
      'cost': cost,
      'statusRequest': statusRequest,
      'driverId': driverId,
      'receiverPhone': receiverPhone,
      'senderPhone': senderPhone,
      'created': created
    };
  }

  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
        requestId: map['requestId'] ?? "",
        userId: map['userId'] as String,
        senderAddress: Map<String, dynamic>.from(
            (map['senderAddress'] as Map<String, dynamic>)),
        receiverAddress: Map<String, dynamic>.from(
            (map['receiverAddress'] as Map<String, dynamic>)),
        type: map['type'] as String,
        parcelId: map['parcelId'] as String,
        paymentMethod: map['paymentMethod'] as String,
        payer: map['payer'] as String,
        cost: map['cost'] as double,
        statusRequest: map['statusRequest'] as String,
        driverId: map['driverId'] as String,
        receiverPhone: map['receiverPhone'] ?? "",
        senderPhone: map['senderPhone'] ?? "",
        created: map['created'] ?? "");
  }

  String toJson() => json.encode(toMap());

  factory Request.fromJson(String source) =>
      Request.fromMap(json.decode(source) as Map<String, dynamic>);
}
