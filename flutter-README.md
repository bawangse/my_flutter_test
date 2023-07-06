# 我的flutter程序
这个用来干啥的？打开md文件的。
打开固定目录的md文件。
## 基础发开步骤
flutter --version
喵的，我的突然没有东西了：zsh: command not found: flutter
在终端中执行：vim $HOME/.zshrc
可以看到flutter的路径：export PATH="$PATH:/Users/lw/flutter/flutter/bin"
啊，我把这个目录删除了，重新安装吧：https://flutter.cn/docs/get-started/install/macos
之后执行：flutter doctor

flutter clean
flutter pub get

0. 中文教程：https://flutter.cn/docs/get-started/learn-more
1. flutter如何启动：#启动 
cd到项目根目录，执行：flutter run --no-sound-null-safety 

--web-hostname=192.168.1.15 --web-port=8885，导致不能使用

Get-Process -Id (Get-NetTCPConnection -LocalPort 8885).OwningProcess | Stop-Process -Force

运行命令：flutter run --web-port=8885 
flutter run -d chrome --no-sound-null-safety --web-hostname=192.168.1.15 --web-port=8885

浏览器打开：http://localhost:8885/#/
浏览器打开：http://192.168.1.15:8885/#/

运行命令：flutter run --observatory-port=8885
浏览器打开：http://localhost:8885/#/


flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8884
flutter run -d chrome --web-hostname=0.0.0.0 --web-port=8884


### flutter在网页如何调试
### 当我使用vscode连接远程的flutter项目，然后启动flutter项目时，使用 flutter run ，我不知道flutter使用了哪个端口，vscode自动转发的端口也没有用。
当值使用 flutter run -d chrome --no-sound-null-safety --web-port=8885 启动，也转发了8885端口，但是浏览器加载不出来内容： http://localhost:8885/#/ 
我应该怎么做？
curl http://localhost:8885/#/ 

## 项目原理
1. 入口： runApp(widget)

widget 美 [ˈwɪdʒɪt] n.小装置。

用 widget 来构建你的 UI 界面，当 widget 的状态改变时，重新构建其 UI，框架则会对比前后变化的不同，以确定底层渲染树从一个状态转换到下一个状态所需的最小更改。--灵感来自react


















# my_flutter_test

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 问题
## 启动时报错
Could not find an option named "sound-null-safety" #2832
找不到名为“声音零安全”的选项 #2832

这是最开始为了避免空安全，一直都好好的，可能是flutter版本太高了，导致出现这个问题。
flutter --version ,返回 Flutter 3.10.5 

然后我只能去.vscode/launch.json里面删除了：
//"args": ["--no-sound-null-safety"]

接着运行提示：Kotlin有问题。

[!] Your project requires a newer version of the Kotlin Gradle plugin.                     
Find the latest version on https://kotlinlang.org/docs/releases.html#release-details, then 
update /Users/lw/flutter/my_flutter_test/android/build.gradle:     ext.kotlin_version = '<latest-version>'  

更新版本后，好了，卧槽，这么神奇。


## 读取yaml文件 
我在flutter项目有个配置文件：lib/common/bws_md_config.yaml
然后在pubspec.yaml中设置：
  assets:
      - lib/common/
然后再项目中读取：final configYaml = await rootBundle.loadString('assets/lib/common/bws_md_config.yaml');
代码报错：
FlutterError (Unable to load asset: "assets/lib/common/bws_md_config.yaml".

`google，gpt给的都不行，不知道为啥。`

gpt回答：
在Flutter项目中，要正确加载资产文件，需要遵循一些规则和约定。根据您提供的信息，以下是您可以尝试的解决方法：

检查文件路径：

确保 lib/common/bws_md_config.yaml 文件存在于您的项目中，并且路径是正确的。
可以通过在终端中导航到项目目录并运行 ls lib/common 命令来验证文件是否存在。
检查 pubspec.yaml 文件：

确保您在 pubspec.yaml 文件中正确地定义了资产路径。
您的资产路径定义似乎是正确的：assets: - lib/common/。
执行 flutter pub get 命令：

确保在更改了 pubspec.yaml 文件后运行了 flutter pub get 命令，以确保依赖关系得到更新。
使用正确的相对路径：

在您的代码中，您正在尝试加载 assets/lib/common/bws_md_config.yaml 文件，但是在 pubspec.yaml 文件中，您将 lib/common/ 路径添加到了 assets 中。
请尝试更改您的代码，以使用相对于 lib/common/ 的路径加载资产文件：final configYaml = await rootBundle.loadString('assets/bws_md_config.yaml');。
清除应用缓存并重新构建：

如果上述步骤仍然无法解决问题，请尝试清除应用程序缓存并重新构建项目。您可以通过运行 flutter clean 命令清除缓存。
如果您尝试了以上方法仍然无法解决问题，请提供更多关于您的项目结构和代码的详细信息，以便我能够更好地帮助您解决问题。

## flutter,读取本地文件，文件不存在创建，文件是多级目录
要在Flutter中读取本地文件并创建多级目录，您可以使用path_provider和dart:io库。下面是一个简单的示例，演示如何读取本地文件并创建多级目录：

File dictFile = File(PathObj.androidYamlConfigPath);

判断文件是否存在：
bool fileExist = await dictFile.exists();

// 创建多级目录-不是创建文件夹,recursive: true表示如果目录不存在，它会自动创建所需的多级目录。
await Directory(filePath).create(recursive: true);

// flutter创建'/abc/a1/a2/txt'文件，目录abc存在，目录a1/a2不存在。
await file.create(recursive: true);

// flutter创建文件失败，因为权限问题，小米手机-设置-搜索权限-特殊权限设置（隐私保护-保护隐私）-所有文件访问权限，设置了就ok
OS Error: Operation not permitted, errno = 1

// flutter向文件写入多行字符串
await file.writeAsString(
    '''
    Line 1
    Line 2
    Line 3
    ''');

## flutter,解析数组字符串

在Flutter中，您可以使用Dart语言内置的JSON库 dart:convert 来解析数组字符串。以下是一个示例代码，演示如何解析一个包含数组的JSON字符串：

dart
Copy code
import 'dart:convert';

void main() {
  String jsonString = '[1, 2, 3, 4, 5]';

  List<dynamic> jsonArray = jsonDecode(jsonString);

  print(jsonArray);  // 输出: [1, 2, 3, 4, 5]
}
在上面的代码中，我们首先定义一个包含数组的JSON字符串 jsonString。然后，我们使用 jsonDecode 函数将其解析为Dart对象。由于数组中的元素类型可能不同，因此我们将其解析为 List<dynamic> 类型。最后，我们将解析后的数组打印出来。

请注意，jsonDecode 函数返回的是动态类型 dynamic，这意味着您需要根据实际情况进行类型转换，或根据数组中元素的类型来处理解析后的数据。

如果您的JSON字符串包含更复杂的结构，例如嵌套数组或对象，您可以使用类似的方法来解析它们。只需将字符串传递给 jsonDecode 函数，然后根据解析后的对象进行进一步操作。

希望这可以帮助您解析数组字符串！如有任何进一步的问题，请随时提问。