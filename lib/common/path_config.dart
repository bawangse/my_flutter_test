///文件的路径
// 因为enum无法定义值，所以我不得不使用class-static
class PathObj {
  // 静态变量
  // 文档路径
  // '/sdcard/aknow/docs/';
  static String WinBasePath = 'D:/code/myfront/my/resource/docs/';
  static String AndroidBasePath = '/storage/emulated/0/aknow/docs/';
  // 文档中的img
  static String WikiImg = 'wiki/img';
  static String SqliteFile = '/storage/emulated/0/aknow/iknow.sqlite';

  /// 词典文件路径
  static String DictFile =
      '/storage/emulated/0/aknow/english/PEPXiaoXue3_2.json';

  /// 古诗词书-双语
  static String poemBookPath =
      '/storage/emulated/0/aknow/古诗/Classical-Modern-main/双语数据';

  /// 配置文件
  static String androidYamlConfigPath =
      '/storage/emulated/0/aknow/docs/aaa/bws_md_config.yaml';
}
