// 为了使用DateFormat
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:universal_io/io.dart';
import 'package:markdown/markdown.dart' hide Text;

import '../../basic.dart';
import '../../common/fileProcess.dart';
import '../../common/sqlite3_process.dart';
import 'ttsUtil.dart';

class ReadMdPage extends StatefulWidget {
  /// 字符串数据
  final String data;
  final String name; // 包含文件名
  const ReadMdPage(this.data, this.name, {super.key});

  @override
  _ReadMdPageState createState() => _ReadMdPageState();
}

class _ReadMdPageState extends State<ReadMdPage> {
  final TocController tocController = TocController();
  bool _isTocVisible = false;
  final _buttonKey = GlobalKey();
  int tocIndex = 0;

  /// 从markdown包里面拿到的md数据
  // late MdData mdObj;

  /// 自动滚动的计时器；
  Timer? autoScrollTimer;

  /// 当前是否在滚动，用于双击后反转状态
  bool isMove = false;

  /// 当前是否在播放，用于双击后反转状态
  bool isSpeak = false;

  /// 将markdown_widget里面的control保存起来
  AutoScrollController? mdControlForPackage;
  int readIndex = 0; // 阅读到了哪一个了
  /// 触发readIndex更改的方法
  void onChangeReadIndex(int newIndex) {
    log.i('更改状态-onChangeReadIndex：$newIndex');
    setState(() {
      readIndex = newIndex;
    });

    // 如果真不行，可以用 controller.scrollToIndex 跳到底部，然后再跳到0，拿到全部的height。
    double getCurrentSpeakHeight() {
      double currentHeight = .0;
      if (mdObj.height.isEmpty) {
        return -1;
      }
      if (mdObj.height[newIndex] == null) {
        log.e('md-speak-error:卧槽，这个竟然没有$newIndex,${mdObj.height}');
        return -1;
      }
// 如果 mdObj.height 没有获取全部，而是只保存了渲染的item，没有渲染的item没有保存，那么，mdObj.height[i]肯定有不存在的，执行的时候会报错的
      for (var i = 0; i < newIndex; i++) {
        currentHeight += mdObj.height[i];
      }
      return currentHeight;
    }

    /* double currentHeight = getCurrentSpeakHeight();
    if (currentHeight == -1) return;
    mdObj.mdControl!.animateTo(
      currentHeight,
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
    );
     */
    log.i(
        '阅读跳转：$newIndex ${mdObj.widgets} ${mdObj.mdControl!.position.minScrollExtent} ${mdObj.mdControl!.position.viewportDimension}');
// mdObj.mdControl!.position.minScrollExtent 表示滚动区域的最小滚动偏移量，即列表的顶部位置对应的像素值 0
// mdObj.mdControl!.position.viewportDimension 表示可见区域的高度，即当前显示在屏幕上的列表部分的高度 856.6
    // mdObj.mdControl!.jumpTo(jumptonum);
    mdObj.mdControl!.scrollToIndex(
      newIndex,
      preferPosition: AutoScrollPosition.begin,
      duration: const Duration(milliseconds: 200),
    );
  }

  _ReadMdPageState() {
    // flutter，window.physicalSize.width得到的屏幕宽度和Offset设置的不一致
    final width = window.physicalSize.width;
    final height = window.physicalSize.height;
    log.i('屏幕的宽高：$width，$height');
    log.i('md-构造函数_ReadMdPageState');
  }

  /// 初始化后朗读,注意这里的数据和通过md渲染的不一样，这里的是按行分割的-比md渲染的多很多空字符串。
  void initEndSpeak() {
    if (widget.data.length > 1000) {
      List<String> dataArr = widget.data.split('\n');
      ttsUtil.speakLongTextFront(dataArr, 0, onChangeReadIndex);
    } else {
      ttsUtil.speak(widget.data);
    }
  }

