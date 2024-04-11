import 'dart:io';

import 'package:drivers/firebase_service/firebase_service.dart';
import 'package:drivers/model/parcel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ParcelRepo {
  Future<Parcel> getParcelInfor(String parcelId) async {
    var response = await FirebaseService.parcelRef.doc(parcelId).get();

    return response.data() as Parcel;
  }

  Future<void> uploadImage(String parcelId, XFile xFile) async {
    String fileName = xFile.path.split("/").last.toString();
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('images/parcel/$parcelId/parcelImage/$fileName');

      await ref.putFile(File(xFile.path));

      String downloadURL = await ref.getDownloadURL();

      await updateImage(parcelId, downloadURL);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateImage(String parcelId, String imageUrl) async {
    try {
      await FirebaseService.parcelRef
          .doc(parcelId)
          .update({'imageConfirm': imageUrl});
    } catch (e) {
      print(e);
    }
  }
}
