class Route {
  final String title; // 页面的名称
  final String description; // 页面描述
  final String route; // 是否今天过生日
  // final int? age; // 年龄

  Route({
    required this.title,
    required this.route,
    this.description = '',
  });
}
