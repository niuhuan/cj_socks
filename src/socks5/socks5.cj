package cj_socks.socks5

import std.socket.*
import std.net.*
import std.io.*
import std.collection.*
import std.convert.*
import std.time.*

public class Socks5SocketFactory {
    public var host: String
    public var port: UInt16
    public var auth: Option<(String, String)>

    init(host: String, port: UInt16, auth!: Option<(String, String)> = None) {
        this.host = host
        this.port = port
        this.auth = auth
    }

    public func connect(domain: String, port: UInt16): StreamingSocket {
        return Socks5Socket(
                TcpSocket(this.host, this.port),
                domain,
                port,
                auth: auth
            )
    }
}

public class Socks5Socket <: StreamingSocket {

    private let socket: StreamingSocket
    
    public mut prop readTimeout: ?Duration {
        get() { socket.readTimeout }
        set(value) { socket.readTimeout = value }
    }

    public mut prop writeTimeout: ?Duration {
        get() { socket.writeTimeout }
        set(value) { socket.writeTimeout = value }
    }

    public prop localAddress: SocketAddress {
        get() { socket.localAddress }
    }

    public prop remoteAddress: SocketAddress {
        get() { socket.remoteAddress }
    }
    
    public init(socket: StreamingSocket, domain: String, port: UInt16, auth!: Option<(String, String)> = None) {
        this.socket = socket
        try {
            socks5Auth(auth:auth)
            socks5Connect(domain, port)
        }catch (e: Exception) {
            socket.close()
            throw e
        }
    }

    public func isClosed(): Bool {
        socket.isClosed()
    }

    public func close() {
        socket.close()
    }

    public func read(buff: Array<Byte>): Int64  {
        socket.read(buff)
    }

    public func write(buff: Array<Byte>) {
        socket.write(buff)
    }

    public func flush() {
        socket.flush()
    }
    
    public func toString(): String { 
        "Socks5Socket(${socket})"
    }

    private func socks5Auth(auth!: Option<(String, String)> = None) {
        socket.write([
            0x05,  // SOCKS5
            0x01   //  method count = 1
        ])
        if (let Some((username, password)) <- auth) {
            socket.write([0x02]) // username/password
            socket.flush()
            var buff = readSize(2)
            if (buff[0] != 0x05 || buff[1] != 0x02) {
                throw Exception("socks5 auth failed")
            }
            socket.write([0x01])
            socket.write([UInt8(username.toArray().size)])
            socket.write(username.toArray())
            socket.write([UInt8(password.toArray().size)])
            socket.write(password.toArray())
            socket.flush()
            buff = readSize(2)
            if (buff[0] != 0x01 || buff[1] != 0x00) {
                throw Exception("socks5 auth failed")
            }
        } else {
            socket.write([0x00]) // no auth
            socket.flush()
            let buff = readSize(2)
            if (buff[0] != 0x05 || buff[1] != 0x00) {
                throw Exception("socks5 auth failed")
            }
        }
    }

    private func socks5Connect(domain: String, port: UInt16): Unit {
        // VER	CMD	RSV	ATYP	DST.ADDR	DST.PORT
        socket.write([
            0x05, // version
            0x01, // connect
            0x00, // reserved
            0x03  // domain
        ])
        socket.write([UInt8(domain.size)]) // domain length
        socket.write(domain.toArray()) // domain
        socket.write([
            UInt8(port >> 8), // port
            UInt8(port & 0xff) // port
        ])
        socket.flush()
        // VER	REP	RSV	ATYP    BND.ADDR	BND.PORT
        let buff = readSize(4)
        if (buff[1] != 0) {
            throw Exception("socks5 connect failed")
        }
        match (buff[3]) {
            case 0x01 =>
                readSize(4)
            case 0x03 =>
                readSize(1)
                readSize(Int64(buff[0]))
            case 0x04 =>
                readSize(16)
            case _ =>
                throw IOException("invalid address type")
        }
        readSize(2)
    }

    private func readSize(size: Int): Array<Byte> {
        if (size == 0) {
            return Array<Byte>(0, {_=>0})
        }
        let array = Array<Byte>(size, {_=>0})
        var read = 0
        while (true) {
            let current = socket.read(array[read..])
            if (current == 0) {
                throw IOException("eof")
            }
            read += current
            if (read == size) {
                break
            }
        }
        array
    }

}


