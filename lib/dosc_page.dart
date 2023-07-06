import 'package:i_konw/page/read/md.dart';
import 'package:universal_io/io.dart';
// 为了使用DateFormat
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'basic.dart';
import 'common/fileProcess.dart';
import 'common/path_config.dart';
import 'common/stringProcess.dart';

class DocsPage extends StatefulWidget {
  const DocsPage({super.key});

  @override
  _DocsPageState createState() => _DocsPageState();
}

enum FileSortEnum { name, modifiedTime, path, work }

class _DocsPageState extends State<DocsPage> {
  List<Map<String, dynamic>> _fileList = [];
  Map<String, dynamic> imgMap = {};

  @override
  void initState() {
    super.initState();
    _getFileList();
  }

  void _getFileList() async {
    String basePath = PathObj.AndroidBasePath;
    if (Platform.isWindows) {
      basePath = PathObj.WinBasePath;
    } else if (Platform.isAndroid) {
      basePath = PathObj.AndroidBasePath;
    }
    // log.i('开始根据目录获取数据：$basePath');
    _fileList = await _getFiles(basePath);
    _sortList(FileSortEnum.modifiedTime);
    // log.i('获取完毕_fileList：$_fileList');
    setState(() {});
  }

  /// 获取path，
  Future<List<Map<String, dynamic>>> _getFiles(String path) async {
    log.i('获取目录：$path');
    List<Map<String, dynamic>> fileList = [];
    Directory dir = Directory(path);
    List<FileSystemEntity> entities = dir.listSync(recursive: true);

    for (var entity in entities) {
      // log.i('entity$entity');
      var path = entity.path;
      if (FileSystemEntity.isFileSync(path)) {
        if (path.contains(PathObj.WikiImg)) {
          var name = path.split('/').last;
          // 通过创建Uri对象的方式将本地文件路径转换为http链接
          // 事实证明，Image.network装载file:///无法展示图片。
          final uri = Uri.file(path);
          // imgMap[name] = uri.toString();
          // 需要再 lib/source/markdown_widget/lib/widget/inlines/img.dart 进行修改
          imgMap[name] = path;
        }
        if (!entity.path.endsWith('.md')) {
          continue;
        }
        File file = File(entity.path);
        int fileSizeInBytes = file.lengthSync();
        String size = fileProcess.getFileSize(fileSizeInBytes);
        String fileName = file.path.split('/').last;
        DateTime modifiedTime = file.lastModifiedSync();
        String modifiedTimeString =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(modifiedTime);
        String filePath = file.path;
        String text = await FileProcess.readFileAsString(file);
        int work = 0;
        if (text.contains('#面试')) {
          work = 1;
        }
        fileList.add({
          'name': fileName,
          'modifiedTime': modifiedTimeString,
          'path': filePath,
          'simplePath': filePath.replaceAll(PathObj.AndroidBasePath, ''),
          'size': size,
          'work': work, // 文件里面是否有面试，有的话权重提高
        });
      }
    }
    // log.i('imgMap$imgMap');
    return fileList;
  }

// 下次排序按反方向来。如果要每个排序按钮都互不干扰，那么应该每个按钮都有个变量记录，懒得搞那么多，就这样吧
  bool _reverse = false;
  void _sortList(FileSortEnum sortType) {
    switch (sortType) {
      case FileSortEnum.name:
        _fileList.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case FileSortEnum.modifiedTime:
        _fileList
            .sort((a, b) => b['modifiedTime'].compareTo(a['modifiedTime']));
        break;
      case FileSortEnum.path:
        _fileList.sort((a, b) => a['path'].compareTo(b['path']));
        break;
      case FileSortEnum.work:
        _fileList
            .sort((a, b) => b['modifiedTime'].compareTo(a['modifiedTime']));
        _fileList.sort((a, b) => b['work'].compareTo(a['work']));
        break;
      default:
        break;
    }
    if (_reverse) {
      _fileList = _fileList.reversed.toList();
    }
    _reverse = !_reverse;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文档列表'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                child: const Text('按名称排序'),
                onPressed: () {
                  _sortList(FileSortEnum.name);
                },
              ),
              TextButton(
                child: const Text('修改日期'),
                onPressed: () {
                  _sortList(FileSortEnum.modifiedTime);
                },
              ),
              TextButton(
                child: const Text('路径'),
                onPressed: () {
                  _sortList(FileSortEnum.path);
                },
              ),
              TextButton(
                child: const Text('面试'),
                onPressed: () {
                  _sortList(FileSortEnum.work);
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _fileList.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> item = _fileList[index];
                // log.i('_fileList${_fileList.toString()}');
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text(
                      '${item['size']} ${item['modifiedTime']} \n${item['simplePath']}'),
                  onTap: () {
                    _openFile(item, context);
                    log.i('打开文件:$item');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// md的字符串处理
  String mdDataProcess(String text, String fileName) {
// text如果是md，需要替换其中的图片
    // flutter,对一个字符串进行正则替换，要求替换的正则
    RegExp regExp = RegExp(r'\]\((.*?)\)');
    // var text = '123](./img/vscode-git-source-repeat.png)456](./img/vscode-git-source-repeat.png)777';
    var text1 = text.replaceAllMapped(regExp, (Match m) {
      log.i(m[0]);
      Iterable<Match> matches = regExp.allMatches(text);
      String? matchedStr = matches.first.group(1);
      if (m[0] == null || matchedStr == null) return '';
      String str = m[0]!;
      str = str.substring(2);
      str = str.substring(0, str.length - 1);
      log.i('str:---$str');

      if (str.contains('/') &&
          !str.contains('://') &&
          (str.contains('.png') ||
              str.contains('.jpg') ||
              str.contains('.jpeg') ||
              str.contains('.webp') ||
              str.contains('.gif'))) {
        var name = str.split('/').last;
        var imagePath = imgMap[name];
        if (imagePath != null) {
          str = imagePath;
        }
      }
      log.i('matchedStr:$str');
      return ']($str)';
    });
    String text2 = splitLongLines(text1);
    return text2;
  }

  void _openFile(Map<String, dynamic> fileInfo, BuildContext context) async {
    try {
      String title = fileInfo['name'];
      File file = File(fileInfo['path']);
      log.i('file:$file');
      if (kIsWeb) {
        final url = file.uri.toString();
        await launch(
          url,
          forceSafariVC: false,
          forceWebView: false,
        );
      } else {
        final bytes = await file.readAsBytes();
        if (title.endsWith('.txt') || title.endsWith('.md')) {
          String text = await FileProcess.readFileAsString(file);
          String text1 = mdDataProcess(text, fileInfo['name']);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReadMdPage(text1, fileInfo['name']),
            ),
          );
        } else if (title.endsWith('.pdf')) {
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/$title';
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (context) => PDFViewerScaffold(
          //       appBar: AppBar(
          //         title: Text(title),
          //       ),
          //       path: filePath,
          //     ),
          //   ),
          // );
        } else {
          basic.alert(context, '文件类型不支持', '暂不支持打开该类型的文件');
        }
      }
    } catch (e) {
      log.i(e);
    }
  }
}
