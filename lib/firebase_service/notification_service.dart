import 'dart:convert';

import 'package:drivers/app/route/route_name.dart';
import 'package:drivers/app/store/app_store.dart';
import 'package:drivers/app/store/services.dart';
import 'package:drivers/app/util/key.dart';
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
      if (AppStore.to.currentRequest.value == null) {
        if (message.notification != null) {
          if (HomeController.to.available.value == false) {
            return;
          }
          if (message.notification?.body != null) {
            HomeController.to.newRequestComing.value =
                message.notification?.body as String;
            return;
          }
        }
      } else {
        if (message.notification?.body == 'Confirm success') {
          PickupController.waitingConfirm.value = false;
          Get.toNamed(RouteName.deliveryRoute);
          return;
        }
      }
    });
  }

  static String firebaseMessagingScope =
      "https://www.googleapis.com/auth/firebase.messaging";

  // Future<String> getAccessToken() async {
  //   final accountCredentials = ServiceAccountCredentials.fromJson({
  //     "type": "service_account",
  //     "project_id": "delivery-5f21b",
  //     "private_key_id": "32efc4dc73072123c37fee21f40d48a5b80b2d25",
  //     "private_key":
  //         "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQClKaBvaqXp1H6U\nNveca1Iy/5sIIUPzzQRnBHowjjyBUDseU7at2OkWd008DbJX9hVuiMT2rS5234fQ\nHzV01H3DbFG2QWQfSjfRQDrFT3SnkxZktqZlBMf+h/SpxxgGQ+te6VPJ/z1mAizu\nuOJHjJFGIu+fBBh9eTe6H9eTJ8qoVu3MfYEKxLMs24XcaDYj40FTRY0MWJ+tsxNt\njHGqQikL7B+WXH5WHg1r0FC8nPN7StXwvZDLAcxrd1j0YKNxZnaFd8C751hTgro0\nqSt/vyCtQEY3kv/BVWbu8UkTFyrcVnC5i75IrpAyiG/GZvKqUNMuMO/2F6GNNqaJ\nMLEONm35AgMBAAECggEACozysTtcVugan+g1ABqA+T4HzsilOR1HIzePgKuNZOtV\no3XQjSF2nldHqUbsth7Dtrho8KMWfUSBPgPIW+q5D/NK8vwRY8hPcYALYRBW0N+e\nBhf+4CQijHlt4SyVNc0/62O3VQeHig0ohqVr2ws5OoQ/z2YpFFbafvrKwB1CHme4\n2e+qxcBntF8pD06yZb8A89yPVP9sV9Db3JNpIFtNr7VE4Agg5sZOA4xjJT2uO8An\nMm9QzpRehuCKyWGTJLFnrFuARYRM1RMmeTtABbCPn7hlbZcy5xYh+KhUqOkuCRPH\nLDkywavNnJrDm7gntg0NqUpvZU/HV+qLgF2oIroAwwKBgQDcrzZ1JKdVwIEaoxSo\n7FpdwXfMoAIQvnoc7OavEdMQUsAHdIjRhkZn5KtVLuPWOW6+newmBaMnZxctf50Y\nuNo7QP9uhAyjiw9RYxiIsvAimLl9A9M3sfVVuRvcw/DOy1aZ9/9GY+3WaQLhESp/\nXnLtcBkjiPtFMwJDQekAmIK5PwKBgQC/l9l0cB3y0uCs7jBwiqRk0OidYZ8XOIcZ\nsp6/CE9rNmhxc8v5b/qTWFdL3Wkp44OM9/sDnn+waAN9EGV2dtcd1rpDLKjhCCtI\nBPpBVRLo58t6Sk4qzFLDiIy6aYPMaW6gHpBp5gCzZxwvUQ7eO7URSkVfqGJOPuC9\nuSEyKe4SxwKBgQCOfQbxbgApSwlQ9JkjVLAoNwGt+mY6/3GC+accxKp9sKBSb/jj\nKAqPjELf1k2/hQevRfIyvpMQnuyFMQ9y5e/qMFZ8ugAbHG+AgjZWFQsdm3SwdmbL\nYDji54lI6q6yJvI8qbaGcYEgXl9AiL/iy03zZtykaA6tKHk+ifDytIY7KwKBgHRc\nikJwkY/XyYLdyuefHIbqZkynbJMSzuKpnEZTisCHs9krxfdBrkLtBV/bIjLBrjTg\nq0AgdFa0ZWIAok7XkIDb2BZSOmMprfe4pjEltS1lEiy8kkrl+2IsPaQ9z0FHy1tO\nFNFsUoKjHfgS19/bDXZp0EZvovz4rVAs7t9jnecjAoGBAKp74satZOHIm56tJ/Uj\ng5Xfwuh33o8BAbhdc7GDb48eCxeXGMe6OGydqNYd5asM+O2XoOFjF553W0y/2MCQ\nX2yHmx3iaxSSp9QsbRDx+7vfmorwrFxqKyeD2oQCAy4Jn3Xu7CCn2t1qK+CV0YTm\nSKwkduBm1E53iAJ2Gs4K3RrU\n-----END PRIVATE KEY-----\n",
  //     "client_email":
  //         "firebase-adminsdk-oqnhd@delivery-5f21b.iam.gserviceaccount.com",
  //     "client_id": "106244357033130867318",
  //     "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  //     "token_uri": "https://oauth2.googleapis.com/token",
  //     "auth_provider_x509_cert_url":
  //         "https://www.googleapis.com/oauth2/v1/certs",
  //     "client_x509_cert_url":
  //         "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-oqnhd%40delivery-5f21b.iam.gserviceaccount.com",
  //     "universe_domain": "googleapis.com"
  //   });
  //   final client = await clientViaServiceAccount(
  //       accountCredentials, [firebaseMessagingScope]);
  //   final accessToken = client.credentials.accessToken.data;
  //   return accessToken;
  // }

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
          'body': body,
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
