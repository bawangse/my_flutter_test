import 'package:flutter_tts/flutter_tts.dart';

import '../../basic.dart';

class TTSUtil {
  late FlutterTts flutterTts;

  TTSUtil() {
    log.i(' 初始化ttsUtil');
    flutterTts = FlutterTts();
    setTts();
  }

  Future setTts() async {
    /// 设置语言
    await flutterTts.setLanguage("zh-CN");

    /// 设置音量
    await flutterTts.setVolume(0.8);

    /// 设置语速
    await flutterTts.setSpeechRate(0.5);

    /// 音调
    await flutterTts.setPitch(1.0);
  }

  Future speak(String text) async {
    log.i('开始朗读');
    // text = "你好，我的名字是李磊，你是不是韩梅梅？";
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  /// 递归调用朗读大文本
  void speakLongText(List<String> dataArr, int index, changeReadIndex) {
    if (index >= dataArr.length) {
      log.i('已经朗读完所有文本，执行回调函数或其他操作');
      stop();
      return;
    }
    String text = dataArr[index];
    log.i('执行-speakLongText：$index,$text');
    int startTime = DateTime.now().millisecondsSinceEpoch;
    // 如果没有调用speak，也就不会调用setCompletionHandler
    if (text == '' || text.isEmpty) {
      index++;
      speakLongText(dataArr, index, changeReadIndex);
    } else {
      if (changeReadIndex != null) {
        changeReadIndex(index);
      }
      speak(text);
    }
    flutterTts.setCompletionHandler(() {
      int endTime = DateTime.now().millisecondsSinceEpoch;
      log.i('朗读-结束：$index，${(endTime - startTime) / 1000} s');
      index++;
      // if (changeReadIndex != null) {
      //   changeReadIndex(index);
      // }
      speakLongText(dataArr, index, changeReadIndex);
    });
    flutterTts.setErrorHandler((message) {
      log.i('执行-speakLongText-error：$index,$text,$message');
      index++;
      // if (changeReadIndex != null) {
      //   changeReadIndex(index);
      // }
      speakLongText(dataArr, index, changeReadIndex);
    });
  }

  /// 递归调用朗读大文本，前要做一些事情
  void speakLongTextFront(List<String> dataArr, int index, changeReadIndex) {
    stop();
    speakLongText(dataArr, index, changeReadIndex);
  }

  /// 暂停
  Future pause() async {
    await flutterTts.pause();
  }

  /// 结束
  Future stop() async {
    await flutterTts.stop();
  }
}

TTSUtil ttsUtil = TTSUtil();
