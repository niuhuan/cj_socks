class Socks4SocketFactory
=========================

```cangjie
main() {
    var factory = Socks4SocketFactory("127.0.0.1", 18000)
    try (sSocket = factory.connect(IPSocketAddress(IPv4Address(114,250,67,34), 80))) {
        sSocket.write("GET / HTTP/1.1\r\nHost: google.cn\r\n\r\n".toArray())
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
| connect(address: IPv4Address): StreamingSocket | 获得一个已经被代理好的 StreamingSocket |
