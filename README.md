CJ_SOCKS 仓颉SOCKS协议库
======================

实现基于SOCKS5、SOCKS4的Socket连接

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
| SOCKS4 | - |


## 🔖 用例

更多用例请参考[API文档](docs/api_doc.md)


```cangjie
main() {
    var factory = Socks5SocketFactory("192.168.2.1", 1080)
    try (sSocket = factory.connect("oracle.com", 80)) {
        sSocket.write("GET / HTTP/1.1\r\nHost: oracle.com\r\n\r\n".toArray())
        sSocket.flush()
        let reader = StringReader(sSocket)
        while (true) {
            if (let Some(line) <- reader.readln()) {
                println(line)
            } else {
                break
            }
        }
    }
}
```

```
HTTP/1.1 301 Moved Permanently
Date: Thu, 19 Dec 2024 13:32:15 GMT
Content-Type: text/html
Content-Length: 157
Connection: keep-alive
Location: https://oracle.com:443/

<html>
<head><title>301 Moved Permanently</title></head>
<body>
<center><h1>301 Moved Permanently</h1></center>
<hr><center></center>
</body>
</html>
```

### 经过验证的仓颉版本

| 版本 | 分支 | 
| -- | -- |
| 0.58.3 | main |
| 0.59.6 | main |

## 🏆 贡献

欢迎您的issue和pull request, fork时请保留源仓库地址

## 📕 协议

参考 [LICENSE](LICENSE) 文件

