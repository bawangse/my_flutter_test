# vscode链接不上ssh
Failed to parse remote port from server output
乱码，无法解析输出。
我已经删除了window10上的vscode-server文件夹，重新链接还是不行。
但是我用终端连接可以。

可能原因：
1. 我破坏了服务器的node和npm
2. 大多数原因是不恰当的关闭和远程服务器的连接，或者和服务器同步时出现问题导致。我那个时候强制重启了服务器。
3. win的open-ssh更新了
4. vscode的版本问题，但是当前的vscode可以连接linux的ssh啊。

我使用vscode的remote ssh插件连接服务器，输入密码后，出现如下乱码，要怎么办
'powershell' �����ڲ����ⲿ���Ҳ���ǿ����еĳ���
> ���������ļ��� "install" terminal command done

```bash
[20:13:21.189] "install" wrote data to terminal: "***********"
[20:13:21.198] > 
[20:13:21.312] > 'powershell' �����ڲ����ⲿ���Ҳ���ǿ����еĳ���
> ���������ļ���
[20:13:21.579] "install" terminal command done
[20:13:21.579] Install terminal quit with output: ���������ļ���
[20:13:21.580] Received install output: ���������ļ���
[20:13:21.580] Failed to parse remote port from server output
```
教程：https://blog.csdn.net/weixin_44749184/article/details/124187881

排查：
1. ssh name@ip ，是否能连接服务器，能连接继续，否则先去解决这个问题
2. 删除本地的 known_hosts 里面对应的ip行。cd .ssh ，vim known_hosts ，dd删除，wq保存。
3. 进入服务器，先关闭VS Code，然后删除服务器的vscode-server目录，一般在c-用户目录下面
4. vscode-顶部菜单-code-关于，找到commitid：2ccd690cbff1569e4a83d7c43d45101f817401dc，替换链接中的id，https://update.code.visualstudio.com/commit:${commit_id}/server-linux-x64/stable，
5. linux：https://update.code.visualstudio.com/commit:2ccd690cbff1569e4a83d7c43d45101f817401dc/server-linux-x64/stable
6. win：https://update.code.visualstudio.com/commit:2ccd690cbff1569e4a83d7c43d45101f817401dc/server-win32-x64/stable
7. 下载后，将内容解压后，把里面的文件放到 ~/.vscode-server/bin/{commit_id},即 bin/2ccd690cbff1569e4a83d7c43d45101f817401dc/里面是 解压包的内容：node等内容
8. 如果本地vscode版本更新，那么服务器的那个就用不了了。
9. 还有人要修改这个：Remote SSH -> Extension Setting -> "remote.SSH.useLocalServer": false

### 配置ssh插件
1. Use Local Server，更详细的日志，可以看到已经链接了，但是断开了
2. Log Level，选择trac


win，ssh，配置断开连接时间，执行下面的命令，600s即10min：
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\OpenSSH" /v IdleTimeout /t REG_SZ /d 600 /f
修改后还是不行。
16:33链接，16：40再看。并没有撑10min

stderr> debug1: pledge: filesystem full
磁盘满了？
可能如下修改：type C:\\ProgramData\\ssh\\sshd_config
1. /etc/ssh/ssh_config
文件末尾添加：IPQoS 0x00
1. .ssh/config 文件（MAC OSX；蒙特雷）
Host *
  IPQoS=throughput

下载新的vscode：https://code.visualstudio.com/insiders/
这种算是最新版本。内部版本。

【win编辑文件】
- notepad: 打开文本编辑器notepad，可以编辑文本文件。
notepad filename.txt
- edit: 打开MS-DOS编辑器edit，可以编辑文本文件。
edit filename.txt
- type & redirection: 可以使用type命令查看文件内容，然后使用重定向符号（>）将输出保存到新文件中。你可以编辑新文件，然后将其重命名为原始文件名以保存更改。
type filename.txt > newfile.txt
type sshd_config > sshd_config2
- copy & edit: 可以使用copy命令将文件复制到新文件中，然后使用notepad或edit编辑新文件。编辑完成后，可以使用copy命令将新文件复制回原始文件名。
copy filename.txt newfile.txt
notepad newfile.txt
copy newfile.txt filename.txt

