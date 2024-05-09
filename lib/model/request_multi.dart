// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class RequestMulti {
  String requestId;
  String userId;
  String senderPhone;
  Map<String, dynamic> senderAddress;
  List<Map<String, dynamic>> receiverAddress;
  List<String> parcelId;
  String paymentMethod;
  String payer;
  double cost;
  String statusRequest;
  String driverId;
  String created;

  RequestMulti({
    required this.requestId,
    required this.userId,
    required this.senderPhone,
    required this.senderAddress,
    required this.receiverAddress,
    required this.parcelId,
    required this.paymentMethod,
    required this.payer,
    required this.cost,
    required this.statusRequest,
    required this.driverId,
    required this.created,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'requestId': requestId,
      'userId': userId,
      'senderPhone': senderPhone,
      'senderAddress': senderAddress,
      'receiverAddress': receiverAddress,
      'parcelId': parcelId,
      'paymentMethod': paymentMethod,
      'payer': payer,
      'cost': cost,
      'statusRequest': statusRequest,
      'driverId': driverId,
      'created': created,
    };
  }

  factory RequestMulti.fromMap(Map<String, dynamic> map) {
    return RequestMulti(
      requestId: map['requestId'] as String,
      userId: map['userId'] as String,
      senderPhone: map['senderPhone'] as String,
      senderAddress: Map<String, dynamic>.from(
          (map['senderAddress'] as Map<String, dynamic>)),
      receiverAddress: (map['receiverAddress'] as List<dynamic>)
          .cast<Map<String, dynamic>>(),
      parcelId: (map['parcelId'] as List<dynamic>).cast<String>(),
      paymentMethod: map['paymentMethod'] as String,
      payer: map['payer'] as String,
      cost: map['cost'] as double,
      statusRequest: map['statusRequest'] as String,
      driverId: map['driverId'] as String,
      created: map['created'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory RequestMulti.fromJson(String source) =>
      RequestMulti.fromMap(json.decode(source) as Map<String, dynamic>);
}
