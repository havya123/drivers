import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/bindings/category_bindings.dart';
import 'package:drivers/bindings/delivery_binding.dart';
import 'package:drivers/bindings/delivery_multi_binding.dart';
import 'package:drivers/bindings/delivery_saving_binding.dart';
import 'package:drivers/bindings/pickup_binding.dart';
import 'package:drivers/bindings/login_binding.dart';
import 'package:drivers/middleware/home_middleware.dart';
import 'package:drivers/middleware/login_middleware.dart';
import 'package:drivers/screens/category_screen/category_screen.dart';
import 'package:drivers/screens/delivery_multi_screen/delivery_multi_screen.dart';
import 'package:drivers/screens/delivery_multi_screen/detail_widget/detail_widget.dart';
import 'package:drivers/screens/delivery_saving_screen/delivery_saving_screen.dart';
import 'package:drivers/screens/delivery_screen/delivery_screen.dart';
import 'package:drivers/screens/login_screen/login_screen.dart';
import 'package:drivers/screens/login_screen/otp_screen/otp_screen.dart';
import 'package:drivers/screens/login_screen/phone_registration/phone_register_screen.dart';
import 'package:drivers/screens/pickup_screen/pickup_screen.dart';
import 'package:get/get.dart';

class RouteCustom {
  static final getPage = [
    GetPage(
        name: RouteName.categoryRoute,
        page: () => const CategoryScreen(),
        binding: CategoryBindings(),
        middlewares: [CategoryMiddleware()]),
    GetPage(
      name: RouteName.loginRoute,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      middlewares: [LoginMiddleWare()],
    ),
    GetPage(
      name: RouteName.phoneRegisterRoute,
      page: () => const PhoneRegisterScreen(),
    ),
    GetPage(
      name: RouteName.otpRoute,
      page: () => const OTPScreen(),
    ),
    GetPage(
      name: RouteName.pickupRoute,
      page: () => const PickupScreen(),
      binding: PickupBinding(),
    ),
    GetPage(
      name: RouteName.deliveryRoute,
      page: () => const DeliveryScreen(),
      binding: DeliveryBinding(),
    ),
    GetPage(
      name: RouteName.deliveryMultiRoute,
      page: () => const DeliveryMultiScreen(),
      binding: DeliveryMultiBinding(),
    ),
    GetPage(
      name: RouteName.detailRoute,
      page: () => const DetailScreen(),
    ),
    GetPage(
      name: RouteName.deliverySavingRoute,
      page: () => const DeliverySavingScreen(),
      binding: DeliverySavingBinding(),
    )
  ];
}
