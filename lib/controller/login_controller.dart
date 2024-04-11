import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/store/services.dart';
import 'package:drivers/app/util/key.dart';
import 'package:drivers/extension/snackbar.dart';
import 'package:drivers/model/driver.dart';
import 'package:drivers/repository/login_repo.dart';
import 'package:drivers/repository/user_repo.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class LoginController extends GetxController {
  late TextEditingController phoneNumber;
  RxBool isSent = false.obs;
  String verifyID = "";

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(15),
    ),
  );

  final errorPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.red),
      borderRadius: BorderRadius.circular(15),
    ),
  );

  @override
  void onInit() async {
    phoneNumber = TextEditingController();
    super.onInit();
  }

  void createAccount(
      String uid, String name, String phoneNumber, String email, String dob) {
    LoginRepo().createAccount(uid, name, phoneNumber, email, dob);
  }

  Future<void> sentOtp(context) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+84${phoneNumber.text}",
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Center(
                        child: Text('The provided phone number is not valid')),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(e.code.toString()),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ],
                  );
                });
            return;
          }
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Center(child: Text('Failed to send OTP')),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(e.code.toString()),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ],
                );
              });
        },
        codeSent: (String verificationId, int? resendToken) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                isSent.value = true;
                return AlertDialog(
                  title: const Center(child: Text('OTP Sent Successfully')),
                  content: const SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text('Your OTP is sent to your phone'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Get.back();
                        Get.toNamed(RouteName.otpRoute);
                      },
                    ),
                  ],
                );
              });
          verifyID = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      return;
    }
  }

  Future<void> confirmOtp(context, String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verifyID,
        smsCode: otp,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      String uid = userCredential.user!.uid;
      String token = await userCredential.user!.getIdToken() as String;

      await AppServices.to.setString(MyKey.token, token);

      bool isExist = await LoginRepo().isExist(uid);
      bool isUser = await LoginRepo().isUser(phoneNumber.text);

      if (isUser) {
        MyDialogs.error(msg: "You have registered as User");
        return;
      } else {
        if (isExist) {
          AppStore.to.saveUser(uid);
          AppStore.to.initUser.value = true;
          Get.toNamed(RouteName.categoryRoute);
        } else {
          createAccount(userCredential.user!.uid, "", phoneNumber.text, "", "");
          AppStore.to.saveUser(uid);
          AppStore.to.initUser.value = true;
          Get.toNamed(RouteName.categoryRoute);
        }
      }
    } catch (e) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Sai mã OTP')),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Bạn đã nhập sai mã OTP. Hãy kiểm tra mã OTP và nhập lại'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
