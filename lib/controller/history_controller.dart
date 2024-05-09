import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/model/request.dart';
import 'package:drivers/model/request_multi.dart';
import 'package:drivers/repository/request_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  RxList<List<Request>> allRequest = <List<Request>>[].obs;
  RxList<List<RequestMulti>> allRequestMulti = <List<RequestMulti>>[].obs;

  RxBool loading = true.obs;
  RxString mode = 'Default'.obs;
  ScrollController titleController = ScrollController();
  final double scrollTo = 60;
  List<String> listType = [
    'Waiting',
    'On Taking',
    'On Delivery',
    'Success',
    'Cancel',
  ];
  RxInt index = 0.obs;

  @override
  Future<HistoryController> onInit() async {
    await getAllRequest();
    loading.value = false;
    return this;
  }

  void scrollTitle(int index) {
    if (titleController.hasClients) {
      double newPosition = index * scrollTo;
      titleController.animateTo(
        newPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void changeIndex(int newIndex) {
    if (index.value < newIndex && newIndex <= 2) {
      index.value = newIndex;
      scrollTitle(index.value);
      return;
    }

    if (index.value < newIndex && newIndex > 2) {
      index.value = newIndex;
      return;
    }

    if (index.value > newIndex && index.value >= 3) {
      index.value = newIndex;
    } else {
      index.value = newIndex;
      scrollTitle(index.value - 1);
    }
  }

  void swipeLeft() {
    if (index.value == 0) {
      return;
    }
    index.value--;
    if (index.value <= 1) {
      scrollTitle(index.value - 1);
    }
  }

  void swipeRight() {
    if (index.value == 4) {
      return;
    }
    index.value++;
    if (index.value <= 2) {
      scrollTitle(index.value);
    }
  }

  Future<void> getAllRequestMulti() async {
    loading.value = true;
    allRequestMulti.clear();
    List<RequestMulti> listRequestMultiCancel = <RequestMulti>[];
    List<RequestMulti> listRequestMultiWaiting = <RequestMulti>[];
    List<RequestMulti> listRequestMultiTaking = <RequestMulti>[];
    List<RequestMulti> listRequestMultiDelivery = <RequestMulti>[];
    List<RequestMulti> listRequestMultiSuccess = <RequestMulti>[];
    listRequestMultiCancel =
        await RequestRepo().getListRequestMultiCancel(AppStore.to.uid.value);
    listRequestMultiWaiting =
        await RequestRepo().getListRequestMultWaiting(AppStore.to.uid.value);
    listRequestMultiSuccess =
        await RequestRepo().getListRequestMultiSuccess(AppStore.to.uid.value);
    listRequestMultiDelivery =
        await RequestRepo().getListRequestMultiDelivery(AppStore.to.uid.value);
    listRequestMultiTaking =
        await RequestRepo().getListRequestMultiTaking(AppStore.to.uid.value);
    allRequestMulti.addAll([
      listRequestMultiWaiting,
      listRequestMultiTaking,
      listRequestMultiDelivery,
      listRequestMultiSuccess,
      listRequestMultiCancel,
    ]);
    loading.value = false;
  }

  Future<void> getAllRequest() async {
    loading.value = true;
    allRequest.clear();
    List<Request> listRequestCancel = <Request>[];
    List<Request> listRequestWaiting = <Request>[];
    List<Request> listRequestTaking = <Request>[];
    List<Request> listRequestDelivery = <Request>[];
    List<Request> listRequestSuccess = <Request>[];
    listRequestCancel = await getListRequestCancel();
    listRequestDelivery = await getListRequestDelivery();
    listRequestSuccess = await getListRequestSuccess();
    listRequestTaking = await getListRequestTaking();
    listRequestWaiting = await getListRequestWaiting();
    allRequest.value = [
      listRequestWaiting,
      listRequestTaking,
      listRequestDelivery,
      listRequestSuccess,
      listRequestCancel,
    ];
    loading.value = false;
  }

  Future<List<Request>> getListRequestCancel() async {
    List<Request> listRequest = [];
    listRequest =
        await RequestRepo().getListRequestCancel(AppStore.to.uid.value);
    return listRequest;
  }

  Future<List<Request>> getListRequestWaiting() async {
    List<Request> listRequest = [];
    listRequest =
        await RequestRepo().getListRequestWaiting(AppStore.to.uid.value);
    return listRequest;
  }

  Future<List<Request>> getListRequestTaking() async {
    List<Request> listRequest = [];
    listRequest =
        await RequestRepo().getListRequestTaking(AppStore.to.uid.value);
    return listRequest;
  }

  Future<List<Request>> getListRequestDelivery() async {
    List<Request> listRequest = [];
    listRequest =
        await RequestRepo().getListRequestDelivery(AppStore.to.uid.value);
    return listRequest;
  }

  Future<List<Request>> getListRequestSuccess() async {
    List<Request> listRequest = [];
    listRequest =
        await RequestRepo().getListRequestSuccess(AppStore.to.uid.value);
    return listRequest;
  }
}