  @override
  void initState() {
    super.initState();
    log.i('md-initState-只会执行一次');
    int startTime = DateTime.now().millisecondsSinceEpoch;
    // 渲染 渲染结束 渲染完毕 执行 渲染结束后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log.i('渲染 渲染结束 渲染完毕 执行 渲染结束后执行');
      int endTime = DateTime.now().millisecondsSinceEpoch;
      // initEndSpeak();
      // 0.842 s
      log.i('md-渲染完毕耗时：${(endTime - startTime) / 1000} s');
    });
  }

  final Offset initOffset = const Offset(300, 600); // 设置为0,0坐标，Offset.zero
  // initOffset在初始化对象之前，您无法访问。要修复您的示例，请将您的myTest初始化移动到构造函数中。或者使用late
  late Offset _dragOffset = initOffset;

  Widget buildMarkdown(BuildContext context) {
    var docs = sql3.selectDoc();
    var mdOffset = 0.0;
    // 上一次的文档滚动位置，用来终结滚动
    var lastMdOffset = -1.1;
    var mdTocOffset = .0;
    var mdIndex = .0;
    for (var item in docs) {
      if (item.id == widget.name) {
        switch (item.key) {
          case 'mdOffset':
            mdOffset = double.parse(item.value);
            break;
          case 'mdTocOffset':
            mdTocOffset = double.parse(item.value);
            break;
          case 'mdIndex':
            mdIndex = double.parse(item.value);
            break;
        }
      }
    }
    // docs.where((e) => e.id == widget.name).toList(); // 数组过滤
    void mdInitStateCall(AutoScrollController mdControl) {
      mdControlForPackage = mdControl;
      //监听滚动事件，打印滚动位置
      mdControl.addListener(() {
        log.i(
            'md:文档滚动位置：${mdControl.offset} ${mdControl.offset.toString()}'); //打印滚动位置
        mdOffset = mdControl.offset.roundToDouble();
        sql3.insertDoc([
          SqliteTableProps(
              id: widget.name, key: 'mdOffset', value: mdOffset.toString()),
        ]);
      }.debounce(timeout: 500));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mdControl.animateTo(
          mdOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      });
    }

    void tocInitStateCall(AutoScrollController tocControl) {
      //监听滚动事件，打印滚动位置
      tocControl.addListener(() {
        log.i('md:toc滚动位置：${tocControl.offset}'); //打印滚动位置
        sql3.insertDoc([
          SqliteTableProps(
              id: widget.name,
              key: 'mdTocOffset',
              value: tocControl.offset.roundToDouble().toString()),
        ]);
      }.debounce(timeout: 500));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 在帧完成后滚动到指定坐标 mdTocOffset
        tocControl.animateTo(
          mdTocOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      });
    }

    void clickTocCall(int clickTocIndex) {
      log.i('点击了数据-$clickTocIndex');
      // 我开始以为是我关闭了toc，导致toc没有定位到刚才的点击。其实不是，应该是我重新渲染了？
      setTimeout(() {
        setState(() {
          _isTocVisible = false;
          tocIndex = clickTocIndex;
        });
        log.i('开始关闭toc-$tocIndex');
      }, 300);
    }

    void getMdObjCall(MdData mdObj1) {
      // mdObj = mdObj1;
    }

    double fontSize = 24.0;
    double height = 1.5; //1倍行高
    TextStyle readStyle = TextStyle(
        height: height,
        backgroundColor: const Color.fromARGB(255, 62, 205, 100));
    TextStyle commonStyle = TextStyle(height: height, fontSize: fontSize);
    TextStyle highLightStyle = TextStyle(
        fontSize: fontSize,
        height: height,
        backgroundColor: const Color.fromARGB(255, 161, 205, 147));

    Widget initMdNode(List<Node> nodes, int index, InlineSpan span) {
      final Widget paragraphWidget = GestureDetector(
        onDoubleTap: () {
          // 双击
          isSpeak = !isSpeak;
          if (!isSpeak) {
            ttsUtil.stop();
            return;
          }
          Node node = nodes[index];
          log.i('点击：${node.textContent}');

          /// basic.alert(context, '选中的内容${widget.name}', node.textContent);
          List<String> dataArr = nodes.map((e) => e.textContent).toList();
          ttsUtil.speakLongTextFront(dataArr, index, onChangeReadIndex);
        },
        onTap: () {
          // 单击-阅读状态下，跳到这一段进行朗读
          if (isSpeak && index != readIndex) {
            ttsUtil.stop();
            Node node = nodes[index];
            log.i('阅读状态下单击：${node.textContent}');
            List<String> dataArr = nodes.map((e) => e.textContent).toList();
            ttsUtil.speakLongTextFront(dataArr, index, onChangeReadIndex);
          }
        },
        behavior: HitTestBehavior.translucent,
        child: Text.rich(
          span,
          style: readIndex == index ? readStyle : null,
        ),
      );
      return paragraphWidget;
    }

