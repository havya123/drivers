import 'dart:convert';

import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/store/services.dart';
import 'package:drivers/app/util/key.dart';
import 'package:drivers/controller/delivery_saving_controller.dart';
import 'package:drivers/controller/home_controller.dart';
import 'package:drivers/controller/pickup_controller.dart';
import 'package:drivers/repository/device_token_repo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> init() async {
    initialize();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await messaging.subscribeToTopic("Test");
    messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (AppStore.to.currentRequest.value == null &&
          AppStore.to.mode.value == "express") {
        if (message.notification != null) {
          if (HomeController.to.available.value == false) {
            return;
          }
          if (message.notification?.body != null) {
            Map<String, dynamic> response =
                jsonDecode(message.notification?.body as String);
            if (response['requestType'] == AppStore.to.mode.value ||
                response['requestType'] == "requestMulti") {
              HomeController.to.newRequestComing.value = response['requestId'];
              HomeController.to.requestType.value = response['requestType'];
              AppStore.to.requestType.value = response['requestType'];
            } else {
              await declineRequest(response['deviceToken']);
            }

            return;
          }
        }
      } else {
        if (message.notification?.body == 'Confirm success') {
          if (AppStore.to.requestType.value == 'express') {
            PickupController.waitingConfirm.value = false;
            Get.toNamed(RouteName.deliveryRoute);
            return;
          }
          if (AppStore.to.requestType.value == 'requestMulti') {
            PickupController.waitingConfirm.value = false;
            Get.toNamed(RouteName.deliveryMultiRoute);
          }
        }
        if (message.notification?.body == "Confirm success saving") {
          var controller = Get.find<DeliverySavingController>();
          if (controller.waitingConfirm.value) {
            controller.listDoneSaving.add(controller.nameLocation.value);
            controller.index++;
            controller.changeLocation();
            AppServices.to.setString(
                MyKey.listDoneSaving, jsonEncode(controller.listDoneSaving));
            controller.waitingConfirm.value = false;
          }
          return;
        }
      }
    });
  }

  static String firebaseMessagingScope =
      "https://www.googleapis.com/auth/firebase.messaging";

