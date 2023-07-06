// 为了使用DateFormat

import 'package:flutter/material.dart';
import 'package:i_konw/basic.dart';

class ConfigInfo extends StatefulWidget {
  const ConfigInfo({super.key});

  @override
  _ConfigInfoState createState() => _ConfigInfoState();
}

class _ConfigInfoState extends State<ConfigInfo> {
  final List<Map<String, dynamic>> infos = [
    {'name': '网络', 'subtitle': ''}
  ];
  @override
  void initState() {
    super.initState();
    _getFileList();
  }

  void _getFileList() async {
    String ip = await basic.getLocalIpAddress();
    infos[0]['subtitle'] = ip;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配置信息'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: infos.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> ele = infos[index];
                return ListTile(
                  title: Text(ele['name']),
                  subtitle: Text(ele['subtitle']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
