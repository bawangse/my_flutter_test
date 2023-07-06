/* 
通知，案例地址：https://www.kodeco.com/34019063-creating-local-notifications-in-flutter
一次只能发一个通知：id相同，那么后面的通知会覆盖前面的通知

 */
// 设置和发送本地通知
import 'dart:math' as math;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

import '../basic.dart';

// 根据通知包使用的用户时区创建时间对象
class LocalNoticeService {
// 初始化本地通知插件
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

// 为每个平台初始化插件
  Future<void> setup() async {
    // 参数是图标地址，android/app/src/main/res/drawable
    // android:icon="@mipmap/ic_launcher"
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');

    // #2
    const initSettings = InitializationSettings(android: androidSetting);

    // #3
    await _localNotificationsPlugin.initialize(initSettings).then((_) {
      log.i('setupPlugin: 通知 setup success');
    }).catchError((Object error) {
      log.i('通知初始化失败-Error: $error');
    });
  }

/** 
channel,用于区分应用发出的不同通知。该值在 iOS 上被忽略

 */
  Future<void> addNotification(
    String title,
    String body,
    String channel,
  ) async {
    // #1 初始化时区数据并定义唤醒通知的时间。由于插件用作tz.TZDateTime时间的输入，因此您需要将endTime值转换为tz.TZDateTime
    tzData.initializeTimeZones();
// 如果使用fromMillisecondsSinceEpoch， 那么 endTime可以传递参数 DateTime .now().millisecondsSinceEpoch + 1000
    final scheduleTime =
        // tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, endTime);
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    // #2 定义了通知的详细信息。androidDetail详细信息包含每个平台（和）的通知设置iosDetail，例如启用/禁用声音和徽章。请注意，您需要为 Android 定义通知的通道 ID 和名称。通道用于区分不同的通知。
    final androidDetail = AndroidNotificationDetails(
        channel, // channel Id
        channel // channel Name
        );

    // final iosDetail = IOSNotificationDetails();

    final noticeDetail = NotificationDetails(
      // iOS: iosDetail,
      android: androidDetail,
    );

    // #3  定义通知的 ID。当您想取消特定通知时，它很有用。在本教程中，您不需要取消任何特定的通知。因此，您可以对所有通知使用 0。
    // const id = 0;
    int id = math.Random().nextInt(100);

    // #4  根据用户的时区安排通知
    await _localNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduleTime,
      noticeDetail,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  /// 取消通知
  ///
  void cancelAllNotification(int? notificationId) {
    if (notificationId != null) {
      _localNotificationsPlugin.cancel(notificationId);
    }
    _localNotificationsPlugin.cancelAll();
  }
}

LocalNoticeService localNoticeService = LocalNoticeService();
