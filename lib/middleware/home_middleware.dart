import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/store/app_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (AppStore.to.onDelivery.value) {
      if (AppStore.to.currentRequest.value?.statusRequest == 'on delivery') {
        if (AppStore.to.requestType.value == "express") {
          return RouteSettings(name: RouteName.deliveryRoute);
        }
        if (AppStore.to.requestType.value == "requestMulti") {
          return RouteSettings(name: RouteName.deliveryMultiRoute);
        }
      }
      if (AppStore.to.currentRequest.value?.statusRequest == 'on taking') {
        return RouteSettings(name: RouteName.pickupRoute);
      }
      if (AppStore.to.mode.value == "saving") {
        return RouteSettings(name: RouteName.deliverySavingRoute);
      }
    }
    return null;
  }
}
