import 'birthday.dart';

/// 全局对象，主要是设置里面的数据。
/// 因为是单独设置，所以可以不用加构造函数
class GlobalData {
  /// 生日数据
  List<BirthdayBasicData> birthdays = [];
}

/// 全局对象实例
GlobalData gData = GlobalData();
