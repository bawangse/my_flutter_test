import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../basic.dart';
import 'global_data.dart';
import 'local_notice_service.dart';
import 'lunar_calendar.dart';
import 'stringProcess.dart';

// lunar 美/ˈluːnər/ adj.月球的;月亮的---阴历
// solar 美/ˈsoʊlər/ adj.太阳的;---公历
enum BirthdayType { Lunar, Solar }

class BirthdayBasicData {
  /// 姓名
  String? name;

  /// 生日 '19970605'
  String? date;

  ///  类型
  BirthdayType? type;
  BirthdayBasicData({this.name, this.date, this.type});
}

/// 将下列的dart类定义，设置age是可选的
class LunarToday {
  final String name; //姓名
  final String date; //生日 '19970605'
  final BirthdayType type; // 类型
  final String lunarTime; //  阴历生日时间，19970605
  final String solarTime; // 阳历生日时间，比如 1998年7月6日
  final String solarTimeNumber; // 阳历生日时间,19970605
  final bool todayIsVeryHappy; // 是否今天过生日
  final int age; // 年龄

  LunarToday(
      {required this.name,
      required this.date,
      required this.type,
      required this.lunarTime,
      required this.solarTime,
      required this.solarTimeNumber,
      required this.todayIsVeryHappy,
      required this.age});
}

class BirthdayDate {
  /// 从原始数据加工后的生日数据
  List<LunarToday> lunarTodayInfo = [];

  BirthdayDate() {
    log.i('调用生日');
  }

  /// 初始化数据，因为数据从yaml中加载，等待yaml加载完成后调用
  void initBirthdayDate() {
    for (var ele in gData.birthdays) {
      if (strIsEmpty(ele.name) || strIsEmpty(ele.date)) {
        continue;
      }
      if (ele.type == BirthdayType.Lunar) {
        LunarToday lunarToday =
            dateAnalyzing(ele.name!, ele.date!, BirthdayType.Lunar);
        lunarTodayInfo.add(lunarToday);
      } else {
        LunarToday lunarToday =
            dateAnalyzing(ele.name!, ele.date!, BirthdayType.Solar);
        lunarTodayInfo.add(lunarToday);
      }
    }
    timeArrSort();
  }

  List<LunarToday> getLunarTodayInfo() {
    return lunarTodayInfo;
  }

  /// 数据排序
  void timeArrSort() {
// 获取当前时间的时间戳
    final now = DateTime.now().millisecondsSinceEpoch;
    Map<String, int> dayNumObj = {};
    for (var ele in lunarTodayInfo) {
      // ele的日期-now相减，得到天数，正数说明在后面，负数说明在今天之前
      final dayNum = DateTime.parse(ele.solarTimeNumber)
          .difference(DateTime.fromMillisecondsSinceEpoch(now))
          .inDays;
      dayNumObj[ele.solarTimeNumber] = dayNum;
    }
// 按照日期距离今天的天数和时间的先后顺序排序
    lunarTodayInfo.sort((a, b) {
      final aDays = dayNumObj[a.solarTimeNumber];
      final bDays = dayNumObj[b.solarTimeNumber];

      if (aDays != null && bDays != null && aDays != bDays) {
        return aDays.compareTo(bDays);
      } else {
        return DateTime.parse(a.solarTimeNumber)
            .compareTo(DateTime.parse(b.solarTimeNumber));
      }
    });
// 在今天之前的放在一个数组中，之后的放在另一个数组中，然后交换两个数组顺序
    List<LunarToday> nowFront = [];
    List<LunarToday> nowNext = [];
    for (var ele in lunarTodayInfo) {
      final dayNum = dayNumObj[ele.solarTimeNumber];
      if (dayNum != null && dayNum < 0) {
        nowFront.add(ele);
      } else {
        nowNext.add(ele);
      }
    }
    lunarTodayInfo = [...nowNext, ...nowFront];
    // log.i('timeArrSort$birthdayInfo');
  }

