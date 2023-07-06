import 'package:flutter/material.dart';

class FunctionPage extends StatelessWidget {
  final List<Map<String, dynamic>> _functions = [
    {
      'title': '文档',
      'description': '查看文档列表',
      'route': '/know/docs',
    },
    {
      'title': '生日',
      'description': '查看生日列表',
      'route': '/know/birthday',
    },
    {
      'title': '古文',
      'description': 'soft',
      'route': '/know/poem/book',
    },
    {
      'title': 'config',
      'description': '查看各种配置信息',
      'route': '/know/config',
    },
  ];

  FunctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('功能'),
      ),
      body: ListView.builder(
        itemCount: _functions.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_functions[index]['title']),
            subtitle: Text(_functions[index]['description']),
            onTap: () {
              Navigator.pushNamed(context, _functions[index]['route']);
            },
          );
        },
      ),
    );
  }
}
