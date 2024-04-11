import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/store/app_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (AppStore.to.onDelivery.value) {
      if (AppStore.to.currentRequest.value?.statusRequest == 'on delivery') {
        return RouteSettings(name: RouteName.deliveryRoute);
      }
      if (AppStore.to.currentRequest.value?.statusRequest == 'on taking') {
        return RouteSettings(name: RouteName.pickupRoute);
      }
    }
    return null;
  }
}
