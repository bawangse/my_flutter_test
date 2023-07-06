import 'package:flutter/foundation.dart';
import 'package:i_konw/page/read/md.dart';
import 'package:universal_io/io.dart';
// 为了使用DateFormat
import 'package:flutter/material.dart';

import '../../basic.dart';
import '../../common/fileProcess.dart';
import '../../common/path_config.dart';

/// 获取文件列表参数类
class PoemBookFilesParams {
  String path;

  /// 是否要进行耗时操作，isTakeTime ,如果不想进行耗时操作，就传递false；
  bool isTakeTime;
  PoemBookFilesParams(this.path, this.isTakeTime);
}

/* 
flutter，给函数设置对象参数
如果不想设置参数类呢
 */
/// 获取文件列表，文件的path和
Future<List<Map<String, dynamic>>> getPoemBookFiles(
    PoemBookFilesParams params) async {
  String path = params.path;
  bool isTakeTime = params.isTakeTime;
  log.i('获取目录：$path');
  int startTime = DateTime.now().millisecondsSinceEpoch;
  List<Map<String, dynamic>> fileList = [];
  Directory dir = Directory(path);
  // 不递归获取，只要当前的目录，获取到书籍
  List<FileSystemEntity> entities = dir.listSync(recursive: false);

  for (var entity in entities) {
    // log.i('entity$entity');
    var path = entity.path;
    if (FileSystemEntity.isDirectorySync(path)) {
      String size = '未获取';
      if (isTakeTime) {
        Directory dir = Directory(path);
        List<FileSystemEntity> entities2 = dir.listSync(recursive: true);
        int fileSizeInBytes = 0;
        for (var entity2 in entities2) {
          var path2 = entity2.path;
          if (path2.contains('bitext.txt')) {
            File file = File(path2);
            fileSizeInBytes += file.lengthSync();
          }
        }
        size = fileProcess.getFileSize(fileSizeInBytes);
      }

      String fileName = path.split('/').last;
      fileList.add({
        'name': fileName,
        'path': path,
        'twoLanguageSize': size,
      });
    }
  }
  int endTime = DateTime.now().millisecondsSinceEpoch;
  // 如果不获取大小，0.364 s，否则 71.587 s
  log.i('获取古文数据耗时：${(endTime - startTime) / 1000} s');
  return fileList;
}

class PoemBook extends StatefulWidget {
  const PoemBook({super.key});

  @override
  _PoemBookState createState() => _PoemBookState();
}

enum FileSortEnum { name, modifiedTime, path, work }

class _PoemBookState extends State<PoemBook> {
  /// path , name ,twoLanguageSize
  List<Map<String, dynamic>> _fileList = [];
  Map<String, dynamic> imgMap = {};

  @override
  void initState() {
    // _PoemBookState初始化啦
    super.initState();
    _getFileList(false);
    _computeFileSizes();
  }

  void _computeFileSizes() async {
    _fileList = await compute(
        getPoemBookFiles, PoemBookFilesParams(PathObj.poemBookPath, true));
    setState(() {});
  }

// 是否要进行耗时操作，isTakeTime ,如果不想进行耗时操作，就传递false；
  void _getFileList(bool isTakeTime) async {
    _fileList = await getPoemBookFiles(
        PoemBookFilesParams(PathObj.poemBookPath, false));
    // _sortList(FileSortEnum.modifiedTime);
    // log.i('获取完毕_fileList：$_fileList');
    setState(() {});
  }

/* 
我在使用flutter编写程序，我要获取一个文件夹的具体数据，包括文件的名称和大小，然后使用ListView.builder展示出来。
因为获取文件大小特别耗时，我就在initState里面，先获取一遍数据，不获取文件大小，这样很快就展示出来了。
然后再获取文件大小，但是页面就卡住了，无法滑动。
下面是我的代码：

@override
  void initState() {
    super.initState();
    _getFileList(false);
  }
void _getFileList(bool isTakeTime) async {
    _fileList = await getPoemBookFiles(PathObj.poemBookPath, isTakeTime);
    setState(() {});
    setTimeout(() => _getFileList(true), 100);
  }
原因1：在Flutter中，使用延时函数会导致UI线程被阻塞，因此页面无法响应滑动事件。
原因2：你看看你的 _getFileList 是不是个死循环，每次执行完成后都会再次调用啊。

所以，不要在ui线程中进行大量计算。
注意：compute 必须是顶级函数或者static函数，且要传递的函数只有一个参数。
如果后台函数太多，也会开销较大，使用线程池，
https://www.jianshu.com/p/07b19f4752ea

 */

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
          Expanded(
            child: ListView.builder(
              itemCount: _fileList.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> item = _fileList[index];
                // log.i('_fileList${_fileList.toString()}');
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('${item['twoLanguageSize']}'),
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

  void _openFile(Map<String, dynamic> fileInfo, BuildContext context) async {
    try {
      String title = fileInfo['name'];
      String path = fileInfo['path'];
      File file = File(fileInfo['path']);
      log.i('file:$file');
      String mdStr = '# $title\n';
      Directory dir = Directory(path);
      // 不递归获取，只要当前的目录，获取到书籍
      List<FileSystemEntity> entities = dir.listSync(recursive: true);
      // 需要在这里进行排序，但是暂时不排序
      for (var entity in entities) {
        // log.i('entity$entity');
        var path = entity.path;
        if (path.contains('bitext.txt')) {
          File file = File(path);
          String text = await FileProcess.readFileAsString(file);
          mdStr +=
              '# ${file.path.replaceAll(PathObj.poemBookPath, '')}\n $text';
        }
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          // builder: (context) => TextPage(title: title, text: text),
          builder: (context) => ReadMdPage(mdStr, title),
        ),
      );
    } catch (e) {
      log.i(e);
    }
  }
}
