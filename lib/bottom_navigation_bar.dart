// 底部菜单
// BottomNavigationBar 组件是 Material 设计规范中的一部分
import 'dart:async';

import 'package:flutter/material.dart';

import 'basic.dart';
import 'common/birthday.dart';
import 'common/poem.dart';
import 'function_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late Timer _timer;

  final List<Widget> _children = [
    FunctionPage(),
    // RecentPage(),
    // SettingPage(),
  ];

  @override
  void initState() {
    super.initState();
    // 渲染 渲染结束 渲染完毕
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log.i('主页，执行检查111');
      showDialogForPoem(context);
      birthdayDate.showReminder(context);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _timer = Timer.periodic(const Duration(hours: 24), () {
    // });
    return Scaffold(
      appBar: AppBar(
        title: Text('i-${basic.getCurrentDate()}'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.amber[800],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: '功能',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: '最近',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
