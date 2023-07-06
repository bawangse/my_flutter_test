// 为了使用DateFormat

import 'package:flutter/material.dart';

import 'basic.dart';
import 'common/birthday.dart';

class Birthday {
  final String name;
  final String date; // 生日日期，格式为 yyyyMMdd
  final int type; // 生日类型，1 为公历，2 为阴历

  const Birthday({
    required this.name,
    required this.date,
    required this.type,
  });
}

class BirthdayPage extends StatefulWidget {
  const BirthdayPage({super.key});

  @override
  _BirthdayPageState createState() => _BirthdayPageState();
}

class _BirthdayPageState extends State<BirthdayPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('生日列表'),
      ),
      body: Column(
        children: [
          Expanded(
            // 请求数据后展示，不过好像没用
            /* child: FutureBuilder<List<LunarToday>>(
              future: birthdayDate.mockNetworkData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                // 请求已结束
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    // 请求失败，显示错误
                    return Text("Error: ${snapshot.error}");
                  } else {
                    // 请求成功，显示数据
                    return ListView.builder(
                    );
                  }
                } else {
                  // 请求未结束，显示loading
                  // return const CircularProgressIndicator();
                }
              },
            ), */
            child: ListView.builder(
              itemCount: birthdayDate.lunarTodayInfo.length,
              itemBuilder: (BuildContext context, int index) {
                String subtitle = '';
                log.i(birthdayDate.lunarTodayInfo[index]);
                LunarToday ele = birthdayDate.lunarTodayInfo[index];
                if (ele.type == BirthdayType.Lunar) {
                  subtitle =
                      '${ele.todayIsVeryHappy ? "今天过生日耶；\n" : ""}公历生日：${ele.solarTime}；阴历生日：${ele.lunarTime}；年龄：${ele.age}；';
                } else {
                  subtitle =
                      '${ele.todayIsVeryHappy ? "今天过生日耶；\n" : ""}公历生日：${ele.solarTime}；年龄：${ele.age}；';
                }
                return ListTile(
                  title: Text(ele.name),
                  subtitle: Text(subtitle),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