// 保存的选中的md字符串
    String selectTile = '';
// 为了防抖，为了选中后来不及复制，
    Timer? selectTime;

    /// md选中英文单词后给出答复
    onSelectionChanged(SelectedContent? selectContent) {
      log.i('selectContent3-${selectContent?.plainText}');
      String title = selectContent?.plainText ?? '';
      if (title == '') return;
      // 包含空格说明不是单词，直接干掉
      if (title.contains(' ')) return;
      title = title.toLowerCase();
      selectTile = title;
      if (selectTime != null) {
        selectTime?.cancel();
      }
      selectTime = setTimeout(() async {
        // 初始化读取文件 dictHou\src\dict\PEPXiaoXue3_2.js，转为json，放到代码中
        // file拿到json文件，通过dart:convert包中的json.decode方法将其进行转化
        String dictStr = await fileProcess.getDictData(title);
        if (dictStr == '') {
          basic.toast('$title:没有数据，请缩短哦');
          return;
        }
        basic.alert(context, title, dictStr);
        selectTime = null;
      }, 2000);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    MarkdownWidget markdownWidget = MarkdownWidget(
        data: widget.data,
        tocController: tocController,
        mdConfig: MdConfig(
          mdInitStateCall: mdInitStateCall,
          tocInitStateCall: tocInitStateCall,
          clickTocCall: clickTocCall,
          getMdObjCall: getMdObjCall,
          onSelectionChanged: onSelectionChanged,
          initMdNode: initMdNode,
          commonStyle: commonStyle,
          highLightStyle: highLightStyle,
        ),
        /* markdownGeneratorConfig: MarkdownGeneratorConfig(
            generators: [videoGeneratorWithTag],
            textGenerator: (node, config, visitor) =>
                CustomTextNode(node.textContent, config, visitor)), */
        config:
            isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig);

    void autoScroll() {
      // 双击
      log.i('开始滚动$mdOffset');
      isMove = !isMove;
      if (!isMove && autoScrollTimer != null) {
        autoScrollTimer!.cancel();
        autoScrollTimer = null;
        return;
      }
      const duration = Duration(seconds: 10);
      autoScrollTimer = Timer.periodic(duration, (Timer t) {
        // 在这里编写需要循环执行的代码
        log.i('定时任务执行$mdOffset');
        if (mdControlForPackage != null) {
          if (mdOffset == lastMdOffset) {
            autoScrollTimer!.cancel();
            isMove = !isMove;
            return;
          }
          lastMdOffset = mdOffset;
          mdControlForPackage!.animateTo(
            mdOffset + 400,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        }
      });
    }

    Widget level0Md = GestureDetector(
      onDoubleTap: () {
        autoScroll();
      },
      behavior: HitTestBehavior.translucent,
      child: markdownWidget,
    );

    // return level0Md;
    return markdownWidget;
  }

  Widget buildTocClickWidget() {
    log.i('buildTocClickWidget---每次修改 _isTocVisible 都会进行渲染。$_dragOffset');
    // 这里单击事件失效，双击和长按可以。且双击和长按并没有跳转。必须先单击，再双击。
    return InkWell(
      child: TocWidget(controller: tocController),
      onTap: () {
        log.i('单击');
        setState(() {
          _isTocVisible = false;
        });
      },
      onDoubleTap: () {
        // 双击
        log.i('单击2');
        setState(() {
          _isTocVisible = false;
        });
      },
      onLongPress: () {
        // 长按
        log.i('单击3');
        setState(() {
          _isTocVisible = false;
        });
      },
    );
  }

  Widget buildFloatingButton() {
    log.i('渲染位置$_dragOffset${_dragOffset.dx}  ${_dragOffset.dy}');
    Widget draggable = Draggable(
      // Draggable 组件允许用户拖动 FloatingActionButton 子组件。
      //它提供了一个 feedback 组件，用于在拖动时显示拖动图标。
      //feedback 组件是一个带有内部 Icon 组件的 FloatingActionButton 组件。
      feedback: FloatingActionButton(
        key: _buttonKey,
        onPressed: () {
          log.i('点击feedback');
        },
        child: const Icon(Icons.memory),
      ),
      // childWhenDragging 属性是在拖动过程中替代 child 属性所显示的组件。
      childWhenDragging: Container(),
      // onDragEnd 属性是拖动结束时调用的回调函数，它接收一个 DraggableDetails 对象作为参数，
      // 其中包含拖动的详细信息。
      onDragEnd: (details) {
        // log.i('拖动结束');
        // 这里必须as，否则 findRenderObject 返回的类型 RenderObject，无法调用 localToGlobal
        final RenderBox renderBox =
            _buttonKey.currentContext?.findRenderObject() as RenderBox;
        if (renderBox == null) {
          return;
        }
        final position = renderBox.localToGlobal(Offset.zero);
        setState(() {
          _isTocVisible = false;
          _dragOffset = position ?? _dragOffset;
        });
      },
      // child 属性是在拖动开始之前所显示的组件。
      child: FloatingActionButton(
        key: _buttonKey,
        onPressed: () {
          setState(() {
            _isTocVisible = true;
          });
        },
        child: const Icon(Icons.menu_book),
      ),
    );
    Widget opacity = Opacity(opacity: 0.5, child: draggable);
    // 不能将positioned组件放到Opacity的child里面，会导致Positioned的坐标始终在左上角
    Widget positioned = Positioned(
      left: _dragOffset.dx,
      top: _dragOffset.dy,
      // drag 英 [dræɡ] 美 [dræɡ] v. 拖
      child: opacity,
      // child: draggable,
    );
    return positioned;
  }

  @override
  Widget build(BuildContext context) {
    Widget mdWidget;
    var isSmallPage = false; // 是小屏幕么
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      mdWidget = Scaffold(
        body: Stack(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: buildTocClickWidget()),
                Expanded(flex: 3, child: buildMarkdown(context))
              ],
            ),
            buildFloatingButton(),
          ],
        ),
      );
    } else {
      isSmallPage = true;
      mdWidget = Scaffold(
        body: Stack(
          // children: <Widget>[buildMarkdown(context), buildFloatingButton()],
          children: <Widget>[buildMarkdown(context), buildFloatingButton()],
        ),
        bottomNavigationBar: Visibility(
          visible: _isTocVisible,
          child: buildTocClickWidget(),
        ),
      );
    }
    // 为了展示滚动条，不过无法拖拽
    Scrollbar scrollMdWidget = Scrollbar(
        thickness: 25.0, // 设置滚动条的宽度为10.0
        child: mdWidget);

    return WillPopScope(
      onWillPop: () async {
        if (autoScrollTimer != null) {
          autoScrollTimer!.cancel();
          autoScrollTimer = null;
        }
        ttsUtil.stop();
        if (_isTocVisible && isSmallPage) {
          setState(() {
            _isTocVisible = false;
          });
          return false;
        }
        return true;
      },
      // 草，我在这里使用 SelectionArea 包裹，但是不起作用，是不是底层也用了 SelectionArea 包裹？
      child: scrollMdWidget,
    );
  }
}