```bash
[16:14:37.539] Got password response
[16:14:37.539] Interactor gave response: ***********
[16:14:37.540] Cleaning up other-window auth server
[16:14:37.604] stderr> debug1: Authentication succeeded (password).
[16:14:37.604] stderr> debug1: Local connections to LOCALHOST:61337 forwarded to remote address socks:0
[16:14:37.605] stderr> debug1: Local forwarding listening on ::1 port 61337.
[16:14:37.605] stderr> debug1: channel 0: new [port listener]
[16:14:37.605] stderr> debug1: Local forwarding listening on 127.0.0.1 port 61337.
[16:14:37.605] stderr> debug1: channel 1: new [port listener]
[16:14:37.605] stderr> debug1: channel 2: new [client-session]
[16:14:37.605] stderr> debug1: Requesting no-more-sessions@openssh.com
[16:14:37.606] stderr> debug1: Entering interactive session.
[16:14:37.606] stderr> debug1: pledge: filesystem full
[16:14:37.625] stderr> debug1: client_input_global_request: rtype hostkeys-00@openssh.com want_reply 0
[16:14:37.635] stderr> debug1: client_input_hostkeys: host key found matching a different name/address, skipping UserKnownHostsFile update
[16:14:37.636] stderr> debug1: Sending environment.
[16:14:39.181] stderr> debug1: channel 0: free: port listener, nchannels 3
[16:14:39.181] stderr> debug1: channel 1: free: port listener, nchannels 2
[16:14:39.181] stderr> debug1: channel 2: free: client-session, nchannels 1
[16:14:39.181] stderr> debug1: fd 0 clearing O_NONBLOCK
[16:14:39.181] stderr> debug1: fd 2 clearing O_NONBLOCK
[16:14:39.181] stderr> Transferred: sent 2500, received 2384 bytes, in 1.6 seconds
[16:14:39.182] stderr> Bytes per second: sent 1585.9, received 1512.3
[16:14:39.182] stderr> debug1: Exit status -1
[16:14:39.183] > local-server-1> ssh child died, shutting down
[16:14:39.188] Local server exit: 0
[16:14:39.189] Received install output: local-server-1> Running ssh connection command: "-v -T -D 61337 -o ConnectTimeout=15 l-f"
local-server-1> Spawned ssh, pid=5725
OpenSSH_8.6p1, LibreSSL 3.3.6
debug1: Server host key: ssh-ed25519 SHA256://S16Yu6kpp7zMF8m24tgocgv2ltXTzEx2COrETdLLU
Transferred: sent 2500, received 2384 bytes, in 1.6 seconds
Bytes per second: sent 1585.9, received 1512.3
local-server-1> ssh child died, shutting down

[16:14:39.190] Failed to parse remote port from server output
[16:14:39.194] Resolver error: Error: 
	at process.processTicksAndRejections (node:internal/process/task_queues:96:5)
[16:14:39.196] TELEMETRY: {"eventName":"resolver","properties":{"osReleaseId":"","arch":"","askedPw":"0","askedPassphrase":"0","asked2fa":"0","askedHostKey":"0","remoteInConfigFile":"1","gotUnrecognizedPrompt":"0","dynamicForwarding":"1","localServer":"1","didLocalDownload":"0","installUnpackCode":"0","outcome":"failure","reason":"UnparsableOutput","exitCodeLabel":""},"measures":{"resolveAttempts":1,"timing.totalResolveTime":14139,"timing.preSshTime":34}}
[16:14:39.200] ------
```

# css
## 两种引入css的方式的不同
1. @import url("../../../../../@universe-ui/react/src/variables.less");
2. @import "@universe-design/styles/less/tokens/index.less";

使用 @import 规则可能会影响网页的性能，特别是如果它们数量很多的话。
- 第一个 @import 规则比第二个要慢，因为它会阻塞页面的渲染，直到导入的文件被下载和处理完成。
- 而第二个 @import 规则使用了非阻塞异步方法来加载导入的文件，因此可以让页面在文件下载时继续渲染，提高了页面的性能。


## 在react中引入css
一般写css是写在css文件，然后再react文件中引入。
```less
.loading{

}
```
```js
import "./loading.less"
const RenderDiv = ()=>{
  return <div className="loading"></div>
}
```

我如何在react中直接引入css？
1. style

与使用 CSS 文件或 Less 文件相比，内联样式的性能可能会稍差一些。这是因为内联样式需要在每个组件渲染时都重新计算样式，而使用 CSS 文件或 Less 文件则可以在多个组件之间共享样式。但是，在大多数情况下，这种性能差异是可以忽略不计的。

```js
const styles = {
  loading: {
    display: 'flex',
  }
};

const RenderDiv = () => {
  return <div style={styles.loading}>Loading...<p className="loading-p"></p></div>;
};
```

2. js添加style

这种可以像less文件一样写。

使用 JavaScript 添加样式可能会导致样式的可维护性降低，因为样式被分散在不同的 JavaScript 文件中。另外，由于样式是动态添加的，可能会影响到页面的性能。

```js
const addStylesToHead = (styles: string) => {
  const styleEl = document.createElement('style')
  styleEl.textContent = styles
  document.head.appendChild(styleEl)
}

const loadingStyle = `
  .stories-loading{
    width: 60px;
    height: 20px;
    .ai-message-loading-dot{
      width: 15px;
      height: 15px;
    }
  }
  @keyframes ai-text-generation {
      from {
        transform: translateY(0);
      }
    
      to {
        transform: translateY(10px);
      }
    }
`
addStylesToHead(loadingStyle)
```

# ai-动画
On Boarding，上船，












