import 'package:drivers/app/route/route_custom.dart';
import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/store/services.dart';
import 'package:drivers/bindings/login_binding.dart';
import 'package:drivers/firebase_options.dart';
import 'package:drivers/firebase_service/firebase_service.dart';
import 'package:drivers/firebase_service/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseService.firebaseApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.locationWhenInUse.request();
    }
  });
  //clearData();
  await Get.putAsync(
    () => AppServices().init(),
  );
  var controller = AppStore();
  Get.put(controller);
  await controller.init();
  await NotificationService().getDeviceToken();
  await NotificationService().init();

  // await Get.putAsync(() => DeliveryController().onInit());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: LoginBinding(),
      initialRoute: RouteName.loginRoute,
      getPages: RouteCustom.getPage,
    );
  }
}

Future<void> clearData() async {
  var prefs = await SharedPreferences.getInstance();
  prefs.clear();
}
