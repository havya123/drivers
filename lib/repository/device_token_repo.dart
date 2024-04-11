import 'package:drivers/firebase_service/firebase_service.dart';
import 'package:drivers/model/device_token.dart';

class DeviceTokenRepo {
  Future<bool> isExist(String uid) async {
    var response =
        await FirebaseService.deviceToken.where('uid', isEqualTo: uid).get();
    if (response.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> createDeviceToken(String uid, String deviceToken) async {
    bool exist = await isExist(uid);
    if (exist) {
      String currentToken = await getDeviceTokenDoc(uid);
      await FirebaseService.deviceToken
          .doc(currentToken)
          .update({'deviceToken': deviceToken});
    } else {
      await FirebaseService.deviceToken
          .doc()
          .set(DeviceTokenModel(uid: uid, deviceToken: deviceToken));
    }
  }

  Future<DeviceTokenModel> getDeviceToken(String uid) async {
    var response =
        await FirebaseService.deviceToken.where('uid', isEqualTo: uid).get();
    return response.docs.first.data();
  }

  Future<String> getDeviceTokenDoc(String uid) async {
    var response =
        await FirebaseService.deviceToken.where('uid', isEqualTo: uid).get();
    return response.docs.first.id;
  }
}
