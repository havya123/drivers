import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/store/app_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginMiddleWare extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return AppStore.to.user.value != null
        ? RouteSettings(name: RouteName.categoryRoute)
        : null;
  }
}
