class Socks5SocketFactory
=========================

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

| 函数 | 说明 |
| :-- | :-- |
| init(host: String, port: UInt16, auth: Option<(String, String)>) | 创建一个factory， 用于反复获得socket连接 |
| connect(domain: String, port: UInt16): StreamingSocket | 获得一个已经被代理好的 StreamingSocket |