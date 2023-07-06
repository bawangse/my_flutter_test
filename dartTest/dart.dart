/* 
1.入口为 返回类型 main(){}

void main() {
  print('hello ikonw as 刘伟');
}
 */

/* 
2. 注释
 */
// 我是注释

/* 
3. 变量
var | 明确类型  变量名
var 会自动推断类型。
赋值类型无法更改。

4.常量
const：一开始赋值。
final：运行时才赋值。可以赋值data，const不行

5.类型
int double bool String List map set 

int:
num1.isNaN 判断是否 非数字
int.parse(str)  double.parse(str)
num1.toString()


string:''  ""   '''多行字符串 '''  """多行字符串"""
拼接："$str1 $str2 ${map1['key']}"   str1+str2
str1.isEmpty  属性可以判断字符串为空

bool 必须是true false，不能是其他0 1

+ - * / %(取余) ~/(相除取整)  == != > >= < <= 
b=a++,++写在后面，就是先使用a，赋值给b，a再自增。
b??=23,如果b为null，就将23赋值给b。即这个变量只能定义为var，var b=null;或者var b；不能定义为明确的类型。
b = a ?? 23,如果a为null，将23赋值给b 

list,元素类型不限制，[1, '2', true] 。限制类型，var i = <int>[1,2,3]
isEmpty  属性-是否为空 isNotEmpty 属性-是否不为空
reversed 属性-翻转-倒序-返回元祖，得再次调用，reversed.toList()  
length 属性-长度
方法：
add 、addAll([])--拼接数组 、indexOf-返回索引没有-1、 
remove('具体的值')   removeAt(index)  、 
指定位置插入，insert(index,item) insertAll
join('-') 拼接为字符串
转为list，toList
固定长度的list：List.filled(长度, 填充值)  List<int>.filled  通过[index]修改。
长度可以修改：arr.length = 0，就变成了空数组，当然filled 固定长度不行。


  map:像js的对象那样定义，key必须带''|"",否则key就是变量的形式了。new Map()
只能通过[key]访问。
  属性：
keys.toList()   values.toList()  isEmpty  isNotEmpty
  方法：
addAll({}) remove(key)  containsValue(value)


set，add，

  map、list、set通用
for  for-in list.forEach((item,){}}
map方法返回，
where相当于filter
any-有一个满足返回true every-每个都满足返回true

类型判断，str1 is String
 */

/* 
方法
返回类型  方法名 (参数1，[int 默认参数3=333，可选参数2]){
  return
}

命名参数
void fun2(int age,{int a2,int a3=3})
fun2(1,a2:2)
 */

void main() {
  var a = 3;

  String b = '4';
  String b1 = '4';
  print(b + b1);
  print("$b$b1");
  print("$b   \$ b1");

  int c = 5;
  const int PI = 3;
  // const time = new DateTime.now();
  final DateTime time2 = new DateTime.now();
  print(time2);

  bool boo1 = false;
  print(boo1);

  List arr1 = [1, '2', true];
  List arr2 = <int>[1, 2, 3];
  arr2.add(5);
  List arr3 = List.filled(3, '0');
  print('$arr1 $arr2$arr3');
  arr2.length = 1;
  print(arr2);

  Map m1 = {'a': 1, b: '2'};
  print('$m1 ${m1["a"]}${m1[b]}');

  print(m1 is String);

  // var b3 = null;
  var b3;
  b3 ??= '23';
  print(b3);

  int b4 = 0;
  int b5 = b4 ?? 2;
  print(b5);
  print(b4.isNaN);

  for (int i = 0; i < 10; i++) {
    print(i);
  }
}
