CJ_SOCKS 仓颉SOCKS协议库
======================

实现基于SOCKS5协议的TCP连接

## 📦 安装

使用git方式进行引入，并使用 `cjpm update` 进行更新

（当仓颉包管理器完善时，将会推送到仓库使用版本安装）

```yaml
[dependencies]

cj_socks = { git = "https://gitcode.com/niuhuan_cn/cj_socks.git" }
```


## 📖 特性

| 传输协议 | 详情 |
| -- | -- |
| SOCKS5 | https://datatracker.ietf.org/doc/html/rfc1928 |


## 🔖 用例


```cangjie
main(): Int64 {
    // 连接socks服务器
    let socket = TcpSocket("localhost", 1080)
    socket.writeTimeout = Duration.second * 30 
    socket.readTimeout = Duration.second * 10 
    socket.connect()
    // 构建socks实例
    let sSocket = Socks5Socket(socket, "google.com", 80)
    // 之后当作Socket使用即可
    sSocket.write("GET / HTTP/1.1\r\nHost: google.com\r\n\r\n".toArray())
    sSocket.flush()
    let reader = StringReader(sSocket)
    while (true) {
        if (let Some(line) <- reader.readln()) {
            println(line)
        } else {
            break
        }
    }
    0
}
```

```html
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```

### 经过验证的仓颉版本

| 版本 | 分支 | 
| -- | -- |
| 0.53.13 | main |

## 🏆 贡献

欢迎您的issue和pull request, fork时请保留源仓库地址

## 📕 协议

参考 [LICENSE](LICENSE) 文件

