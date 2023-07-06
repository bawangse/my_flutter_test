import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:enough_convert/enough_convert.dart';
import '../basic.dart';
import 'path_config.dart';
// #安卓 #文件
/* 
Directory(path).listSync(recursive: true)
需要在AndroidManifest.xml中添加以下权限：
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.my_flutter_test">
        <!-- 在此处配置权限 -->
        <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
        <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
        <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
   <application
        android:allowBackup="true"
        android:preserveLegacyExternalStorage="true"
        android:requestLegacyExternalStorage="true"
        android:label="my_flutter_test"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

安卓11以上，存储权限发生了很大的变更，如果你获取了文件权限，那么你只能获取媒体文件：图片，视频等。
你不能获取其他类型的文件，比如pdf、txt。。。
进行设置：小米手机-设置-搜索权限-特殊权限设置（隐私保护-保护隐私）-所有文件访问权限，在这里进行设置
两种路径都可以：/storage/emulated/0/aknow/docs/  和 /sdcard/aknow/docs/

来源：在 Android 11 及更高版本中，默认情况下，存储权限仅限于读取媒体文件，以便访问您需要转到设备设置的所有文件设置 > 隐私> 权限管理器 > 文件和媒体，然后选择您的应用程序和单击允许所有文件

不要忘记在 AndroidManifest.xml 文件中设置权限标签

了解更多信息：https ://developer.android.com/about/versions/11/privacy/storage

https://juejin.cn/post/7211422882253537339  
Android操作文件也太难了趴，File vs DocumentFile 以及 DocumentsProvider vs FileProvider 的异同
 */

Future<List<Map<String, dynamic>>> getFiles() async {
  /// path_provider包的测试，只会获取应用内部，无法获取外部
  final types = [
    StorageDirectory.music,
    StorageDirectory.podcasts,
    StorageDirectory.ringtones,
    StorageDirectory.alarms,
    StorageDirectory.notifications,
    StorageDirectory.pictures,
    StorageDirectory.movies,
    StorageDirectory.downloads,
    StorageDirectory.dcim,
    StorageDirectory.documents,
  ];
  await Future.forEach(types, (StorageDirectory type) async {
    // log.i('type$type');
    //这玩意获取的目录看起来是app内部的，不是外部的。"/storage/emulated/0/Android/data/com.example.flutter_test/files/music"
    List<Directory>? dir4 = await getExternalStorageDirectories(type: type);
    // '/storage/emulated/0/Android/data/com.example.flutter_test/files'
    Directory? dir5 = await getExternalStorageDirectory();
    // log.i('dir4:$dir4\ndir5:$dir5');
  });

// 正式开始获取文件
  String path = PathObj.AndroidBasePath;
  log.i(path);
  List<Map<String, dynamic>> fileList = [];

  Directory dir = Directory(path);
  // 下面两种都能获取文件，任意一种都行。
  List<FileSystemEntity> entities = dir.listSync(recursive: true);
  final files = await dir.list(recursive: true).toList();
  log.i('files:$files');

  for (var entity in entities) {
    log.i('entity$entity');
    if (FileSystemEntity.isFileSync(entity.path)) {
      File file = File(entity.path);
      String fileName = file.path.split('/').last;
      DateTime modifiedTime = file.lastModifiedSync();
      String modifiedTimeString =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(modifiedTime);
      String filePath = file.path;
      fileList.add({
        'name': fileName,
        'modifiedTime': modifiedTimeString,
        'path': filePath,
      });
    }
  }

  return fileList;
}

class FileProcess {
  // 从文件中读取字符串
  static Future<String> readFileAsString(File file) async {
    // final text = String.fromCharCodes(bytes);
    String text = '';
    try {
      text = await file.readAsString(encoding: utf8);
    } catch (e) {
      // 如果utf8不行，就找个gbk的
      text = await file.readAsString(
          encoding: const GbkCodec(allowInvalid: false));
      log.i('text$text');
    }
    return text;
  }

  /// 英语词典文件里面读取的数据，保存到一个map中
  Map? dictObj;

  ///获取拼音 https://pub.dev/packages/lpinyin
  ///繁体转简体
  /// 汉字信息库：https://github.com/theajack/cnchar 谷歌搜：github 汉字
  /// 根据字符串获取对应的释义，这里会缓存文件内容
  Future<String> getDictData(String title) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    if (dictObj == null) {
      dictObj = {};
      File dictFile = File(PathObj.androidYamlConfigPath);
      String text = await readFileAsString(dictFile);
      Map jsonResult = json.decode(text);
      for (final item in jsonResult["pepXiaoXue3_2"]) {
        String key = item["headWord"]?.toLowerCase() ?? '';
        dictObj![key] = item['content']['word']['content'];
      }
    }
    if (dictObj == null) return '';
    String dictStr = '';
    final content = dictObj![title];
    if (content != null) {
      final yinBiao =
          '音标：【${content['phone']}】、【${content['usphone']}】、【${content['ukphone']}】';
      final shiYi = content['trans'].toString();
      dictStr = '$yinBiao\n$shiYi';
    }
    log.i('获取数据：$dictStr');
    int endTime = DateTime.now().millisecondsSinceEpoch;
    // 0.842 s
    log.i('获取数据耗时：${(endTime - startTime) / 1000} s');
    return dictStr;
  }

  /// 获取到文件大小后，返回格式化后的文件大小
  String getFileSize(int fileSizeInBytes) {
    String fileSizeString = fileSizeInBytes.toString();
    double fileSizeNum = fileSizeInBytes.toDouble();

    if (fileSizeNum >= 1000000000) {
      // Convert to GB
      fileSizeNum = fileSizeNum / 1000000000;
      fileSizeString = '${fileSizeNum.toStringAsFixed(2)} GB';
    } else if (fileSizeNum >= 1000000) {
      // Convert to MB
      fileSizeNum = fileSizeNum / 1000000;
      fileSizeString = '${fileSizeNum.toStringAsFixed(2)} MB';
    } else if (fileSizeNum >= 1000) {
      // Convert to KB
      fileSizeNum = fileSizeNum / 1000;
      fileSizeString = '${fileSizeNum.toStringAsFixed(2)} KB';
    } else {
      // Leave as bytes
      fileSizeString += ' bytes';
    }
    // log.i('File size is $fileSizeString');
    return fileSizeString;
  }
}

FileProcess fileProcess = FileProcess();
