import 'package:drivers/firebase_service/firebase_service.dart';
import 'package:drivers/model/driver.dart';

class LoginRepo {
  Future<void> createAccount(String uid, String name, String phoneNumber,
      String email, String dob) async {
    Map<String, dynamic> driverData = Driver(
      uid: uid,
      phoneNumber: phoneNumber,
      email: email,
      dob: dob,
      userName: "",
      avatar:
          "https://png.pngtree.com/element_our/20200610/ourmid/pngtree-character-default-avatar-image_2237203.jpg",
      active: false,
    ).toMap();

    await FirebaseService.driverRef.child(uid).set(driverData);
  }

  Future<bool> isExist(String uid) async {
    try {
      FirebaseService.driverRef.child(uid).once().then((value) {
        if (value.snapshot.exists) {
          return true;
        }
      });
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUser(String phoneNumber) async {
    var response = await FirebaseService.userRef
        .where("phoneNumber", isEqualTo: phoneNumber)
        .get();
    if (response.docs.isNotEmpty) {
      return true;
    }
    return false;
  }
}
