import 'package:drivers/firebase_service/firebase_service.dart';
import 'package:drivers/model/request.dart';
import 'package:drivers/model/request_multi.dart';

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

  Future<void> updateStatusMulti(String requestId, String newStatus) async {
    await FirebaseService.requestMultiRef
        .doc(requestId)
        .update({'statusRequest': newStatus});
  }

  Future<void> updateDriverRequest(String requestID, String driverId) async {
    await FirebaseService.requestRef
        .doc(requestID)
        .update({'driverId': driverId});
  }

  Future<void> updateDriverRequestMulti(
      String requestID, String driverId) async {
    await FirebaseService.requestMultiRef
        .doc(requestID)
        .update({'driverId': driverId});
  }

  Future<RequestMulti?> getRequestMulti(String requestId) async {
    var response = await FirebaseService.requestMultiRef.doc(requestId).get();
    if (response.exists) {
      return response.data();
    }
    return null;
  }

  Future<List<Request>> getHistoryRequest(String userId) async {
    List<Request> listRequest = [];
    var response = await FirebaseService.requestRef
        .where('driverId', isEqualTo: userId)
        .get();
    if (response.docs.isNotEmpty) {
      for (var request in response.docs) {
        listRequest.add(request.data());
      }
    }
    return listRequest;
  }

  Future<List<RequestMulti>> getAllRequestMulti(String userId) async {
    List<RequestMulti> listRequestMulti = [];
    var response = await FirebaseService.requestMultiRef
        .where('driverId', isEqualTo: userId)
        .get();
    if (response.docs.isNotEmpty) {
      for (var requestMulti in response.docs) {
        listRequestMulti.add(requestMulti.data());
      }
    }
    return listRequestMulti;
  }

  Future<List<RequestMulti>> getListRequestMultWaiting(String userId) async {
    List<RequestMulti> listRequest = [];
    var response = await FirebaseService.requestMultiRef
        .where('driverId', isEqualTo: userId)
        .where('statusRequest', isEqualTo: 'waiting')
        .get();
    if (response.docs.isEmpty) {
      return listRequest;
    }
    for (var request in response.docs) {
      listRequest.add(request.data());
    }
    return listRequest;
  }

  Future<List<RequestMulti>> getListRequestMultiCancel(String userId) async {
    List<RequestMulti> listRequest = [];
    var response = await FirebaseService.requestMultiRef
        .where('driverId', isEqualTo: userId)
        .where('statusRequest', isEqualTo: 'cancel')
        .get();
    if (response.docs.isEmpty) {
      return listRequest;
    }
    for (var request in response.docs) {
      listRequest.add(request.data());
    }
    return listRequest;
  }

  Future<List<RequestMulti>> getListRequestMultiTaking(String userId) async {
    List<RequestMulti> listRequest = [];
    var response = await FirebaseService.requestMultiRef
        .where('driverId', isEqualTo: userId)
        .where('statusRequest', isEqualTo: 'on taking')
        .get();
    if (response.docs.isEmpty) {
      return listRequest;
    }
    for (var request in response.docs) {
      listRequest.add(request.data());
    }
    return listRequest;
  }

  Future<List<RequestMulti>> getListRequestMultiDelivery(String userId) async {
    List<RequestMulti> listRequest = [];
    var response = await FirebaseService.requestMultiRef
        .where('driverId', isEqualTo: userId)
        .where('statusRequest', isEqualTo: 'on delivery')
        .get();
    if (response.docs.isEmpty) {
      return listRequest;
    }
    for (var request in response.docs) {
      listRequest.add(request.data());
    }
    return listRequest;
  }

  Future<List<RequestMulti>> getListRequestMultiSuccess(String userId) async {
    List<RequestMulti> listRequest = [];
    var response = await FirebaseService.requestMultiRef
        .where('driverId', isEqualTo: userId)
        .where('statusRequest', isEqualTo: 'success')
        .get();
    if (response.docs.isEmpty) {
      return listRequest;
    }
    for (var request in response.docs) {
      listRequest.add(request.data());
    }
    return listRequest;
  }

  Future<void> deleteRequest(String requestId) async {
    await FirebaseService.requestRef.doc(requestId).delete();
  }

  Future<void> deleteRequestMulti(String requestId) async {
    await FirebaseService.requestMultiRef.doc(requestId).delete();
  }

  Future<List<Request>> getListRequestWaiting(String userId) async {
    List<Request> listRequest = [];
    var response = await FirebaseService.requestRef
        .where('driverId', isEqualTo: userId)
        .where('statusRequest', isEqualTo: 'waiting')
        .get();
    if (response.docs.isEmpty) {
      return listRequest;
    }
    for (var request in response.docs) {
      listRequest.add(request.data());
    }
    return listRequest;
  }

  Future<List<Request>> getListRequestCancel(String userId) async {
    List<Request> listRequest = [];
    var response = await FirebaseService.requestRef
        .where('driverId', isEqualTo: userId)
        .where('statusRequest', isEqualTo: 'cancel')
        .get();
    if (response.docs.isEmpty) {
      return listRequest;
    }
    for (var request in response.docs) {
      listRequest.add(request.data());
    }
    return listRequest;
  }

  Future<List<Request>> getListRequestTaking(String userId) async {
    List<Request> listRequest = [];
    var response = await FirebaseService.requestRef
        .where('driverId', isEqualTo: userId)
        .where('statusRequest', isEqualTo: 'on taking')
        .get();
    if (response.docs.isEmpty) {
      return listRequest;
    }
    for (var request in response.docs) {
      listRequest.add(request.data());
    }
    return listRequest;
  }

  Future<List<Request>> getListRequestDelivery(String userId) async {
    List<Request> listRequest = [];
    var response = await FirebaseService.requestRef
        .where('driverId', isEqualTo: userId)
        .where('statusRequest', isEqualTo: 'on delivery')
        .get();
    if (response.docs.isEmpty) {
      return listRequest;
    }
    for (var request in response.docs) {
      listRequest.add(request.data());
    }
    return listRequest;
  }

  Future<List<Request>> getListRequestSuccess(String userId) async {
    List<Request> listRequest = [];
    var response = await FirebaseService.requestRef
        .where('driverId', isEqualTo: userId)
        .where('statusRequest', isEqualTo: 'success')
        .get();
    if (response.docs.isEmpty) {
      return listRequest;
    }
    for (var request in response.docs) {
      listRequest.add(request.data());
    }
    return listRequest;
  }
}
