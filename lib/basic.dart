import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settings_yaml/settings_yaml.dart';
import 'package:universal_io/io.dart';

import 'common/birthday.dart';
import 'common/fileProcess.dart';
import 'common/global_data.dart';
import 'common/path_config.dart';
import 'common/stringProcess.dart';

class Basic {
  /// 遇到问题，会弹出多个toast，且不会终止问题。
  void globalErrorProcess() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      log.i('Global Error Handler: \n$details');
      // Show a notification to the user
      Fluttertoast.showToast(
          msg: 'An error occurred! Please try again later.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      // Do something else, such as sending error reports to your server
    };
  }

  /// 测试临时目录
  Future<void> checkCache() async {
    final cacheDir = await getTemporaryDirectory();
    final cacheDir1 = await getExternalCacheDirectories();
    final cacheDir2 = await getExternalStorageDirectory();
    // "/data/user/0/com.example.flutter_test/cache"
    log.i('Cache Directory: ${cacheDir.path}');
    // "/storage/emulated/0/Android/data/com.example.flutter_test/cache"
    log.i('Cache Directory: $cacheDir1');
    // "/storage/emulated/0/Android/data/com.example.flutter_test/files"
    log.i('Cache Directory: $cacheDir2');
    // cacheDir.delete(recursive: true);
    log.i('Cache cleared.');
    // await DefaultCacheManager().emptyCache(); // 清空应用程序的缓存
  }

  void test() async {
    chineseToArabicTest();
  }

  /// 通用的toast，传递一个str就行
  void toast(String title) async {
    Fluttertoast.showToast(
        msg: title,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.black,
        textColor: Colors.green,
        fontSize: 16.0);
  }

  /// 通用的dialog，传递一个str就行
  void alert(BuildContext context, String title, String content) async {
    ScrollController scrollCrl = ScrollController();
    Widget scrollText = Scrollbar(
      controller: scrollCrl, //必须设置一个controller
      // 不能使用ListView.builder，因为dialog里面需要立即生成的内容
      // thumbVisibility: true, //设置滚动条常亮。只有需要滚动条的时候，才会展示滚动条，否则不会展示。
      child: SingleChildScrollView(
        controller: scrollCrl, //主要要使用和Scrollbar同一个controller
        child: Container(
          // padding: const EdgeInsets.all(16.0),
          child: Text(
            content,
            style: const TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );

    showDialog(
      context: context,
      // 用户可以通过点击对话框外部的区域或按下返回按钮来关闭对话框
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: scrollText,
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // 通过Navigator.of(context).pop(…)方法来关闭对话框的，这和路由返回的方式是一致的，并且都可以返回一个结果数据
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    /* showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
    ); */
  }

  String getCurrentDate() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  void getCurrentOS() async {
    String os = '';
    // 我在mac的google浏览器里面得到了mac，在win的浏览器里面得到了win，都不是浏览器。
    // Platform.operatingSystem也是这个求样子
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        {
          os = 'ios';
        }
        break;
      case TargetPlatform.android:
        {
          os = 'android';
        }
        break;
      case TargetPlatform.linux:
        {
          os = 'linux';
        }
        break;
      case TargetPlatform.macOS:
        {
          os = 'macos';
        }
        break;
      case TargetPlatform.windows:
        {
          os = 'windows';
        }
        break;
      case TargetPlatform.fuchsia:
        {
          // 物联网产品搭载的系统
          os = 'fuchsia';
        }
        break;
      default:
        {
          os = 'web';
        }
        break;
    }
    /* if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      // Some android/ios specific code
    } else if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {
      // Some desktop specific code there
    } else {
      // Some web specific code there
    } */
    // return Platform.operatingSystem;
    String system = Platform.operatingSystem;
    // var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    // 运行提示：Error: Unsupported operation: ServerSocket.bind
    // 如果你在Flutter应用程序中使用ServerSocket.bind方法时出现Unsupported operation: ServerSocket.bind错误，这意味着你正在尝试在Web平台上使用Socket API，而Web平台不支持使用原始Socket API。
    /* 
     Provider[prəˈvaɪdər] 提供器;   医疗服务提供者;   属性;   提供者;   提供程序;  
    FileProvider 文件提供程序，创建一个content:///URI 而不是file:///使安全。
     */
    var server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    log.i('port: ${server.port}');
    log.i('当前系统信息：os:$os,来自defaultTargetPlatform\n operatingSystem：$system\n ');
  }

  /// 获取存储权限。，没有获取就发起请求
  void grantPermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      log.i('已经获取到storage权限');
    } else {
      await Permission.storage.request();
      status = await Permission.storage.status;
      log.i('获取到storage权限的状态：$status');
    }
  }

  /// 获取配置文件yaml的数据
  Future<void> getYamlConfig() async {
    try {
      var path = 'assets/bws_md_config.yaml';
      final configYaml = await rootBundle.loadString(path);
      log.i('configYaml：$configYaml');
    } catch (e) {}

    File yamlFile = File(PathObj.androidYamlConfigPath);
    bool fileExist = await yamlFile.exists();
    if (!fileExist) {
      yamlFile = await yamlFile.create(recursive: true);
      await yamlFile.writeAsString('''
    # 人员生日，type为0表示Lunar-阴历, 1是Solar-公历
birthday:
  [
    { "name": "姓名1", "date": "20200707", "type": 0 },
    { "name": "姓名1", "date": "20200122", "type": 0 },
  ]
    ''');
      log.i('写入yaml文件完成');
    }
    String text = await FileProcess.readFileAsString(yamlFile);
    final config =
        SettingsYaml.load(pathToSettings: PathObj.androidYamlConfigPath);
    // 访问配置项，是数组就返回了数组，比yaml包好用多了
    final birthday = config['birthday'];
    for (var i = 0; i < birthday.length; i++) {
      var item = birthday[i];
      var type = item['type'] == 0 ? BirthdayType.Lunar : BirthdayType.Solar;
      gData.birthdays.add(BirthdayBasicData(
          name: item['name'], date: item['date'], type: type));
    }
    if (gData.birthdays.isNotEmpty) {
      birthdayDate.initBirthdayDate();
    }
    log.i('birthday:$birthday');
  }

  /// 应用的ip
  Future<String> getLocalIpAddress() async {
    String ip = '本地ip---';
    try {
      // NetworkInterface.list()方法返回一个Future,一个包含所有本地网络接口信息的列表
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            ip += '${interface.name}: ${addr.address}；';
          }
        }
      }
    } catch (e) {
      log.i('Error: $e');
    }
    log.i(ip);
    return ip;
  }
}

