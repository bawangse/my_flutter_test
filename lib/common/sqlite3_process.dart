// 不仅要导入 sqlite3，还要导入 flutter pub add sqlite3_flutter_libs
import 'package:sqlite3/sqlite3.dart';

import '../basic.dart';
import 'path_config.dart';

class SqliteTableProps {
  final String id;
  final String key; //
  final String value; //

  SqliteTableProps({required this.id, required this.key, this.value = ''});
}

class Sqlite3Process {
  late Database db;
  Sqlite3Process() {
    log.i('sqlite:初始化${sqlite3.version}');
    // 如果文件不存在呢？会自动创建么？是同步的么？
    db = sqlite3.open(PathObj.SqliteFile, mode: OpenMode.readWriteCreate);
    createDocTable();
  }

  /// 创建doc的表，用来记录docs的文件查看的位置
  /// id，fileOffset，tocOffset，tocIndex，
  /// 用最传统的表：id，key，value
  createDocTable() {
    log.i('sqlite:创建$db');
    db.execute('''
    create table if not exists props(
            id VARCHAR(256)   NOT NULL,
            key VARCHAR(256)  NOT NULL, 
            value blob ,
            PRIMARY KEY ("id", "key")
         );
  ''');
  }

  ///插入
  void insertDoc(List<SqliteTableProps> props) {
    log.i('sqlite:insertDoc,$props');
    for (var item in props) {
      db.execute('INSERT OR REPLACE INTO props VALUES (?,?,?)',
          [item.id, item.key, item.value]);
    }
  }

  ///查找
  List<SqliteTableProps> selectDoc() {
    List<SqliteTableProps> props = [];
    ResultSet resultSet = db.select(
      'SELECT * FROM props',
    );
    for (final Row row in resultSet) {
      props.add(SqliteTableProps(
          id: row['id'], key: row['key'], value: row['value']));
    }
    // log.i('sqlite:selectDoc,$resultSet $props');
    return props;
  }

  void docTest() {
    log.i('sqlite:docTest');
    /* insertDoc([
      SqliteTableProps(id: '1', key: 'toc', value: '400'),
      SqliteTableProps(id: '1', key: 'md', value: '500'),
      SqliteTableProps(id: '1', key: 'tocIndex', value: '6'),
      SqliteTableProps(id: '2', key: 'toc', value: '400'),
      SqliteTableProps(id: '2', key: 'md', value: '500'),
      SqliteTableProps(id: '2', key: 'tocIndex', value: '6'),
    ]); */
    selectDoc();
  }
}

Sqlite3Process sql3 = Sqlite3Process();
