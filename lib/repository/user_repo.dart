import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/firebase_service/firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

import '../model/driver.dart';

class DriverRepo {
  Future<Driver?> getUser(String uid) async {
    try {
      DatabaseReference databaseReference =
          FirebaseService.driverRef.child(uid);

      // Listen for the once event
      DatabaseEvent event = await databaseReference.once();

      // Access the snapshot property of the event
      DataSnapshot dataSnapshot = event.snapshot;

      // Check if dataSnapshot.value is a Map
      if (dataSnapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> userData =
            dataSnapshot.value as Map<dynamic, dynamic>;

        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        Map<String, dynamic> userDataStringKey =
            userData.map((key, value) => MapEntry(key.toString(), value));

        return Driver.fromMap(userDataStringKey);
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  isOnline(String uid, bool active) {
    DatabaseReference ref = FirebaseService.driverRef.child(uid);
    ref.update({"active": active});
    ref.onValue.listen((event) {});
  }

  ifOffLine(String uid, bool active) {
    DatabaseReference? ref = FirebaseService.driverRef.child(uid);
    ref.update({"active": active});
    ref.onValue.listen((event) {});
  }

  // Future<void> updateStatus(String uid, bool active) async {
  //   var response =
  //       await FirebaseService.driverRef.where('uid', isEqualTo: uid).get();
  //   if (response.docs.isNotEmpty) {
  //     await FirebaseService.driverRef
  //         .doc(response.docs.first.id)
  //         .update({'active': active});
  //   }
  // }
}