/* 可选参数声明方式2： 用方括号把可选参数包裹
 Person([this.id, this.age, this.name]);
 Person();
// 或
Person(0, 18);
// 或
Person(0, 18, 'name_of_person');
这种情况下:

调用的时候不会显示参数名.
传参顺序必须按照声明顺序.
传参的时候不能跳过可选参数中间的某个参数, 比如上述例子, 不可以传入id和name而跳过age.
  */
Timer setTimeout(callback, [int duration = 1000]) {
  return Timer(Duration(milliseconds: duration), callback);
}

void clearTimeout(Timer t) {
  t.cancel();
}

extension FunctionExt on Function {
  VoidCallback throttle() {
    return FunctionProxy(this).throttle;
  }

  VoidCallback throttleWithTimeout({int? timeout}) {
    return FunctionProxy(this, timeout: timeout).throttleWithTimeout;
  }

  VoidCallback debounce({int? timeout}) {
    return FunctionProxy(this, timeout: timeout).debounce;
  }
}

class FunctionProxy {
  static final Map<String, bool> _funcThrottle = {};
  static final Map<String, Timer> _funcDebounce = {};
  final Function? target;

  final int timeout;

  FunctionProxy(this.target, {int? timeout}) : timeout = timeout ?? 500;

  void throttle() async {
    String key = hashCode.toString();
    bool enable = _funcThrottle[key] ?? true;
    if (enable) {
      _funcThrottle[key] = false;
      try {
        await target?.call();
      } catch (e) {
        rethrow;
      } finally {
        _funcThrottle.remove(key);
      }
    }
  }

  void throttleWithTimeout() {
    String key = hashCode.toString();
    bool enable = _funcThrottle[key] ?? true;
    if (enable) {
      _funcThrottle[key] = false;
      Timer(Duration(milliseconds: timeout), () {
        _funcThrottle.remove(key);
      });
      target?.call();
    }
  }

  void debounce() {
    String key = hashCode.toString();
    Timer? timer = _funcDebounce[key];
    timer?.cancel();
    timer = Timer(Duration(milliseconds: timeout), () {
      Timer? t = _funcDebounce.remove(key);
      t?.cancel();
      target?.call();
    });
    _funcDebounce[key] = timer;
  }
}

Basic basic = Basic();

Logger log = Logger(
  printer: PrettyPrinter(
      methodCount: 1, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true // Should each log print contain a timestamp
      ),
);
