import 'package:drivers/firebase_service/firebase_service.dart';
import 'package:drivers/model/request.dart';

class RequestRepo {
  Future<Request?> getRequest(String requestId) async {
    var response = await FirebaseService.requestRef.doc(requestId).get();
    if (response.exists) {
      return response.data();
    }
    return null;
  }

  Future<List<Request>> getAllRequest(String userId) async {
    List<Request> listRequest = [];
    var response = await FirebaseService.requestRef
        .where('userId', isEqualTo: userId)
        .get();
    if (response.docs.isNotEmpty) {
      for (var request in response.docs) {
        listRequest.add(request.data());
      }
    }
    return listRequest;
  }

  Future<void> updateStatus(String requestId, String newStatus) async {
    await FirebaseService.requestRef
        .doc(requestId)
        .update({'statusRequest': newStatus});
  }

  Future<void> updateDriverRequest(String requestID, String driverId) async {
    await FirebaseService.requestRef
        .doc(requestID)
        .update({'driverId': driverId});
  }
}
