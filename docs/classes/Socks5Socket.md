class Socks5Socket
==================

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

| 函数 | 说明 |
| :-- | :-- |
| init(socket: StreamingSocket, domain: String, port: UInt16, auth!: Option<(String, String)> = None) | 使用现有的socket连接进行socks5验证，并发送连接请求
| ... | 其他prop和函数均继承于StreamSocket，您可以查阅仓颉官方文档 |

