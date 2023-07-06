import '../basic.dart';

/// 中文数字转阿拉伯数字; 不支持的字符，返回-1
int chineseToArabic(String chineseNumber) {
  // 定义数字的映射关系
  Map<String, int> digitMap = {
    '零': 0,
    '一': 1,
    '二': 2,
    '三': 3,
    '四': 4,
    '五': 5,
    '六': 6,
    '七': 7,
    '八': 8,
    '九': 9,
  };

  int result = 0; // 最终的阿拉伯数字结果
  int temp = 0; // 临时保存当前处理的数字
  int lastDigit = 0; // 上一个处理的数字

  for (int i = 0; i < chineseNumber.length; i++) {
    String char = chineseNumber[i];

    // 处理亿、万、千等单位
    if (digitMap.containsKey(char)) {
      temp = digitMap[char]!;
      if (i == chineseNumber.length - 1) {
        result += temp;
      }
    } else {
      switch (char) {
        case '亿':
          result = (result + temp) * 100000000;
          temp = 0;
          break;
        case '万':
          result = (result + temp) * 10000;
          temp = 0;
          break;
        case '千':
          temp = temp * 1000;
          break;
        case '百':
          temp = temp * 100;
          break;
        case '十':
          if (i == 0) {
            temp = 1;
          }
          temp = temp * 10;
          break;
        default:
          return -1; // 不支持的字符，返回-1
      }

      if (temp >= 10 || i == chineseNumber.length - 1) {
        // 处理个位数字
        if (lastDigit > temp) {
          result += temp;
        } else {
          result += (temp > 0 ? temp : 1);
        }
        temp = 0;
      }
    }

    lastDigit = temp;
  }

  return result;
}

void chineseToArabicTest() {
  log.i(chineseToArabic('五')); // 输出：15
  log.i(chineseToArabic('十五')); // 输出：15
  log.i(chineseToArabic('二百')); // 输出：235
  log.i(chineseToArabic('二百三十五')); // 输出：235
}

/// 如果一行字太长，比如超过100个字符就进行分割。
String splitLongLines(String text) {
  final List<String> lines = text.split('\n');
  final List<String> newLines = [];

  for (final line in lines) {
    if (line.length > 120 &&
        line.contains(RegExp(r'[。！？.]')) &&
        hasChineseCharacters(line)) {
      final List<String> splitLines = splitLine(line);
      newLines.addAll(splitLines);
      log.i('超过100个字符了');
    } else {
      newLines.add(line);
    }
  }

  return newLines.join('\n');
}

/// 字符串包含中文么
bool hasChineseCharacters(String line) {
  final chineseRegex = RegExp(r'[\u4e00-\u9fa5]');
  return chineseRegex.hasMatch(line);
}

/// 字符串超过100，对这个字符串进行分割，返回分割后的list
List<String> splitLine(String line) {
  final List<String> splitLines = [];
  final List<String> separators = ['。', '！', '？', '.'];

  String currentLine = '';
  for (int i = 0; i < line.length; i++) {
    final char = line[i];
    currentLine += char;

    if (i < line.length - 1 &&
        (separators.contains(char) && currentLine.length >= 80)) {
      splitLines.add(currentLine);
      currentLine = '';
    }
  }

  if (currentLine.isNotEmpty) {
    splitLines.add(currentLine);
  }

  return splitLines;
}

bool strIsEmpty(String? text) {
  if (text != null && text.isNotEmpty) {
    return false;
  }
  return true;
}
