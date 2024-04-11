import 'package:drivers/app/util/const.dart';
import 'package:drivers/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xffD8DADC)),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  spaceHeight(context),
                  Container(
                    width: getWidth(context, width: 0.7),
                    height: getHeight(context, height: 0.3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.yellow),
                  ),
                  spaceHeight(context),
                  const Text(
                    "Enter Code",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  spaceHeight(context),
                  Pinput(
                    length: 6,
                    defaultPinTheme: controller.defaultPinTheme,
                    validator: (value) {
                      controller.confirmOtp(context, value!);
                      return null;
                    },
                  ),
                  spaceHeight(context, height: 0.2),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     const Text("Send code again?"),
                  //     Obx(() => controller.countdown.value != 0
                  //         ? Text(
                  //             "${controller.countdown.value}",
                  //             style: const TextStyle(color: Colors.blue),
                  //           )
                  //         : TextButton(
                  //             onPressed: () {
                  //               controller.resetCountDown();
                  //             },
                  //             child: const Text(
                  //               "Send code",
                  //               style: TextStyle(color: Colors.blue),
                  //             )))
                  //   ],
                  // ),
                  spaceHeight(context),
                  // ButtonWidget(
                  //   function: () {},
                  //   textButton: "Continue",
                  // )
                ]),
          ),
        ),
      ),
    );
  }
}
