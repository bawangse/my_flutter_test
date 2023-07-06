import 'package:flutter/material.dart';

import 'basic.dart';
import 'bottom_navigation_bar.dart';
import 'common/local_notice_service.dart';
import 'common/sqlite3_process.dart';
import 'dirthday_page.dart';
import 'dosc_page.dart';
import 'page/config_info_page.dart';
import 'page/read/poemBook.dart';

void main() {
  // basic.globalErrorProcess();
  runApp(const MyApp());
  log.i('当前时间：${basic.getCurrentDate()}');
  basic.getCurrentOS();
  basic.grantPermission();
  basic.test();
  localNoticeService.setup();
  basic.getYamlConfig();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

// 路由映射。
  static final Map<String, WidgetBuilder> _routes = {
    '/know/docs': (BuildContext context) => const DocsPage(),
    '/know/birthday': (BuildContext context) => const BirthdayPage(),
    '/know/config': (BuildContext context) => const ConfigInfo(),
    '/know/poem/book': (BuildContext context) => const PoemBook(),
    // '/know/docs/md': (BuildContext context) => ReadMdPage(),
    // '/': (BuildContext context) => HomePage(),
    // '/details': (BuildContext context) => DetailsPage(),
  };

  @override
  Widget build(BuildContext context) {
    Widget home = MaterialApp(
        title: '你知道',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: _routes,
        home: const SelectionArea(
          child: MainPage(),
        ));

    return WillPopScope(
      onWillPop: () async {
        // 退出前做些其他操作
        sql3.db.dispose();
        return true;
      },
      child: home,
    );
  }
}
