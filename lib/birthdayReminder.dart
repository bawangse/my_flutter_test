import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'basic.dart';
import 'common/birthday.dart';

class BirthdayReminder extends StatefulWidget {
  const BirthdayReminder({super.key});

  @override
  _BirthdayReminderState createState() => _BirthdayReminderState();
}

class _BirthdayReminderState extends State<BirthdayReminder> {
  String _lastRemindDate = '';

  @override
  void initState() {
    super.initState();
    _loadLastRemindDate();
  }

  void _loadLastRemindDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastRemindDate = prefs.getString('lastRemindDate')!;
    });
  }

  void _saveLastRemindDate(String date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastRemindDate', date);
  }

  void _showReminder(String birthday) {
    basic.alert(context, 'Reminder生日提醒', birthday);
  }

  void _checkReminder() {
    log.i('生日，调用检查');
    String today = DateTime.now().toString().substring(0, 10);
    if (_lastRemindDate != today) {
      String? reminder = birthdayDate.remindBirthday(); // 调用提醒方法
      if (reminder != null) {
        _showReminder(reminder);
        _saveLastRemindDate(today);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkReminder(); // 检查提醒
    return Scaffold(
      appBar: AppBar(
        title: const Text('Birthday Reminder'),
      ),
      body: const Center(
        child: Text('Welcome to Birthday Reminder!'),
      ),
    );
  }
}