  Future<List<LunarToday>> mockNetworkData() async {
    return Future.delayed(
        const Duration(seconds: 3), () => getLunarTodayInfo());
  }

  /// 两个日期是否相同
  bool _isSameMonthDay(int month1, int day1, int month2, int day2) {
    return month1 == month2 && day1 == day2;
  }

  /// 日期解析，参数是公历，比如'19960708'   [ˈænəlaɪzɪŋ] v. 分析 dateAnalyzing('20200404',BirthdayType.Lunar)
  LunarToday dateAnalyzing(String name, String time, BirthdayType type) {
    int year = int.parse(time.substring(0, 4));
    int month = int.parse(time.substring(4, 6));
    int day = int.parse(time.substring(6));

    DateTime today = DateTime.now();
    int todayYear = today.year;
    int todayMonth = today.month;
    int todayDay = today.day;

    // 阴历的年月日转生日
    int changeYear = todayYear;
    int changeMonth = month;
    int changeDay = day;

    if (type == BirthdayType.Lunar) {
      // 这里需要替换为今年的年份
      List<int> lunarCh = LunarCalendarUtil.lunarToSolar(todayYear, month, day);
      changeYear = lunarCh[0];
      changeMonth = lunarCh[1];
      changeDay = lunarCh[2];
    }
    bool isSameMonthDay =
        _isSameMonthDay(changeMonth, changeDay, todayMonth, todayDay);
    String changeMonthStr =
        changeMonth.toString().length == 1 ? '0$changeMonth' : '$changeMonth';
    String changeDayStr =
        changeDay.toString().length == 1 ? '0$changeDay' : '$changeDay';
    return LunarToday(
        name: name,
        date: time,
        type: type,
        lunarTime: '$year年$month月$day日',
        solarTime: '$changeYear年$changeMonth月$changeDay日',
        solarTimeNumber: '$changeYear$changeMonthStr$changeDayStr',
        todayIsVeryHappy: isSameMonthDay,
        age: todayYear - year);
  }

  String? remindBirthday() {
    // 在这里实现提醒逻辑，返回需要提醒的生日字符串，如果没有需要提醒的，则返回 null
    String remindStr = '';
    for (var ele in lunarTodayInfo) {
      if (ele.type == BirthdayType.Lunar) {
        if (ele.todayIsVeryHappy) {
          remindStr +=
              '${ele.name}：阴历生日：${ele.lunarTime}；公历生日：${ele.solarTime}；年龄：${ele.age}；\n';
        }
      } else {
        if (ele.todayIsVeryHappy) {
          remindStr += '${ele.name}：公历生日：${ele.solarTime}；年龄：${ele.age}；\n';
        }
      }
    }
    if (remindStr != '') {
      return remindStr;
    } else {
      return null;
    }
  }

  /// 弹出日期提醒
  void _showReminderDialog(BuildContext context) {
    String? reminder = remindBirthday();
    if (reminder != null) {
      localNoticeService.addNotification('生日通知', reminder, 'birthday');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('生日提醒'),
            content: Text(reminder),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  /// 定时调用
  void showReminder(BuildContext context) {
    // Check if the last reminder time is saved in shared preferences
    SharedPreferences.getInstance().then((prefs) {
      final String? lastReminderTime = prefs.getString('lastReminderTime');
      if (lastReminderTime != null) {
        log.i('lastReminderTime$lastReminderTime');
      }
      // If last reminder time is not saved, show the reminder
      if (lastReminderTime == null) {
        _showReminderDialog(context);
      } else {
        // Calculate the difference between the last reminder time and the current time
        final lastTime = DateTime.parse(lastReminderTime);
        final currentTime = DateTime.now();
        final difference = currentTime.difference(lastTime).inHours;

        // If the difference is greater than or equal to 24 hours, show the reminder
        if (difference >= 24) {
          _showReminderDialog(context);

          // Save the current time as the last reminder time in shared preferences
          prefs.setString('lastReminderTime', currentTime.toString());
        }
      }
    });
  }
}

BirthdayDate birthdayDate = BirthdayDate();
