// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DeviceTokenModel {
  String uid;
  String deviceToken;
  DeviceTokenModel({
    required this.uid,
    required this.deviceToken,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'deviceToken': deviceToken,
    };
  }

  factory DeviceTokenModel.fromMap(Map<String, dynamic> map) {
    return DeviceTokenModel(
      uid: map['uid'] as String,
      deviceToken: map['deviceToken'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceTokenModel.fromJson(String source) =>
      DeviceTokenModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