//  /* Future<String> getAccessToken() async {
//     final accountCredentials = ServiceAccountCredentials.fromJson({
//       "type": "service_account",
//       "project_id": "delivery-5f21b",
//       "private_key_id": "e33b9e3194ec0ede2f53f81b9225de0d49458fce",
//       "private_key":
//           "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDNaASbNoiipIbE\n27+IeeAjZ8VZYrZzGCtoDQQ+PUGcMRCUJlLaNmtoA/nmE+JROQC9yBgNd32axzHU\nnF7S6vmeOD1e6rPhKEI5XfFcmqmccVOMUfh+VIWwWRaSYz/wvb6COuskiEF48QvQ\ndIH1mW6ZsxjtGE3/vZEpOsKUYreAXM3X9DMGkArzOM8kbJzyLyz8v4HlJelbd22B\nhVV+aJRTVYPTJMjYk/gVt64yzYln5F28OaGbtI/rFROFpj8emlEIY1+3e/3RLK81\nooCnL8bxa2kM1B5KuANw6UhlenxxNVWEoJUVXPLEb7eMSp328fVg105kAzC69oFN\nNFfuG11zAgMBAAECggEAR60VdmgIM+D/mjAoXOJSgWhTqEZW7kCv3OY15dYQUAWb\nCGd7H+Q/hJNmn4+uuLMQfCkXo5NfxCPgUpWiTS1rn3d2iumRjW8z9LrAX5UkvI+b\nHOr5sHOkFw5vXvO9Oy+rC9ytcxkM57wNaFdPhjldK8sgVpPVm/k1b1Ku1YLBD8wy\nZdc0qLcyuyv2YqZ5f4IuWe6Vtbf2sLjmDf87/5ecj9A6rCdYTdVcM35cQNpEkyxj\nfVxNLUsKdtg/s7zj+EMGpsfKXDjOmXL6Wc/nt8X/WP/kDk8PhrwfkBh6KX9spj9j\nPo3VfctVcNavezVLwVgkfEJdNO/Ok05EAFFpz2H9UQKBgQDvNPVszTzSTkUjpCWa\ncrNM4ykVqra3Pzl+WlHswCQ7xuvNkMPnZZ803psWAn9FwxTcDEQ0FO++P4mIYTRc\nao/yefQX6vovfXTJ8t+NPTuMiqtGWg7T/JFmxhTvJHvYrmTBcl0oG7AWnZLnalyI\nSDQCbP429OhMJK0ZXcCm/kSfqQKBgQDb05f48hkYlH0VZwk6M1J7F+569Nf9v1Ww\n1hLBeGiL0wc7L6DCw4ZDqLn5+pFYo5/YcfTW+BXPzUx94JzUavQjf3xJWs5GhwPO\nPJc1jYKMvBTJEG5hYPjhX/N6EHj0/V8E3VvW91CyD0lCP1E4i5rEgNoMjMT+gBcm\n3kDEcH71uwKBgCJi3Yj3c+/TepLmDNXH+UhrO0O3F6798rjcKPy8njjNnqYdUlwY\nOqux+F9QmpUftwbu6HsIK3KQ1ad6ObmzQ+AaceFiUPa0tS42sLYwADhy0q45Ufpd\nS1WX0fiSqQ77+tXoJ8YVPNnzauPDYWvh3UAgBOdHi4EuoIeN95zJ3nmJAoGBAK8W\ndloTQkfgpUwxuBjCHfTrF8iZUZvLFM53g5LTe7m6yGysv8fBAiTLs+1WVQQbt0on\nYdMC4CSWKVGtYFyUH4ZSmUS37cog6bgPbIR8BLphZ9DJpJEtMq4XxY64pg7D7DWs\nteSfMYfRQxFf6yo1j3zqAEK0sIbgsRAFP+L2kzjXAoGBAN+gbSErledu+ZGdnZ4T\nauWad4PnWQdUzXI81YUcN7ZSAPpNMcH9haJIlm3RqSjFtZ2yD3EiMX2FiGGq8+YX\n79O9LEM/ClslcD5Vt0sAsPWK5bh/e98mcvXBDoJywqbhTLSYhNnLSNmQe4YukCEj\nrnf4Y5A3BUhNLk7FJoYGiJ5w\n-----END PRIVATE KEY-----\n",
//       "client_email": "delivery-5f21b@appspot.gserviceaccount.com",
//       "client_id": "106494490895015421787",
//       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//       "token_uri": "https://oauth2.googleapis.com/token",
//       "auth_provider_x509_cert_url":
//           "https://www.googleapis.com/oauth2/v1/certs",
//       "client_x509_cert_url":
//           "https://www.googleapis.com/robot/v1/metadata/x509/delivery-5f21b%40appspot.gserviceaccount.com",
//       "universe_domain": "googleapis.com"
//     });
//     final client = await clientViaServiceAccount(
//         accountCredentials, [firebaseMessagingScope]);
//     final accessToken = client.credentials.accessToken.data;
//     return accessToken;
//   }*/

  Future<void> sendNotification(
      String receiverDeviceToken, dynamic title, dynamic body) async {
    String accessToken = await getAccessToken();
    const String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/delivery-5f21b/messages:send';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken }',
      'Priority': 'high',
    };

    final Map<String, dynamic> data = {
      'message': {
        'token': receiverDeviceToken,
        'notification': {
          'title': title,
          'body': body is String ? body : jsonEncode(body),
        },
      },
    };

    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    print(response);

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification');
    }
  }

  Future<void> declineRequest(String receiverDeviceToken) async {
    String accessToken = await getAccessToken();
    const String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/delivery-5f21b/messages:send';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken }',
    };

    final Map<String, dynamic> data = {
      'message': {
        'token': receiverDeviceToken,
        'notification': {
          'title': 'Request Declined',
          'body': "Request Declined",
        },
      },
    };

    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    print(response);

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification');
    }
  }

  Future<void> getDeviceToken() async {
    var mess = FirebaseMessaging.instance;
    String deviceToken = await mess.getToken() ?? "";
    print(deviceToken);
    await AppServices.to.setString(MyKey.deviceToken, deviceToken);
    await DeviceTokenRepo()
        .createDeviceToken(AppStore.to.uid.value, deviceToken);
  }

  void initialize() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  void showNotification(RemoteMessage message) {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
          "com.example.drivers1", "push_notification",
          importance: Importance.max, priority: Priority.high),
    );
    localNotificationsPlugin.show(
        DateTime.now().microsecond,
        message.notification?.title ?? "",
        message.notification?.body ?? "",
        notificationDetails,
        payload: message.data.toString());
  }
}
