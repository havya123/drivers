import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Parcel {
  String parcelId;
  List<String> listImage;
  int dimension;
  double weight;
  String requestId;
  String imageConfirm;
  Parcel({
    required this.parcelId,
    required this.listImage,
    required this.dimension,
    required this.weight,
    required this.requestId,
    required this.imageConfirm,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'parcelId': parcelId,
      'listImage': listImage,
      'dimension': dimension,
      'weight': weight,
      'requestId': requestId,
      'imageConfirm': imageConfirm
    };
  }

  factory Parcel.fromMap(Map<String, dynamic> map) {
    return Parcel(
        parcelId: map['parcelId'] as String,
        listImage: List<String>.from(map['listImage']),
        dimension: map['dimension'] as int,
        weight: map['weight'] as double,
        requestId: map['requestId'] ?? "",
        imageConfirm: map['imageConfirm'] ?? "");
  }

  String toJson() => json.encode(toMap());

  factory Parcel.fromJson(String source) =>
      Parcel.fromMap(json.decode(source) as Map<String, dynamic>);
}
